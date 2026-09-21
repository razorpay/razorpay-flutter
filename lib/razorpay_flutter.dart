import 'dart:async';
import 'package:flutter/foundation.dart';
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

  static const MethodChannel _channel = MethodChannel('razorpay_flutter');
  static const EventChannel _merchantEventChannel =
      EventChannel('razorpay_flutter/merchant_events');

  // EventEmitter instance used for communication
  late EventEmitter _eventEmitter;
  bool _resultHandled = false;

  // ignore: unused_field
  List<String>? _subscribedAnalyticsEvents;
  void Function(String payloadJson)? _onMerchantEvent;
  StreamSubscription<dynamic>? _merchantEventSubscription;

  /// Tracks event registrations that should receive the raw native
  /// response map instead of the typed response classes. This lets
  /// merchants share a single handler between razorpay_flutter and
  /// razorpay_flutter_customui.
  final Set<String> _rawMapEvents = <String>{};

  Razorpay() {
    _eventEmitter = EventEmitter();
  }

  /// Subscribes to checkout analytics events. Call before [open] to receive events.
  /// [events] e.g. ['payment.*', 'checkout.initiate', 'checkout.close'].
  /// [onEvent] is invoked with raw JSON string for each matching event.
  void subscribeToAnalyticsEvents(
      List<String> events, void Function(String payloadJson) onEvent) {
    _subscribedAnalyticsEvents = List.from(events);
    _onMerchantEvent = onEvent;
    _channel.invokeMethod(
        'subscribeToAnalyticsEvents', <String, dynamic>{'events': events});
    _merchantEventSubscription?.cancel();
    _merchantEventSubscription =
        _merchantEventChannel.receiveBroadcastStream().listen(
      (dynamic payload) {
        if (_onMerchantEvent != null && payload is String) {
          _onMerchantEvent!(payload);
        }
      },
      onError: (dynamic error) {
        debugPrint('[RazorpayFlutter] merchant event stream error: $error');
      },
    );
  }

  /// Opens Razorpay checkout
  void open(Map<String, dynamic> options) async {
    _resultHandled = false;
    Map<String, dynamic> validationResult = _validateOptions(options);

    if (!validationResult['success']) {
      _handleResult({
        'type': _CODE_PAYMENT_ERROR,
        'data': {
          'code': INVALID_OPTIONS,
          'message': validationResult['message']
        }
      });
      return;
    }

    var response = await _channel.invokeMethod('open', options);
    _handleResult(response);
  }

  /// Handles checkout response from platform
  void _handleResult(Map<dynamic, dynamic> response) {
    if (_resultHandled) {
      return;
    }
    _resultHandled = true;
    String eventName;
    Map<dynamic, dynamic>? data = response["data"];

    dynamic payload;

    switch (response['type']) {
      case _CODE_PAYMENT_SUCCESS:
        eventName = EVENT_PAYMENT_SUCCESS;
        payload = _rawMapEvents.contains(EVENT_PAYMENT_SUCCESS)
            ? (data ?? <dynamic, dynamic>{})
            : PaymentSuccessResponse.fromMap(data!);
        break;

      case _CODE_PAYMENT_ERROR:
        eventName = EVENT_PAYMENT_ERROR;
        payload = _rawMapEvents.contains(EVENT_PAYMENT_ERROR)
            ? (data ?? <dynamic, dynamic>{})
            : PaymentFailureResponse.fromMap(data!);
        break;

      case _CODE_PAYMENT_EXTERNAL_WALLET:
        eventName = EVENT_EXTERNAL_WALLET;
        payload = _rawMapEvents.contains(EVENT_EXTERNAL_WALLET)
            ? (data ?? <dynamic, dynamic>{})
            : ExternalWalletResponse.fromMap(data!);
        break;

      default:
        eventName = 'error';
        payload = _rawMapEvents.contains(EVENT_PAYMENT_ERROR)
            ? (data ?? <dynamic, dynamic>{})
            : PaymentFailureResponse(
                UNKNOWN_ERROR, 'An unknown error occurred.', null);
    }

    _eventEmitter.emit(eventName, null, payload);
  }

  /// Registers event listeners for payment events.
  ///
  /// By default the handler receives the typed response class
  /// (e.g. [PaymentSuccessResponse]). Set [rawMap] to `true` to receive the
  /// raw native response map instead. This is useful when you want to share
  /// the same handler between `razorpay_flutter` and
  /// `razorpay_flutter_customui`.
  void on(String event, Function handler, {bool rawMap = false}) {
    if (rawMap) {
      _rawMapEvents.add(event);
    } else {
      _rawMapEvents.remove(event);
    }

    EventCallback cb = (event, cont) {
      handler(event.eventData);
    };
    _eventEmitter.on(event, null, cb);
    _resync();
  }

  /// Clears all event listeners
  void clear() {
    _rawMapEvents.clear();
    _merchantEventSubscription?.cancel();
    _merchantEventSubscription = null;
    _onMerchantEvent = null;
    _subscribedAnalyticsEvents = null;
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
  String? paymentId;
  String? orderId;
  String? signature;
  Map<dynamic, dynamic>? data;

  PaymentSuccessResponse(
      this.paymentId, this.orderId, this.signature, this.data);

  static PaymentSuccessResponse fromMap(Map<dynamic, dynamic> map) {
    String? paymentId = map["razorpay_payment_id"];
    String? signature = map["razorpay_signature"];
    String? orderId = map["razorpay_order_id"];
    Map<dynamic, dynamic> data = map;
    return new PaymentSuccessResponse(paymentId, orderId, signature, data);
  }
}

class PaymentFailureResponse {
  int? code;
  String? message;
  Map<dynamic, dynamic>? error;

  PaymentFailureResponse(this.code, this.message, this.error);

  static PaymentFailureResponse fromMap(Map<dynamic, dynamic> map) {
    var code = map["code"] as int?;
    var message = map["message"] as String?;
    var rawBody = map["responseBody"];
    var responseBody = rawBody is Map<dynamic, dynamic> ? rawBody : null;
    return new PaymentFailureResponse(code, message, responseBody);
  }
}

class ExternalWalletResponse {
  String? walletName;

  ExternalWalletResponse(this.walletName);

  static ExternalWalletResponse fromMap(Map<dynamic, dynamic> map) {
    var walletName = map["external_wallet"] as String?;
    return new ExternalWalletResponse(walletName);
  }
}
