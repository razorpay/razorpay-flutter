package com.razorpay.razorpay_flutter;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.razorpay.Checkout;
import com.razorpay.CheckoutActivity;
import com.razorpay.ExternalWalletListener;
import com.razorpay.GenericPluginCallback;
import com.razorpay.PaymentData;
import com.razorpay.PaymentResultWithDataListener;
import com.razorpay.UpiTurboLinkAccountResultListener;
import com.razorpay.upi.Error;
import com.razorpay.upi.UpiAccount;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
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
    private Checkout checkout;
    Gson gson ;

    public RazorpayDelegate(Activity activity) {
        this.activity = activity;
        checkout = new Checkout().upiTurbo(activity);
        this.gson = new Gson();
    }

    void setPackageName(String packageName){
        this.packageName = packageName;
    }

    void openCheckout(Map<String, Object> arguments, Result result) {

        this.pendingResult = result;

        JSONObject options = new JSONObject(arguments);
        if (activity.getPackageName().equalsIgnoreCase(packageName)){
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
        try{
            JSONObject response = new JSONObject(message);
            JSONObject errorObj = response.getJSONObject("error");
            data.put("message", errorObj.getString("description"));
            JSONObject metadata = errorObj.getJSONObject("metadata");
            Map<String, String> metadataHash = new HashMap<>();
            Iterator<String> metaKeys = metadata.keys();
            while (metaKeys.hasNext()){
                String key = metaKeys.next();
                metadataHash.put(key,metadata.getString(key));
            }
            errorObj.remove("metadata");
            Map<String,Object> resp = new HashMap<>();
            Iterator<String> keys = errorObj.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                resp.put(key,errorObj.get(key));
            }
            resp.put("metadata", metadataHash);
            resp.put("email", paymentData.getUserEmail());
            resp.put("contact", paymentData.getUserContact());
            data.put("responseBody", resp);
        }catch (JSONException e){
            data.put("message", message);
            data.put("responseBody", message);
        }

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

    public void setKeyID(String keyId,  Result result){
        checkout.setKeyID(keyId);
    }

    public void linkNewUpiAccount(String customerMobile, String color, Result result){
        Log.d("RazorpayDelegate" , "customerMobile "+customerMobile +" color "+color);
        this.pendingResult = result;
        Map<String, Object> reply = new HashMap<>();
        checkout.upiTurbo.linkNewUpiAccount(customerMobile, color , new GenericPluginCallback(){
            @Override
            public void onSuccess(@NonNull Object o) {
                if (o instanceof List<?> && !((List<?>) o).isEmpty()) {
                    reply.put("data", toJsonString(o));
                } else {
                    reply.put("data", "");
                }
                sendReply(reply);
            }

            @Override
            public void onError(@NonNull JSONObject jsonObject) {
                String errorCode = "AXIS_SDK_ERROR";
                String errorDescription = "Something went wrong.Please try again.";
                try {
                    if (jsonObject.has("error")) {
                        errorCode = jsonObject.getJSONObject("error").getString("code");
                        errorDescription = jsonObject.getJSONObject("error").getString("description");
                    }
                } catch (Exception e) {
                    Log.d("Exception", e.getMessage());
                }
                pendingResult.error(errorCode, errorDescription, jsonObject.toString());
            }

        });
    }


    public void manageUpiAccounts(String customerMobile, String color, Result result){
        this.pendingResult = result;
        HashMap<Object, Object> reply = new HashMap<>();
        checkout.upiTurbo.manageUpiAccounts(customerMobile, color , new GenericPluginCallback(){
            @Override
            public void onSuccess(@NonNull Object object) {
            }

            @Override
            public void onError(@NonNull JSONObject jsonObject) {
                String errorCode = "AXIS_SDK_ERROR";
                String errorDescription = "Something went wrong.Please try again.";
                try {
                    if (jsonObject.has("error")) {
                        errorCode = jsonObject.getJSONObject("error").getString("code");
                        errorDescription = jsonObject.getJSONObject("error").getString("description");
                    }
                } catch (Exception e) {
                    Log.d("Exception", e.getMessage());
                }
                pendingResult.error(errorCode, errorDescription, jsonObject.toString());
            }
        });
    }

    public  boolean isTurboPluginAvailable(Result result) {
        this.pendingResult = result;

        Map<String, Object> reply = new HashMap<>();
        try {
            Class.forName("com.razorpay.UpiTurboLinkAccountResultListener");
            reply.put("isTurboPluginAvailable", true);
            sendReply(reply);
            return true;
        } catch (ClassNotFoundException e) {
            // Class not found, so it doesn't exist
            reply.put("isTurboPluginAvailable", false);
            sendReply(reply);
            return false;
        }
    }

    private String toJsonString(Object object){
        return this.gson.toJson(object);
    }

}
