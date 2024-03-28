import 'package:flutter/material.dart';
import 'package:razorpay_flutter/model/upi_account.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpay_flutter/model/error.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Razorpay Flutter Sample App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/*class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  // TPV Key - rzp_test_5sHeuuremkiApj
  //Non-TPV key - rzp_test_0wFRWIZnH65uny
  String keyId = "rzp_test_5sHeuuremkiApj";
  String mobileNumber="";
  late CheckOut checkOut ;

  @override
  void initState() {
    checkOut = CheckOut(keyId);
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razorpay Flutter Sample App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Pay with Razorpay'),
            ElevatedButton(
              onPressed: () {
                Razorpay razorpay = Razorpay();
                var options = {
                  'key': 'rzp_live_ILgsfZCZoFIKMb',
                  'amount': 100,
                  'name': 'Acme Corp.',
                  'description': 'Fine T-Shirt',
                  'retry': {'enabled': true, 'max_count': 1},
                  'send_sms_hash': true,
                  'prefill': {
                    'contact': '8888888888',
                    'email': 'test@razorpay.com',
                  },
                  'external': {
                    'wallets': ['paytm'],
                  },
                };
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
                razorpay.open(options);
              },
              child: const Text('Pay with Razorpay'),
            ),
            ElevatedButton(onPressed: (){
                  Razorpay razorpay = Razorpay();
                   var options = {
                    'key': 'rzp_live_ILgsfZCZoFIKMb',
                    'amount': 100,
                    'name': 'Acme Corp.',
                    'description': 'Fine T-Shirt',
                    'retry': {'enabled': true, 'max_count': 1},
                    'send_sms_hash': true,
                    'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
                    'external': {
                      'wallets': ['paytm']
                    }
                  };
                  var options = {
                    'amount': 10000,
                    'currency': 'INR',
                    'prefill':{
                      'contact':'9877597717',
                      'email':'pshibu567@gmail.com'
                    },
                    'theme':{
                      'color':'#0CA72F'
                    },
                    'send_sms_hash':true,
                    'retry':{
                      'enabled':false,
                      'max_count':4
                    },
                    'key': 'rzp_test_5sHeuuremkiApj',
                    'order_id':'order_N0fmkHxFIp7wQh',
                    'disable_redesign_v15': false,
                    'experiments.upi_turbo':true,
                    'ep':'https://api-web-turbo-upi.ext.dev.razorpay.in/test/checkout.html?branch=feat/turbo/tpv'
                  };
                  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
                  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
                  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
                  razorpay.open(options);
                },
                child: const Text("Pay with Razorpay")),

            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child:  TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                  ),
                  onChanged: (newValue) => mobileNumber = newValue,
              ),
            ),
            ElevatedButton(onPressed: (){
             checkOut.upiTurbo.linkNewUpiAccount(customerMobile: mobileNumber,
                 color: "#ffffff",
                 onSuccess: (List<UpiAccount> upiAccounts) {
                    print("Successfully Onboarded Account : ${upiAccounts.length}");
                 },
               onFailure:(Error error) { ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text("Error : ${error.errorDescription}")));}
                );
            }, child: const Text("Pay with Turbo UPI")),

            SizedBox(height: 8,),

            ElevatedButton(onPressed: (){
              checkOut.upiTurbo.manageUpiAccounts(customerMobile: mobileNumber,
                  color: "#ffffff",
                  onFailure:(Error error) { ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error : ${error.errorDescription}")));}
              );
            }, child: const Text("ManageUpiAccounts")),

          ],
        ),
      ),
    );
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response){

    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    *
    showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response){

    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    *
    showAlertDialog(context, "Payment Successful", "Payment ID: ${response.paymentId}");
  }

  void handleExternalWalletSelected(ExternalWalletResponse response){
    showAlertDialog(context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message){
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed:  () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}*/

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController keyController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  // TPV Key - rzp_test_5sHeuuremkiApj
  //Non-TPV key - rzp_test_0wFRWIZnH65uny
  //Checkout key - rzp_live_ILgsfZCZoFIKMb
  String merchantKeyValue = "rzp_live_ILgsfZCZoFIKMb";
  String amountValue = "100";
  String orderIdValue = "";
  String mobileNumberValue = "8888888888";

  late Razorpay razorpay;

  @override
  void initState() {
    razorpay = Razorpay("rzp_test_qRGYYA5wZrpFvJ").initUpiTurbo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razorpay Flutter Sample App'),
      ),
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
                margin: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 0),
                child: const Text(
                  '* Note - In case of TPV the orderId is mandatory.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: RZPButton(
                      widthSize: 200.0,
                      onPressed: () {
                        merchantKeyValue = keyController.text;
                        amountValue = amountController.text;

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
                        razorpay.open(getPaymentOptions());
                      },
                      labelText: 'Standard Checkout Pay',
                    ),
                  ),
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
                    color: "#ffffff",
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
                    color: "#ffffff",
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
      'key': merchantKeyValue,
      'amount': int.parse(amountValue),
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': mobileNumberValue,
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
        'contact': mobileNumberValue,
        'email': 'test@razorpay.com',
      },
      'theme': {
        'color': '#0CA72F',
      },
      'send_sms_hash': true,
      'retry': {
        'enabled': false,
        'max_count': 4,
      },
      'key': merchantKeyValue,
      'order_id': orderIdValue,
      'disable_redesign_v15': false,
      'experiments.upi_turbo': true,
      'ep':
          'https://api-web-turbo-upi.ext.dev.razorpay.in/test/checkout.html?branch=feat/turbo/tpv',
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
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
  }
}

class RZPButton extends StatelessWidget {
  String labelText;
  VoidCallback onPressed;
  double widthSize = 100.0;

  RZPButton({
    super.key,
    required this.widthSize,
    required this.labelText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthSize,
      height: 50.0,
      margin: const EdgeInsets.fromLTRB(12.0, 8.0, 8.0, 12.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.indigoAccent),
        ),
        child: Text(
          labelText,
          style: const TextStyle(
            color: Colors.white,
          ),
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
    super.key,
    required this.textInputType,
    required this.hintText,
    required this.labelText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: TextField(
        controller: controller,
        keyboardType: textInputType,
        style: const TextStyle(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          labelText: labelText,
        ),
      ),
    );
  }
}
