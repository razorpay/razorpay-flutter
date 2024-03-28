import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/model/Error.dart';
import 'package:razorpay_flutter/model/upi_account.dart';

typedef OnSuccess<T> = void Function(T result);
typedef OnFailure<T> = void Function(T error);

class UpiTurbo {
  late MethodChannel _channel;
  // Turbo UPI
  bool _isTurboPluginAvailable = true;

  UpiTurbo(MethodChannel channel) {
    _channel = channel;
    _checkTurboPluginAvailable();
  }

  void _checkTurboPluginAvailable() async {
    final Map<dynamic, dynamic> turboPluginAvailableResponse =
        await _channel.invokeMethod('isTurboPluginAvailable');
    _isTurboPluginAvailable =
        turboPluginAvailableResponse["isTurboPluginAvailable"];
  }

  void linkNewUpiAccount({
    required String? customerMobile,
    String? color,
    required OnSuccess<List<UpiAccount>> onSuccess,
    required OnFailure<Error> onFailure,
  }) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }

      var requestLinkNewUpiAccountWithUI = <String, dynamic>{
        "customerMobile": customerMobile,
        "color": color,
      };

      final Map<dynamic, dynamic> getLinkedUpiAccountsResponse = await _channel
          .invokeMethod('linkNewUpiAccount', requestLinkNewUpiAccountWithUI);
      if (getLinkedUpiAccountsResponse["data"] != "") {
        onSuccess(_getUpiAccounts(getLinkedUpiAccountsResponse["data"]));
      } else {
        onFailure(
          Error(
            errorCode: "NO_ACCOUNT_FOUND",
            errorDescription: "No Account Found",
          ),
        );
      }
    } on PlatformException catch (error) {
      onFailure(Error(errorCode: error.code, errorDescription: error.message!));
    }
  }

  void manageUpiAccounts({
    required String? customerMobile,
    String? color,
    required OnFailure<Error> onFailure,
  }) async {
    try {
      if (!_isTurboPluginAvailable) {
        _emitFailure(onFailure);
        return;
      }

      var requestManageUpiAccounts = <String, dynamic>{
        "customerMobile": customerMobile,
        "color": color,
      };

      await _channel.invokeMethod(
        'manageUpiAccounts',
        requestManageUpiAccounts,
      );
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
    onFailure(
      Error(
        errorCode: "AXIS_SDK_ERROR",
        errorDescription: "No Turbo Plugin Found",
      ),
    );
  }
}
