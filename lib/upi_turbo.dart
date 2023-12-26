import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/model/Error.dart';
import 'package:razorpay_flutter/model/upi_account.dart';

typedef void OnSuccess<T>(T result);
typedef void OnFailure<T>(T error);

class UpiTurbo {
  late MethodChannel _channel;
  // Turbo UPI
  bool _isTurboPluginAvailable = true;

  UpiTurbo(MethodChannel channel){
    this._channel = channel;
    _checkTurboPluginAvailable();
  }

  void _checkTurboPluginAvailable() async {
    final Map<dynamic, dynamic> turboPluginAvailableResponse = await _channel.invokeMethod('isTurboPluginAvailable');
    _isTurboPluginAvailable = turboPluginAvailableResponse["isTurboPluginAvailable"];
  }

  void linkNewUpiAccount({required String? customerMobile,  String? color , required OnSuccess<List<UpiAccount>> onSuccess,
    required OnFailure<Error> onFailure} ) async {
    try {

      if(!_isTurboPluginAvailable){
        _emitFailure(onFailure);
        return;
      }

      var requestLinkNewUpiAccountWithUI =  <String, dynamic>{
        "customerMobile": customerMobile,
        "color": color
      };

      final Map<dynamic, dynamic> getLinkedUpiAccountsResponse = await _channel.invokeMethod('linkNewUpiAccount', requestLinkNewUpiAccountWithUI);
      if(getLinkedUpiAccountsResponse["data"]!=""){
        onSuccess(_getUpiAccounts(getLinkedUpiAccountsResponse["data"]));
      }else {
        onFailure(Error(errorCode:"" , errorDescription: "No Account Found", errorReason: "sdk_error", errorSource: "unknown_source", errorStep: ""));
      }

    } on PlatformException catch (error) {
      onFailure(Error(errorCode:error.code , errorDescription: error.message!, errorReason: "sdk_error", errorSource: "unknown_source", errorStep: ""));
    }
  }

  void manageUpiAccounts({required String? customerMobile, String? color, required OnFailure<Error> onFailure} ) async {
    try {
      if(!_isTurboPluginAvailable){
        _emitFailure(onFailure);
        return;
      }

      var requestManageUpiAccounts =  <String, dynamic>{
        "customerMobile": customerMobile,
        "color": color
      };

      await _channel.invokeMethod('manageUpiAccounts', requestManageUpiAccounts);
    } on PlatformException catch (error) {
      onFailure(Error(errorCode:error.code , errorDescription: error.message!, errorReason: "sdk_error", errorSource: "unknown_source", errorStep: ""));
    }
  }

  List<UpiAccount> _getUpiAccounts(jsonString) {
    if (jsonString.toString().isEmpty){
      return <UpiAccount>[];
    }

    List<UpiAccount> upiAccounts = List<UpiAccount>.from(
      json.decode(jsonString).map((x) => UpiAccount.fromJson(x)),
    );
    return upiAccounts;
  }

  void _emitFailure(OnFailure<Error> onFailure) {
    onFailure(Error(errorCode:"" , errorDescription: "No Turbo Plugin Found", errorReason: "sdk_error", errorSource: "unknown_source", errorStep: ""));
  }

}
