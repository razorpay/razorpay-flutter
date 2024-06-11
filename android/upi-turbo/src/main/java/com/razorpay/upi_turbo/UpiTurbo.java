package com.razorpay.upi_turbo;

import android.app.Activity;
import android.util.Log;



import com.google.gson.Gson;
import com.razorpay.Checkout;
import com.razorpay.GenericPluginCallback;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UpiTurbo {
    private final Activity activity;
    private Object pendingResult;
    private Map<String, Object> pendingReply;
    private Checkout checkout;
    Gson gson ;

    UpiTurbo(Activity activity) {
        this.activity = activity;
        checkout = new Checkout().upiTurbo(activity);
        this.gson = new Gson();
    }

    public void setKeyID(String keyId,  Object result){
        checkout.setKeyID(keyId);
    }

    public void linkNewUpiAccount(String customerMobile, String color, Object result){
        this.pendingResult = result;
        Map<String, Object> reply = new HashMap<>();
        checkout.upiTurbo.linkNewUpiAccount(customerMobile, color , new GenericPluginCallback(){
            @Override
            public void onSuccess( Object o) {
                if (o instanceof List<?> && !((List<?>) o).isEmpty()) {
                    reply.put("data", toJsonString(o));
                } else {
                    reply.put("data", "");
                }
                sendReply(reply);
            }

            @Override
            public void onError( JSONObject jsonObject) {
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
//                pendingResult.error(errorCode, errorDescription, jsonObject.toString());
            }

        });
    }


    public void manageUpiAccounts(String customerMobile, String color, Object result){
        this.pendingResult = result;
        HashMap<Object, Object> reply = new HashMap<>();
        checkout.upiTurbo.manageUpiAccounts(customerMobile, color , new GenericPluginCallback(){
            @Override
            public void onSuccess( Object object) {
            }

            @Override
            public void onError( JSONObject jsonObject) {
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
//                pendingResult.error(errorCode, errorDescription, jsonObject.toString());
            }
        });
    }

    public  boolean isTurboPluginAvailable(Object result) {
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

    private void sendReply(Map<String, Object> data) {
        if (pendingResult != null) {
//            pendingResult.success(data);
            pendingReply = null;
        } else {
            pendingReply = data;
        }
    }

}
