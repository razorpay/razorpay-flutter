package com.razorpay.razorpay_flutter;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.razorpay.Checkout;
import com.razorpay.CheckoutActivity;
import com.razorpay.ExternalWalletListener;
import com.razorpay.PaymentData;
import com.razorpay.PaymentResultWithDataListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

public class RazorpayDelegate implements ActivityResultListener, ExternalWalletListener, PaymentResultWithDataListener {

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
    private String packageName;

    public RazorpayDelegate(Activity activity) {
        this.activity = activity;
    }

    void setPackageName(String packageName){
        this.packageName = packageName;
        Log.d("PackageName", packageName);
    }

    void openCheckout(Map<String, Object> arguments, Result result) {

        this.pendingResult = result;

        JSONObject options = new JSONObject(arguments);
        if (activity.getPackageName().equalsIgnoreCase(packageName)){
            Log.d("PAYMENT", activity.getPackageName()+";;;"+packageName);
            Intent intent = new Intent(activity, CheckoutActivity.class);
            intent.putExtra("OPTIONS", options.toString());
            intent.putExtra("FRAMEWORK", "flutter");

            activity.startActivityForResult(intent, Checkout.RZP_REQUEST_CODE);
        }


    }

    private void sendReply(Map<String, Object> data) {
        if (pendingResult != null) {
            pendingResult.success(data);
            pendingReply = null;
        } else {
            pendingReply = data;
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
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_ERROR);

        Map<String, Object> data = new HashMap<>();
        data.put("code", translateRzpPaymentError(code));
        data.put("message", message);

        reply.put("data", data);

        sendReply(reply);
    }

    @Override
    public void onPaymentSuccess(String paymentId, PaymentData paymentData) {
        Map<String, Object> reply = new HashMap<>();
        reply.put("type", CODE_PAYMENT_SUCCESS);

        Map<String, Object> data = new HashMap<>();
        data.put("razorpay_payment_id", paymentData.getPaymentId());
        data.put("razorpay_order_id", paymentData.getOrderId());
        data.put("razorpay_signature", paymentData.getSignature());

        if (paymentData.getData().has("razorpay_subscription_id")) {
            try {
                data.put("razorpay_subscription_id", paymentData.getData().optString("razorpay_subscription_id"));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }


        reply.put("data", data);
        sendReply(reply);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Checkout.handleActivityResult(activity, requestCode, resultCode, data, this, this);
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
