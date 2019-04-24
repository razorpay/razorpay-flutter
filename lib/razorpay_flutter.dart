import 'package:flutter/services.dart';

import 'package:eventify/eventify.dart';


enum PaymentErrorCode {
  NETWORK_ERROR,
  INVALID_OPTIONS,
  PAYMENT_CANCELLED,
  TLS_ERROR
}

class RazorpayFlutter {

  static const CODE_PAYMENT_SUCCESS = 0;
  static const CODE_PAYMENT_ERROR = 1;
  static const CODE_PAYMENT_EXTERNAL_WALLET = 2;

  static const MethodChannel _channel =
      const MethodChannel('razorpay_flutter');

  EventEmitter _eventEmitter;

  RazorpayFlutter() {
    _eventEmitter = new EventEmitter();
  }

  void open(Map<String, dynamic> options) async {
    var response = await _channel.invokeMethod('open', options);
    _handleResult(response);
  }

  void _handleResult(Map<dynamic, dynamic> response) {
    String eventName;

    switch (response['type']) {

      case CODE_PAYMENT_SUCCESS:
        eventName = 'payment.success';
        break;

      case CODE_PAYMENT_ERROR:
        eventName = 'payment.error';
        break;

      case CODE_PAYMENT_EXTERNAL_WALLET:
        eventName = 'payment.external_wallet';
        break;

      default:
        eventName = 'payment.error';

    }

    _eventEmitter.emit(eventName, null, response['data']);
  }

  void on(String event, Function handler) {
    EventCallback cb = (ev, cont) {
      handler(ev.eventName, ev.eventData);
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
