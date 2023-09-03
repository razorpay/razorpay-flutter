import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0D94FB),
          secondary: Color(0xFF012652),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                  'key': 'rzp_test_KdOUktx4iNXOO6',
                  'amount': 100,
                  'name': 'Acme Corp.',
                  'description': 'Fine T-Shirt',
                  'retry': {'enabled': false, 'max_count': 1},
                  'send_sms_hash': true,
                  'prefill': {
                    'contact': '8888888888',
                    'email': 'test@razorpay.com'
                  },
                  'external': {
                    'wallets': ['paytm']
                  }
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
          ],
        ),
      ),
    );
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    // PaymentFailureResponse contains three values:
    // 1. Error Code
    // 2. Error Description
    // 3. Metadata
    showAlertDialog(
      context,
      'Payment Failed',
      'Code: ${response.code}\n'
          'Description: ${response.message}\n'
          'Metadata: ${response.error.toString()}',
    );
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    // PaymentSuccessResponse contains three values:
    // 1. Order ID
    // 2. Payment ID
    // 3. Signature
    showAlertDialog(
      context,
      'Payment Successful',
      'Payment ID: ${response.paymentId}',
    );
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
      context,
      'External Wallet Selected',
      '${response.walletName}',
    );
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}
