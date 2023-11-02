import 'package:flutter/services.dart';
import 'package:razorpay_flutter/upi_turbo.dart';

class CheckOut{
  late UpiTurbo upiTurbo;
  static const MethodChannel _channel = const MethodChannel('razorpay_flutter');
  CheckOut(String keyId){
    _setKeyID(keyId);
    upiTurbo = new UpiTurbo( _channel);
  }

  void _setKeyID(String keyID) async {
     await _channel.invokeMethod('setKeyID', keyID);
  }

}