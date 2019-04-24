package com.razorpay.razorpay_flutter;

import android.app.Activity;
import android.content.Intent;

import com.razorpay.Checkout;
import com.razorpay.CheckoutActivity;
import com.razorpay.ExternalWalletListener;
import com.razorpay.PaymentData;
import com.razorpay.PaymentResultWithDataListener;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

public class RazorpayDelegate implements ActivityResultListener, ExternalWalletListener, PaymentResultWithDataListener {

    private final Activity activity;
    private Result pendingResult;
    private JSONObject pendingReply;

    private final int CODE_PAYMENT_SUCCESS = 0;
    private final int CODE_PAYMENT_ERROR = 1;
    private final int CODE_PAYMENT_EXTERNAL_WALLET = 2;


    public RazorpayDelegate(Activity activity) {
        this.activity = activity;
    }

    void openCheckout(Map<String, Object> arguments, Result result) {

        this.pendingResult = result;

        JSONObject optionsJSON = new JSONObject(arguments);

        Intent intent = new Intent(activity, CheckoutActivity.class);
        intent.putExtra("OPTIONS", optionsJSON.toString());
        intent.putExtra("FRAMEWORK", "flutter");

        activity.startActivityForResult(intent, Checkout.RZP_REQUEST_CODE);

    }

    private void sendReply(JSONObject data) {
        if (pendingResult != null) {
            try {
                pendingResult.success(Utils.toMap(data));
            } catch (JSONException e) {
                // TODO
            }
            pendingReply = null;
        } else {
            pendingReply = data;
        }
    }

    public void resync(Result result) throws JSONException {
        if (pendingReply != null) {
            result.success(Utils.toMap(pendingReply));
            pendingReply = null;
        } else {
            result.success(null);
        }
    }

    @Override
    public void onPaymentError(int code, String message, PaymentData paymentData) {
        try {
            JSONObject reply = new JSONObject();
            reply.put("type", CODE_PAYMENT_ERROR);

            JSONObject data = paymentData.getData();
            data.put("code", code);
            data.put("message", message);

            reply.put("data", data);

            sendReply(reply);
        } catch (Exception e) {
            // TODO handle exception
        }
    }

    @Override
    public void onPaymentSuccess(String paymentId, PaymentData data) {
        try {
            JSONObject reply = new JSONObject();
            reply.put("type", CODE_PAYMENT_SUCCESS);
            reply.put("data", data.getData());
            sendReply(reply);
        } catch (Exception e) {
            // TODO handle exception
        }
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Checkout.handleActivityResult(activity, requestCode, resultCode, data, this, this);
        return true;
    }

    @Override
    public void onExternalWalletSelected(String walletName, PaymentData paymentData) {
        try {
            JSONObject reply = new JSONObject();
            reply.put("type", CODE_PAYMENT_EXTERNAL_WALLET);

            JSONObject data = paymentData.getData();
            data.put("external_wallet", walletName);
            reply.put("data", data);

            sendReply(reply);
        } catch (Exception e) {
            //TODO handle
        }
    }

}
