package com.razorpay.razorpay_flutter;

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

    UpiTurbo(Activity activity) {

    }

    public void setKeyID(String keyId,  Object result){

    }

    public void linkNewUpiAccount(String customerMobile, String color, Object result){
    }


    public void manageUpiAccounts(String customerMobile, String color, Object result){

    }

    public  boolean isTurboPluginAvailable(Object result) {
        return false;
    }

    private String toJsonString(Object object){
     return "" ;
    }

    private void sendReply(Map<String, Object> data) {

    }

}