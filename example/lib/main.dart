import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  static const platform = const MethodChannel("razorpay_flutter");

  RazorpayFlutter _razorpayFlutter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Razorpay Sample App'),
        ),
        body: Center(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(onPressed: openCheckout, child: Text('Open'))
          ]
          )
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _razorpayFlutter = new RazorpayFlutter();
    _razorpayFlutter.on('payment.success', _handlePaymentSuccess);
    _razorpayFlutter.on('payment.error', _handlePaymentError);
    _razorpayFlutter.on('payment.external_wallet', _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpayFlutter.clear();
  }

  void openCheckout() async {

    Map<String, dynamic> options = new Map();

    options['key'] = 'rzp_live_ILgsfZCZoFIKMb';
    options['amount'] = 100;
    options['name'] = 'Acme Corp';
    options['description'] = 'Fine T-shirt';

    options['prefill'] = new Map();
    options['prefill']['contact'] = '8888888888';
    options['prefill']['email'] = 'test@razorpay.com';

    options['external'] = new Map();
    options['external']['wallets'] = ['paytm'];

    try {
      _razorpayFlutter.open(options);
    } catch (e) {
      debugPrint(e);
    }

  }

  void _handlePaymentSuccess(String event, Map result) {
    Fluttertoast.showToast(msg: "SUCCESS: " + result.toString(), timeInSecForIos: 4);
  }

  void _handlePaymentError(String event, Map result) {
    Fluttertoast.showToast(msg: "ERROR: " + result.toString(), timeInSecForIos: 4);
  }

  void _handleExternalWallet(String event, Map result) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + result.toString(), timeInSecForIos: 4);
  }

}
