package com.razorpay.razorpay_flutter_example;

import android.os.Bundle;

import androidx.annotation.NonNull;

import com.razorpay.razorpay_flutter.RazorpayDelegate;
import com.razorpay.razorpay_flutter.RazorpayFlutterPlugin;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private ActivityPluginBinding pluginBinding;
  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    flutterEngine.getPlugins().add(new RazorpayFlutterPlugin());
  }
}
