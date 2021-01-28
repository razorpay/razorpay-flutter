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
  static const NETWORK_ERROR = 0;
  static const INVALID_OPTIONS = 1;
  static const PAYMENT_CANCELLED = 2;
  static const TLS_ERROR = 3;
  static const INCOMPATIBLE_PLUGIN = 4;
  static const UNKNOWN_ERROR = 100;

  static const MethodChannel _channel = const MethodChannel('razorpay_flutter');

  // EventEmitter instance used for communication
  EventEmitter _eventEmitter;

  Razorpay() {
    _eventEmitter = new EventEmitter();
  }

  /// Opens Razorpay checkout
  Future<Map<String, dynamic>> open(Map<String, dynamic> options) async {
    Map<String, dynamic> validationResult = _validateOptions(options);

    if (!validationResult['success']) {
      return _handleResult({
        'type': _CODE_PAYMENT_ERROR,
        'data': {
          'code': INVALID_OPTIONS,
          'message': validationResult['message']
        }
      });
    }

    var response = await _channel.invokeMethod('open', options);
    return _handleResult(response);
  }

  /// Handles checkout response from platform
  Map<String, dynamic> _handleResult(Map<dynamic, dynamic> response) {
    String eventName;
    Map<dynamic, dynamic> data = response['data'];

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
        payload =
            PaymentFailureResponse(UNKNOWN_ERROR, 'An unknown error occurred.');
    }

    _eventEmitter.emit(eventName, null, payload);

    // Creating a response map
    Map<String, dynamic> res = {'event': eventName};
    res['data'] = payload?.toJson();
    return res;
  }

  /// Registers event listeners for payment events
  void on(String event, Function handler) {
    EventCallback cb = (event, cont) {
      handler(event.eventData);
    };
    _eventEmitter.on(event, null, cb);
    _resync();
  }

  /// Clears all event listeners
  void clear() {
    _eventEmitter.clear();
  }

  /// Retrieves lost responses from platform
  void _resync() async {
    var response = await _channel.invokeMethod('resync');
    if (response != null) {
      _handleResult(response);
    }
  }

  /// Validate payment options
  static Map<String, dynamic> _validateOptions(Map<String, dynamic> options) {
    var key = options['key'];
    if (key == null) {
      return {
        'success': false,
        'message': 'Key is required. Please check if key is present in options.'
      };
    }
    return {'success': true};
  }
}

class PaymentSuccessResponse {
  String paymentId;
  String orderId;
  String signature;

  PaymentSuccessResponse(this.paymentId, this.orderId, this.signature);

  factory PaymentSuccessResponse.fromMap(Map<dynamic, dynamic> map) {
    String paymentId = map['razorpay_payment_id'];
    String signature = map['razorpay_signature'];
    String orderId = map['razorpay_order_id'];

    return new PaymentSuccessResponse(paymentId, orderId, signature);
  }

  Map<String, dynamic> toJson() {
    return {
      'razorpay_payment_id': this.paymentId,
      'razorpay_signature': this.signature,
      'razorpay_order_id': this.orderId,
    };
  }
}

class PaymentFailureResponse {
  int code;
  String message;

  PaymentFailureResponse(this.code, this.message);

  factory PaymentFailureResponse.fromMap(Map<dynamic, dynamic> map) {
    var code = map['code'] as int;
    var message = map['message'] as String;
    return new PaymentFailureResponse(code, message);
  }

  Map<String, dynamic> toJson() {
    return {'code': this.code, 'message': this.message};
  }
}

class ExternalWalletResponse {
  String walletName;

  ExternalWalletResponse(this.walletName);

  factory ExternalWalletResponse.fromMap(Map<dynamic, dynamic> map) {
    var walletName = map['external_wallet'] as String;
    return new ExternalWalletResponse(walletName);
  }

  Map<String, dynamic> toJson() {
    return {'external_wallet': this.walletName};
  }
}