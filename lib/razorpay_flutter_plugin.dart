// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:razorpay_flutter/js_razorpay.dart';

class RazorpayFlutterPlugin {
  /// Success response code
  static const _CODE_PAYMENT_SUCCESS = 0;

  /// Error response code
  static const _CODE_PAYMENT_ERROR = 1;

  /// External wallet response code
  // static const _CODE_PAYMENT_EXTERNAL_WALLET = 2;

  // Payment error codes

  /// Network error code
  static const NETWORK_ERROR = 0;

  /// Invalid options error code
  static const INVALID_OPTIONS = 1;

  /// Payment cancelled error code
  static const PAYMENT_CANCELLED = 2;

  /// TLS error code
  static const TLS_ERROR = 3;

  /// Incompatible plugin error code
  static const INCOMPATIBLE_PLUGIN = 4;

  /// Unknown error code
  static const UNKNOWN_ERROR = 100;

  /// Base request error code
  static const BASE_REQUEST_ERROR = 5;

  /// instance of JsRazorpay class.
  JsRazorpay? _jsRazorpay;

  /// Registers plugin with registrar
  static void registerWith(Registrar registrar) {
    final MethodChannel methodChannel = MethodChannel(
      'razorpay_flutter',
      const StandardMethodCodec(),
      registrar,
    );

    final RazorpayFlutterPlugin instance = RazorpayFlutterPlugin();
    methodChannel.setMethodCallHandler(instance.handleMethodCall);
  }

  /// Handles method calls over platform channel
  Future<Map<dynamic, dynamic>> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'open':
        return await startPayment(call.arguments);
      case 'resync':
      default:
        var defaultMap = {'status': 'Not implemented on web'};

        return defaultMap;
    }
  }

  /// check retry in option
  (bool, int) _retryStatus(dynamic options) {
    int maxCount = 0;
    bool isRetryEnabled = true;

    if (options.containsKey('retry')) {
      if (options['retry'].runtimeType == bool) {
        isRetryEnabled = options['retry'];
      }

      if (options['retry'].runtimeType.toString() ==
          "LinkedMap<Object?, Object?>") {
        if (options['retry'].containsKey('enabled')) {
          isRetryEnabled = options['retry']['enabled'] ?? true;
          // maxCount = options['retry']['max_count'] ?? 0;
        }
      }
    }

    return (isRetryEnabled, maxCount);
  }

  /// Convert LegacyJavaScriptObject to Dart Map.
  Map<String, dynamic>? _mapify(dynamic obj) {
    if (obj == null) return null;
    return jsonDecode(stringify(obj));
  }

  Future<Map<dynamic, dynamic>> startPayment(
    Map<dynamic, dynamic> options,
  ) async {
    /// required for sending value after the data has been populated
    var completer = Completer<Map<String, dynamic>>();

    /// reply that to be return
    var reply = <String, dynamic>{};

    /// collect data from razorpay response
    var data = <String, dynamic>{};

    /// check retry enabled in options
    /// true (default): Enables customers to retry payments.
    bool isRetryEnabled = true;

    /// Web Integration does not support the max_count parameter.
    // int maxCount = 0;

    var status = _retryStatus(options);
    isRetryEnabled = status.$1;
    // maxCount = status.$2;

    options['handler'] = allowInterop((dynamic res) {
      final response = _mapify(res);

      reply['type'] = _CODE_PAYMENT_SUCCESS;
      data['razorpay_payment_id'] = response?['razorpay_payment_id'];
      data['razorpay_order_id'] = response?['razorpay_order_id'];
      data['razorpay_signature'] = response?['razorpay_signature'];
      reply['data'] = data;

      /// send payment success reply
      completer.complete(reply);
    });

    options['modal.ondismiss'] = allowInterop((response) {
      if (!completer.isCompleted) {
        reply['type'] = _CODE_PAYMENT_ERROR;
        data['code'] = PAYMENT_CANCELLED;
        data['message'] = 'Payment processing cancelled by user';
        reply['data'] = data;

        /// send payment cancel reply
        completer.complete(reply);
      }
    });

    // assign options
    _jsRazorpay = JsRazorpay(
      options: options,
      onFailed: (res) {
        /// if retry is enabled then do not
        /// complete completer
        if (!isRetryEnabled) {
          final response = _mapify(res);

          reply['type'] = _CODE_PAYMENT_ERROR;
          data['code'] = BASE_REQUEST_ERROR;
          // final  errorResponse = response?['error'];
          data['message'] = response?['error']['description'];

          var metadata = <String, dynamic>{};
          metadata['payment_id'] = response?['error']['metadata']['payment_id'];
          data['metadata'] = metadata;

          data['source'] = response?['error']['source'];
          data['step'] = response?['error']['step'];
          reply['data'] = data;

          /// send payment failure reply
          completer.complete(reply);
        }
      },
    );

    // open payment gateway.
    // _jsRazorpay not null.
    _jsRazorpay?.open();

    return completer.future;
  }

  /// close razorpay checkout.<br>
  /// usage:-
  /// ```dart
  /// RazorpayFlutterPlugin.close();
  /// ```
  void close() {
    if (_jsRazorpay != null) {
      _jsRazorpay?.close();
    }
  }
}
