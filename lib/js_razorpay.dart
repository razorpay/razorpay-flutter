import 'package:js/js.dart';
import 'package:js/js_util.dart';

/// JsRazorpay
class JsRazorpay {
  /// Js Razorpay Class
  final Razorpay razorpay;

  JsRazorpay({
    required Map<dynamic, dynamic> options,
    required Function(dynamic) onFailed,
  }) : razorpay = Razorpay(
          jsify(options),
        )..on(
            'payment.failed',
            allowInterop(onFailed),
          );

  /// open checkoout
  void open() => razorpay.open();

  /// close checkout
  void close() => razorpay.close();
}

@JS()
class Razorpay {
  external Razorpay(dynamic options);
  external open();
  external on(String type, Function(dynamic) onResponse);
  external close();
}

@JS('JSON.stringify')
external String stringify(Object obj);