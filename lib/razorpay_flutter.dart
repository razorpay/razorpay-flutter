import 'package:flutter/services.dart';

import 'package:eventify/eventify.dart';

class Razorpay {

  // Response codes from platform
  static const _CODE_PAYMENT_SUCCESS = 0;
  static const _CODE_PAYMENT_ERROR = 1;
  static const _CODE_PAYMENT_EXTERNAL_WALLET = 2;

  // Event names
  static const EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const EVENT_PAYMENT_ERROR = 'payment.error';
  static const EVENT_EXTERNAL_WALLET = 'payment.external_wallet';

  // Payment error codes
  // TODO update code values
  static const NETWORK_ERROR = 0;
  static const INVALID_OPTIONS = 1;
  static const PAYMENT_CANCELLED = 2;
  static const TLS_ERROR = 3;


  static const MethodChannel _channel =
      const MethodChannel('razorpay_flutter');

  // EventEmitter instance used for communication
  EventEmitter _eventEmitter;

  Razorpay() {
    _eventEmitter = new EventEmitter();
  }

  /// Opens Razorpay checkout
  void open(Map<String, dynamic> options) async {
    var response = await _channel.invokeMethod('open', options);
    _handleResult(response);
  }

  /// Handles checkout response from platform
  void _handleResult(Map<dynamic, dynamic> response) {
    String eventName;
    Map<dynamic, dynamic> data = response["data"];

    dynamic payload;

    switch (response['type']) {

      case _CODE_PAYMENT_SUCCESS:
        eventName = EVENT_PAYMENT_SUCCESS;
        payload = PaymentSuccessResponse.fromMap(data);
        break;

      case _CODE_PAYMENT_ERROR:
        eventName = EVENT_PAYMENT_ERROR;
        payload = PaymentFailureResponse.fromMap(data);
        break;

      case _CODE_PAYMENT_EXTERNAL_WALLET:
        eventName = EVENT_EXTERNAL_WALLET;
        payload = ExternalWalletResponse.fromMap(data);
        break;

      default:
        eventName = 'error';

    }

    _eventEmitter.emit(eventName, null, payload);
  }

  void on(String event, Function handler) {
    EventCallback cb = (event, cont) {
      handler(event.eventData);
    };
    _eventEmitter.on(event, null, cb);
    _resync();
  }

  void clear() {
    _eventEmitter.clear();
  }

  void _resync() async {
    var response = await _channel.invokeMethod('resync');
    if (response != null) {
      _handleResult(response);
    }
  }

}

class PaymentSuccessResponse {
  String paymentId;

  PaymentSuccessResponse(this.paymentId);

  static PaymentSuccessResponse fromMap(Map<dynamic, dynamic> map) {
    var paymentId = map["razorpay_payment_id"] as String;
    return new PaymentSuccessResponse(paymentId);
  }

}

class PaymentFailureResponse {

  int code;
  String message;

  PaymentFailureResponse(this.code, this.message);

  static PaymentFailureResponse fromMap(Map<dynamic, dynamic> map) {
    var code = map["code"] as int;
    var message = map["message"] as String;
    return new PaymentFailureResponse(code, message);
  }

}

class ExternalWalletResponse {
  String walletName;

  ExternalWalletResponse(this.walletName);

  static ExternalWalletResponse fromMap(Map<dynamic, dynamic> map) {
    var walletName = map["external_wallet"] as String;
    return new ExternalWalletResponse(walletName);
  }
}
