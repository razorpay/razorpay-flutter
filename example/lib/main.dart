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
      title: 'Razorpay FPX Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Razorpay _razorpay;
  final _keyController = TextEditingController();
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _keyController.dispose();
    super.dispose();
  }

  void _log(String msg) {
    setState(() => _logs.insert(0, '[${DateTime.now().toIso8601String().substring(11, 19)}] $msg'));
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    _log('SUCCESS — payment_id: ${response.paymentId}');
    _showDialog('Payment Success', 'Payment ID: ${response.paymentId}');
  }

  void _handleError(PaymentFailureResponse response) {
    _log('ERROR — code: ${response.code}, msg: ${response.message}, error: ${response.error}');
    _showDialog('Payment Failed', 'Code: ${response.code}\nMessage: ${response.message}\nError: ${response.error}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _log('EXTERNAL WALLET — ${response.walletName}');
    _showDialog('External Wallet', '${response.walletName}');
  }

  void _openCheckout() {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      _showDialog('Error', 'Please enter a Razorpay key first.');
      return;
    }
    _log('Opening checkout with key: ${key.substring(0, key.length.clamp(0, 12))}...');
    var options = {
      'key': key,
      'amount': 100,
      'name': 'FPX Crash Test',
      'description': 'Testing FPX cancellation crash',
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      _log('EXCEPTION: $e');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Razorpay FPX Crash Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Razorpay Key (rzp_test_... or rzp_live_...)',
                border: OutlineInputBorder(),
              ),
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _openCheckout,
              child: const Text('Open Checkout (test FPX cancellation)'),
            ),
            const SizedBox(height: 16),
            const Text('Event Log:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _logs.isEmpty
                  ? const Center(child: Text('No events yet.\nEnter key, tap button, choose FPX, then cancel on the bank page.', textAlign: TextAlign.center))
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (_, i) => Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SelectableText(
                            _logs[i],
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
