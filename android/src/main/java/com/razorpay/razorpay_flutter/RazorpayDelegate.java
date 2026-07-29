package com.razorpay.razorpay_flutter;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.razorpay.Checkout;
import com.razorpay.CheckoutActivity;
import com.razorpay.EventCallback;
import com.razorpay.ExternalWalletListener;
import com.razorpay.PaymentData;
import com.razorpay.PaymentResultWithDataListener;

import org.json.JSONObject;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

public class RazorpayDelegate implements ActivityResultListener, ExternalWalletListener, PaymentResultWithDataListener, EventCallback {

    private final Activity activity;
    private Result pendingResult;
    private Map<String, Object> pendingReply;

    // Response codes for communicating with plugin
    private static final int CODE_PAYMENT_SUCCESS = 0;
    private static final int CODE_PAYMENT_ERROR = 1;
    private static final int CODE_PAYMENT_EXTERNAL_WALLET = 2;

    // Payment error codes for communicating with plugin
    private static final int NETWORK_ERROR = 0;
    private static final int INVALID_OPTIONS = 1;
    private static final int PAYMENT_CANCELLED = 2;
    private static final int TLS_ERROR = 3;
    private static final int INCOMPATIBLE_PLUGIN = 3;
    private static final int UNKNOWN_ERROR = 100;
    private static final String TAG = "RazorpayFlutter";

    private String packageName;
    private EventChannel.EventSink merchantEventSink;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private volatile boolean paymentCompleted = false;
    private volatile Map<String, Object> completedPaymentData = null;
    private static final long CANCEL_GRACE_PERIOD_MS = 2000;

    public RazorpayDelegate(Activity activity) {
        this.activity = activity;
    }

    void setPackageName(String packageName){
        this.packageName = packageName;
    }

    void setMerchantEventSink(EventChannel.EventSink sink) {
        this.merchantEventSink = sink;
    }

    void subscribeToAnalyticsEvents(List<String> events, Result result) {
        try {
            Checkout checkout = Checkout.getInstance(activity);
            checkout.setEventCallback(this);
            if (events != null && !events.isEmpty()) {
                Method setSubscribed = Checkout.class.getDeclaredMethod("setSubscribedAnalyticsEvents", ArrayList.class);
                setSubscribed.setAccessible(true);
                setSubscribed.invoke(checkout, new ArrayList<>(events));
              }
        } catch (Exception e) {
            Log.w(TAG, "Failed to subscribe to analytics events: " + e.getMessage());
        }
        if (result != null) {
            result.success(null);
        }
    }

    void openCheckout(Map<String, Object> arguments, Result result) {
         this.pendingResult = result;
        this.paymentCompleted = false;
        this.completedPaymentData = null;
        JSONObject options = new JSONObject(arguments);
        try {
            Checkout checkout = Checkout.getInstance(activity);
            checkout.setEventCallback(this);
        } catch (Exception e) {
            Log.w(TAG, "Failed to set event callback in openCheckout: " + e.getMessage());
        }
        if (activity.getPackageName().equalsIgnoreCase(packageName)){
            Intent intent = new Intent(activity, CheckoutActivity.class);
            intent.putExtra("OPTIONS", options.toString());
            intent.putExtra("FRAMEWORK", "flutter");
            activity.startActivityForResult(intent, Checkout.RZP_REQUEST_CODE);
        }
     }

    @Override
    public void onEvent(String payloadJson) {
        if (payloadJson != null && !paymentCompleted) {
            String lower = payloadJson.toLowerCase();
            if (lower.contains("payment.captured") || lower.contains("payment.authorized") || lower.contains("payment.success")) {
                paymentCompleted = true;
                try {
                    JSONObject event = new JSONObject(payloadJson);
                    JSONObject payload = event.optJSONObject("payload");
                    if (payload != null) {
                        JSONObject payment = payload.optJSONObject("payment");
                        if (payment != null) {
                            Map<String, Object> data = new HashMap<>();
                            data.put("razorpay_payment_id", payment.optString("id", ""));
                            data.put("razorpay_order_id", payment.optString("order_id", ""));
                            completedPaymentData = data;
                        }
                    }
                } catch (Exception e) {
                    Log.w(TAG, "Failed to parse payment completion event: " + e.getMessage());
                }
            }
        }
        if (merchantEventSink == null) {
            return;
        }
        mainHandler.post(() -> {
            if (merchantEventSink != null) {
                merchantEventSink.success(payloadJson);
            }
        });
    }

    private void sendReply(Map<String, Object> data) {
        try{
            
            if (pendingResult != null) {
                pendingResult.success(data);
                pendingReply = null;
            } else {
                pendingReply = data;
            }
        }catch(Exception e){
            //no-op
        }
    }

    public void resync(Result result) {
        result.success(pendingReply);
        pendingReply = null;
    }

    private static int translateRzpPaymentError(int errorCode) {
        switch (errorCode) {
            case Checkout.NETWORK_ERROR:
                return NETWORK_ERROR;
            case Checkout.INVALID_OPTIONS:
                return INVALID_OPTIONS;
            case Checkout.PAYMENT_CANCELED:
                return PAYMENT_CANCELLED;
            case Checkout.TLS_ERROR:
                return TLS_ERROR;
            case Checkout.INCOMPATIBLE_PLUGIN:
                return INCOMPATIBLE_PLUGIN;
            default:
                return UNKNOWN_ERROR;
        }
    }

    @Override
    public void onPaymentError(int code, String message, PaymentData paymentData) {
        int translatedCode = translateRzpPaymentError(code);

        if (translatedCode == PAYMENT_CANCELLED && paymentCompleted) {
            if (completedPaymentData != null) {
                Map<String, Object> reply = new HashMap<>();
                reply.put("type", CODE_PAYMENT_SUCCESS);
                reply.put("data", completedPaymentData);
                sendReply(reply);
                return;
            }
            mainHandler.postDelayed(() -> {
                if (paymentCompleted && completedPaymentData != null) {
                    Map<String, Object> reply = new HashMap<>();
                    reply.put("type", CODE_PAYMENT_SUCCESS);
                    reply.put("data", completedPaymentData);
                    sendReply(reply);
                } else {
                    sendPaymentError(translatedCode, message, paymentData);
                }
            }, CANCEL_GRACE_PERIOD_MS);
            return;
        }

        sendPaymentError(translatedCode, message, paymentData);
    }

    private void sendPaymentError(int translatedCode, String message, PaymentData paymentData) {
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_ERROR);
        Map<String, Object> data = new HashMap<>();
        data.put("code", translatedCode);
        try {
            JSONObject response = new JSONObject(message);
            JSONObject errorObj = response.getJSONObject("error");
            data.put("message", errorObj.optString("description", ""));
            JSONObject metadata = errorObj.optJSONObject("metadata");
            Map<String, String> metadataHash = new HashMap<>();
            if (metadata != null) {
                Iterator<String> metaKeys = metadata.keys();
                while (metaKeys.hasNext()) {
                    String key = metaKeys.next();
                    metadataHash.put(key, metadata.getString(key));
                }
            }
            errorObj.remove("metadata");
            Map<String, Object> resp = new HashMap<>();
            Iterator<String> keys = errorObj.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                resp.put(key, errorObj.get(key));
            }
            resp.put("metadata", metadataHash);
            resp.put("email", paymentData != null ? paymentData.getUserEmail() : null);
            resp.put("contact", paymentData != null ? paymentData.getUserContact() : null);
            data.put("responseBody", resp);
        } catch (Exception e) {
            data.put("message", message);
            Map<String, Object> resp = new HashMap<>();
            resp.put("description", message);
            data.put("responseBody", resp);
        }
        reply.put("data", data);
        sendReply(reply);
    }

    @Override
    public void onPaymentSuccess(String paymentId, PaymentData paymentData) {
        paymentCompleted = true;
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_SUCCESS);

        Map<String, Object> data = new HashMap<>();
        data.put("razorpay_payment_id", paymentData.getPaymentId());
        data.put("razorpay_order_id", paymentData.getOrderId());
        data.put("razorpay_signature", paymentData.getSignature());

        if (paymentData.getData().has("razorpay_subscription_id")) {
            try {
                data.put("razorpay_subscription_id", paymentData.getData().optString("razorpay_subscription_id"));
            } catch (Exception e) {}
        }
        reply.put("data", data);
        sendReply(reply);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        try{
            Method merchantActivityResult = Checkout.class.getMethod("merchantActivityResult", Activity.class, Integer.class, Integer.class, Intent.class, PaymentResultWithDataListener.class, ExternalWalletListener.class);
            merchantActivityResult.invoke(null,activity, requestCode, resultCode, data, this, this);
        }catch (Exception e){
            Checkout.handleActivityResult(activity, requestCode, resultCode, data, this, this);
        }
        return true;
    }

    @Override
    public void onExternalWalletSelected(String walletName, PaymentData paymentData) {
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_EXTERNAL_WALLET);

        Map<String, Object> data = new HashMap<>();
        data.put("external_wallet", walletName);
        reply.put("data", data);

        sendReply(reply);
    }

}
