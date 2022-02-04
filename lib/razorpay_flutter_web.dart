import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/services.dart';

class RazorpayFlutterPlugin{

  // Response codes from platform
  static const _CODE_PAYMENT_SUCCESS = 0;
  static const _CODE_PAYMENT_ERROR = 1;
  static const _CODE_PAYMENT_EXTERNAL_WALLET = 2;

  // Payment error codes
  static const NETWORK_ERROR = 0;
  static const INVALID_OPTIONS = 1;
  static const PAYMENT_CANCELLED = 2;
  static const TLS_ERROR = 3;
  static const INCOMPATIBLE_PLUGIN = 4;
  static const UNKNOWN_ERROR = 100;
  static const BASE_REQUEST_ERROR = 5;

  static void registerWith(Registrar registrar){
    final MethodChannel methodChannel = MethodChannel('razorpay_flutter', StandardMethodCodec(), registrar.messenger);
    final RazorpayFlutterPlugin instance = RazorpayFlutterPlugin();
    methodChannel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<Map<dynamic, dynamic>> handleMethodCall(MethodCall call) async{
    switch(call.method){
      case 'open':
        return await startPayment(call.arguments);
      case 'resync':
      default:
        var defaultMap = {'status':'Not implemented on web'};

        return defaultMap;
    }
  }

  Future<Map<dynamic, dynamic>> startPayment(Map<dynamic, dynamic> options) async{
    //required for sending value after the data has been populated
    var completer = new Completer<Map<dynamic,dynamic>>();

    var returnMap = new Map<dynamic, dynamic>(); // main map object
    var dataMap = new Map<dynamic, dynamic>();// return map object

    var razorpay;
    options['handler']=(response)=>{
      returnMap['type'] = _CODE_PAYMENT_SUCCESS,
      dataMap['razorpay_payment_id'] = response['razorpay_payment_id'],
      dataMap['razorpay_order_id'] = response['razorpay_order_id'],
      dataMap['razorpay_signature'] = response['razorpay_signature'],
      returnMap['data'] = dataMap,
      completer.complete(returnMap)
    };
    options['modal.ondismiss']=()=>{
      if(!completer.isCompleted){
        returnMap['type'] = _CODE_PAYMENT_ERROR,
        dataMap['code'] = PAYMENT_CANCELLED,
        dataMap['message'] = 'Payment processing cancelled by user',
        returnMap['data'] = dataMap,
        completer.complete(returnMap)
      }

    };
    var retryCount = 0;
    var jsObjOptions = js.JsObject.jsify(options);
    if(jsObjOptions.hasProperty('retry')){
      if(jsObjOptions['retry']['enabled'] == true){
        retryCount = jsObjOptions['retry']['max_count'];
        options['retry']=true;
      }else{
        options['retry'] = false;
      }
    }else{
      options['retry'] = false;
    }

    var rjs = html.document.getElementsByTagName('script')[0];
    var rzpjs = html.document.createElement('script');
    rzpjs.id = 'rzp-jssdk';
    rzpjs.setAttribute('src','https://checkout.razorpay.com/v1/checkout.js');
    rjs.parentNode?.insertBefore(rzpjs,rjs);
    rzpjs.addEventListener('load', (event) => {
      razorpay = js.JsObject.fromBrowserObject(js.context.callMethod('Razorpay',[js.JsObject.jsify(options)])),
      razorpay.callMethod('on',['payment.failed', (response){
        returnMap['type'] = _CODE_PAYMENT_ERROR;
        dataMap['code'] = BASE_REQUEST_ERROR;
        dataMap['message'] = response['error']['description'];
        var metadataMap = new Map<dynamic, dynamic>();
        metadataMap['payment_id']= response['error']['metadata']['payment_id'];
        dataMap['metadata'] = metadataMap;
        dataMap['source'] = response['error']['source'];
        dataMap['step'] = response['error']['step'];
        returnMap['data'] = dataMap;
        completer.complete(returnMap);
      }]),
      razorpay.callMethod('open')
    });
    return completer.future;
  }

}
