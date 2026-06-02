package com.razorpay.razorpay_flutter;

import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONException;

import java.util.Map;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * RazorpayFlutterPlugin
 */
public class RazorpayFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private RazorpayDelegate razorpayDelegate;
    private ActivityPluginBinding pluginBinding;
    private static final String CHANNEL_NAME = "razorpay_flutter";
    private static final String MERCHANT_EVENT_CHANNEL_NAME = "razorpay_flutter/merchant_events";

    private EventChannel.EventSink merchantEventSink;

    public RazorpayFlutterPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        EventChannel merchantEventChannel = new EventChannel(binding.getBinaryMessenger(), MERCHANT_EVENT_CHANNEL_NAME);
        merchantEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                merchantEventSink = events;
                if (razorpayDelegate != null) {
                    razorpayDelegate.setMerchantEventSink(merchantEventSink);
                }
            }

            @Override
            public void onCancel(Object arguments) {
                merchantEventSink = null;
                if (razorpayDelegate != null) {
                    razorpayDelegate.setMerchantEventSink(null);
                }
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }


//    /**
//     * Constructor for Flutter version < 1.12
//     * @param registrar
//     */
//    private RazorpayFlutterPlugin(Registrar registrar) {
//        this.razorpayDelegate = new RazorpayDelegate(registrar.activity());
//        this.razorpayDelegate.setPackageName(registrar.activity().getPackageName());
//        registrar.addActivityResultListener(razorpayDelegate);
//    }

    @Override
    @SuppressWarnings("unchecked")
    public void onMethodCall(MethodCall call, Result result) {


        switch (call.method) {
            case "open":
                razorpayDelegate.openCheckout((Map<String, Object>) call.arguments, result);
                break;
            case "resync":
                razorpayDelegate.resync(result);
                break;
            case "subscribeToAnalyticsEvents":
                @SuppressWarnings("unchecked")
                Map<String, Object> args = call.arguments != null ? (Map<String, Object>) call.arguments : null;
                List<String> events = args != null && args.containsKey("events")
                    ? (List<String>) args.get("events")
                    : new ArrayList<>();
                razorpayDelegate.subscribeToAnalyticsEvents(events, result);
                break;
            default:
                result.notImplemented();
        }

    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.razorpayDelegate = new RazorpayDelegate(binding.getActivity());
        this.pluginBinding = binding;
        razorpayDelegate.setPackageName(binding.getActivity().getPackageName());
        if (merchantEventSink != null) {
            razorpayDelegate.setMerchantEventSink(merchantEventSink);
        }
        binding.addActivityResultListener(razorpayDelegate);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        pluginBinding.removeActivityResultListener(razorpayDelegate);
        pluginBinding = null;
    }
}
