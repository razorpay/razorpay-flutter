import 'package:flutter/material.dart';
import 'package:razorpay_turbo_standard/model/upi_account.dart';
import 'package:razorpay_turbo_standard/razorpay_turbo_standard.dart';
import 'package:razorpay_turbo_standard/model/Error.dart';
import 'package:flutter/cupertino.dart';
import 'location_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController keyController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  // TPV Key - rzp_test_5sHeuuremkiApj
  //Non-TPV key - rzp_test_0wFRWIZnH65uny
  //Checkout key - rzp_live_ILgsfZCZoFIKMb
  String merchantKeyValue = "rzp_test_0wFRWIZnH65uny";
  String amountValue = "100";
  String orderIdValue = "";
  String mobileNumberValue = "8595371784";
  final LocationService _locationService = LocationService();

  late Razorpay razorpay;

  @override
  void initState() {
    keyController.text = merchantKeyValue;
    amountController.text = amountValue;
    mobileNumberController.text = mobileNumberValue;
    razorpay = Razorpay(merchantKeyValue);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.on(Razorpay.EVENT_FETCH_SESSION_TOKEN, _handleRefreshToken);
    super.initState();
  }

  Future<void> _getLocation() async {
    final status = await _locationService.requestLocationPermission();
    if (status.isGranted) {
    } else {
      // Show dialog or snackbar with status.message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(status.message)));
    }
  }

  //https://api-web-turbo-upi.ext.dev.razorpay.in/v1/upi/turbo/customer/session - UAT
  // https://api.razorpay.com/v1/upi/turbo/customer/session - Prod

  // AUTH (PROD) - cnpwX3Rlc3RfRHQydGdQM3B5eW5sVm86b3FJUFBaM3VwR3MyR2JLWlg3Z3lxYkZL=
  // AUTH (UAT) - cnpwX3Rlc3RfMHdGUldJWm5INjV1bnk6dGhpc2lzc3VwZXJzZWNyZXQ=

  void _handleRefreshToken(dynamic response) async {
    try {
      var url = Uri.parse(
        "https://api-web-turbo-upi.ext.dev.razorpay.in/v1/upi/turbo/customer/session",
      );
      final basicToken =
          'cnpwX3Rlc3RfMHdGUldJWm5INjV1bnk6dGhpc2lzc3VwZXJzZWNyZXQ=';
      final httpResponse = await http.post(
        url,
        headers: {
          "Authorization": "Basic $basicToken",
          "Content-Type": "application/json",
        },
        body: json.encode({'customer_reference': mobileNumberValue}),
      );
      print('Token Response ${httpResponse.body}');
      final responseJson = json.decode(httpResponse.body);

      // Null safety check
      final token = responseJson['token'] as String?;
      if (token != null && token.isNotEmpty) {
        razorpay.upiTurbo.updateSessionToken(token: token);
        print('Session token updated successfully');
      } else {
        print('Error: Token not found in response: $responseJson');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get session token')),
        );
      }
    } catch (e) {
      print('Error in _handleRefreshToken: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session token error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              RZPEditText(
                controller: keyController,
                textInputType: TextInputType.text,
                hintText: 'Enter Key',
                labelText: 'Merchant Key',
              ),
              RZPEditText(
                controller: amountController,
                textInputType: TextInputType.number,
                hintText: 'Enter Amount',
                labelText: 'Amount',
              ),
              RZPEditText(
                controller: orderIdController,
                textInputType: TextInputType.text,
                hintText: 'Enter Order Id',
                labelText: 'Order Id',
              ),
              RZPEditText(
                controller: mobileNumberController,
                textInputType: TextInputType.number,
                hintText: 'Enter Mobile Number',
                labelText: 'Mobile Number',
              ),
              Container(
                margin: EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
                child: Text(
                  '* Note - In case of TPV the orderId is mandatory.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Expanded(
                  //   child: RZPButton(
                  //     widthSize: 200.0,
                  //     onPressed: () {
                  //       merchantKeyValue = keyController.text;
                  //       amountValue = amountController.text;

                  //       razorpay.open(getPaymentOptions());
                  //     },
                  //     labelText: 'Standard Checkout Pay',
                  //   ),
                  // ),
                  Expanded(
                    child: RZPButton(
                      widthSize: 200.0,
                      onPressed: () {
                        merchantKeyValue = keyController.text;
                        amountValue = amountController.text;
                        mobileNumberValue = mobileNumberController.text;
                        orderIdValue = orderIdController.text;

                        razorpay.on(
                          Razorpay.EVENT_PAYMENT_ERROR,
                          handlePaymentErrorResponse,
                        );
                        razorpay.on(
                          Razorpay.EVENT_PAYMENT_SUCCESS,
                          handlePaymentSuccessResponse,
                        );
                        razorpay.on(
                          Razorpay.EVENT_EXTERNAL_WALLET,
                          handleExternalWalletSelected,
                        );

                        _getLocation();
                        razorpay.open(getTurboPaymentOptions());
                      },
                      labelText: 'Turbo Pay',
                    ),
                  ),
                ],
              ),
              RZPEditText(
                controller: mobileNumberController,
                textInputType: TextInputType.number,
                hintText: 'Enter Mobile Number',
                labelText: 'Mobile Number',
              ),
              RZPButton(
                widthSize: 200.0,
                labelText: "Link New Upi Account",
                onPressed: () {
                  mobileNumberValue = mobileNumberController.text;

                  razorpay.upiTurbo.linkNewUpiAccount(
                    customerMobile: mobileNumberValue,
                    color: "#0CA72F",
                    onSuccess: (List<UpiAccount> upiAccounts) {
                      print(
                        "Successfully Onboarded Account : ${upiAccounts.length}",
                      );
                    },
                    onFailure: (Error error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error : ${error.errorDescription}"),
                        ),
                      );
                    },
                  );
                },
              ),
              RZPButton(
                widthSize: 200.0,
                labelText: "Manage Upi Account",
                onPressed: () {
                  mobileNumberValue = mobileNumberController.text;

                  razorpay.upiTurbo.manageUpiAccounts(
                    customerMobile: mobileNumberValue,
                    color: "#0CA72F",
                    onFailure: (Error error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error : ${error.errorDescription}"),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Object> getPaymentOptions() {
    return {
      'key': '$merchantKeyValue',
      'amount': int.parse(amountValue),
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': '$mobileNumberValue',
        'email': 'test@razorpay.com',
      },
      'external': {
        'wallets': ['paytm'],
      },
    };
  }

  Map<String, Object> getTurboPaymentOptions() {
    return {
      'amount': int.parse(amountValue),
      'currency': 'INR',
      'prefill': {
        'contact': '$mobileNumberValue',
        'email': 'test@razorpay.com',
      },
      'upi': {'flow': 'in_app'},
      'method': 'upi',
      'send_sms_hash': true,
      'theme': {'color': '#0CA72F'},
      'key': '$merchantKeyValue',
      // 'disable_redesign_v15': false,
      'image':
          'https://spaceplace.nasa.gov/templates/featured/sun/sunburn300.png',
      //
      'ep':
          "https://api-web-turbo-upi.ext.dev.razorpay.in/v1/checkout/public?traffic_env=production&build=ba52c7510ea150775eb16f477f02e226c8723851&force_checkout_v2=1&platform=android",
      // 'experiments.upi_turbo': true,
      // "environment_url":
      // "https://api-web-turbo-upi.ext.dev.razorpay.in/v1/checkout/public?traffic_env=production&build=ba52c7510ea150775eb16f477f02e226c8723851&force_checkout_v2=1&platform=ios",
      // 'external': {
      //   'wallets': ['paytm']
      // }
    };
  }

  //Handle Payment Responses

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    /** PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    **/
    showAlertDialog(
      context,
      "Payment Failed",
      "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}",
    );
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /** Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    **/
    showAlertDialog(
      context,
      "Payment Successful",
      "Payment ID: ${response.paymentId}",
    );
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
      context,
      "External Wallet Selected",
      "${response.walletName}",
    );
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(title: Text(title), content: Text(message));
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class RZPButton extends StatelessWidget {
  String labelText;
  VoidCallback onPressed;
  double widthSize = 100.0;

  RZPButton({
    required this.widthSize,
    required this.labelText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthSize,
      height: 50.0,
      margin: EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 12.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(labelText, style: TextStyle(color: Colors.white)),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.indigoAccent),
        ),
      ),
    );
  }
}

class RZPEditText extends StatelessWidget {
  String hintText;
  String labelText;
  TextInputType textInputType;
  TextEditingController controller;

  RZPEditText({
    required this.textInputType,
    required this.hintText,
    required this.labelText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12.0),
      padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
      decoration: BoxDecoration(border: Border.all()),
      child: TextField(
        controller: controller,
        keyboardType: textInputType,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          labelText: labelText,
        ),
      ),
    );
  }
}
