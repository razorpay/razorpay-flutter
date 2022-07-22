package com.razorpay.razorpay_flutter;

import androidx.annotation.NonNull;

import org.json.JSONException;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * RazorpayFlutterPlugin
 */
public class RazorpayFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private RazorpayDelegate razorpayDelegate;
    private ActivityPluginBinding pluginBinding;
    private static String CHANNEL_NAME = "razorpay_flutter";


    public RazorpayFlutterPlugin() {
    }

    /**
     * Plugin registration for Flutter version < 1.12
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(new RazorpayFlutterPlugin(registrar));
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        final MethodChannel channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }


    /**
     * Constructor for Flutter version < 1.12
     * @param registrar
     */
    private RazorpayFlutterPlugin(Registrar registrar) {
        this.razorpayDelegate = new RazorpayDelegate(registrar.activity());
        registrar.addActivityResultListener(razorpayDelegate);
    }

    @Override
    @SuppressWarnings("unchecked")
    public void onMethodCall(MethodCall call, Result result) {


        switch (call.method) {

            case "open":
                razorpayDelegate.openCheckout((Map<String, Object>) call.arguments, result);
                break;

            case "setPackageName":
                razorpayDelegate.setPackageName((String)call.arguments);
                break;

            case "resync":
                razorpayDelegate.resync(result);
                break;

            default:
                result.notImplemented();

        }

    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.razorpayDelegate = new RazorpayDelegate(binding.getActivity());
        this.pluginBinding = binding;
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
