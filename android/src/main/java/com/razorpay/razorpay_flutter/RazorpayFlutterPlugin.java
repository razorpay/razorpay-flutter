package com.razorpay.razorpay_flutter;

import org.json.JSONException;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * RazorpayFlutterPlugin
 */
public class RazorpayFlutterPlugin implements MethodCallHandler {

    private final RazorpayDelegate razorpayDelegate;
    private static String CHANNEL_NAME = "razorpay_flutter";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(new RazorpayFlutterPlugin(registrar));
    }

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

            case "resync":
                razorpayDelegate.resync(result);
                break;

            default:
                result.notImplemented();

        }

    }

}
