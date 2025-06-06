import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/model/Error.dart';
import 'package:razorpay_flutter/model/upi_account.dart';
import 'package:eventify/eventify.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef void OnSuccess<T>(T result);
typedef void OnFailure<T>(T error);

class UpiTurbo {
  late MethodChannel _channel;
  late EventEmitter _eventEmitter;
  StreamSubscription? _eventSubscription;

  final _eventChannel = const EventChannel('razorpay_turbo_with_turbo_upi');

  // Turbo UPI
  bool _isTurboPluginAvailable = true;

  UpiTurbo(MethodChannel channel, EventEmitter eventEmitter) {
    this._channel = channel;
    this._eventEmitter = eventEmitter;
    _streamFromNative();
    _checkTurboPluginAvailable();
  }

  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  void _checkTurboPluginAvailable() async {
    final Map<dynamic, dynamic> turboPluginAvailableResponse =
        await _channel.invokeMethod('isTurboPluginAvailable');
    _isTurboPluginAvailable =
        turboPluginAvailableResponse["isTurboPluginAvailable"];
  }

  void _streamFromNative() {
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void _onError(dynamic error) {
    print("Error: $error");
    _eventEmitter.emit('error', null,
        Error(errorCode: "TURBO_ERROR", errorDescription: error.toString()));
  }

  void linkNewUpiAccount(
      {required String? customerMobile,
      String? color,
      required OnSuccess<List<UpiAccount>> onSuccess,
      required OnFailure<Error> onFailure}) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }

      var requestLinkNewUpiAccountWithUI = <String, dynamic>{
        "customerMobile": customerMobile,
        "color": color
      };

      final Map<dynamic, dynamic> getLinkedUpiAccountsResponse = await _channel
          .invokeMethod('linkNewUpiAccount', requestLinkNewUpiAccountWithUI);
      if (getLinkedUpiAccountsResponse["data"] != "") {
        onSuccess(_getUpiAccounts(getLinkedUpiAccountsResponse["data"]));
      } else {
        onFailure(Error(
            errorCode: "NO_ACCOUNT_FOUND",
            errorDescription: "No Account Found"));
      }
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  void manageUpiAccounts(
      {required String? customerMobile,
      String? color,
      required OnFailure<Error> onFailure}) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }
      var requestManageUpiAccounts = <String, dynamic>{
        "customerMobile": customerMobile,
        "color": color
      };

      await _channel.invokeMethod(
          'manageUpiAccounts', requestManageUpiAccounts);
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  List<UpiAccount> _getUpiAccounts(jsonString) {
    if (jsonString.toString().isEmpty) {
      return <UpiAccount>[];
    }

    List<UpiAccount> upiAccounts = List<UpiAccount>.from(
      json.decode(jsonString).map((x) => UpiAccount.fromJson(x)),
    );
    return upiAccounts;
  }

  void _emitFailure(OnFailure<Error> onFailure) {
    onFailure(Error(
        errorCode: "AXIS_SDK_ERROR",
        errorDescription: "No Turbo Plugin Found"));
  }

  void _onEvent(dynamic event) {
    if (event["responseEvent"] == "refreshSessionToken") {
      _eventEmitter.emit(Razorpay.EVENT_FETCH_SESSION_TOKEN, null, event);
    }
  }

  void updateSessionToken({required String token}) {
    _channel.invokeMethod('refreshSessionToken', token);
  }
}
