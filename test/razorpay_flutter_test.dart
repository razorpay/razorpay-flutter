import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_flutter/options.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  group("$Razorpay", () {
    const MethodChannel channel = MethodChannel("razorpay_flutter");

    final List<MethodCall> log = <MethodCall>[];

    late Razorpay razorpay;

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall call) async {
        log.add(call);
        return {};
      });

      razorpay = Razorpay();

      log.clear();
    });

    group("#open", () {
      setUp(() {
        razorpay.clear();
      });

      test('passes options correctly', () async {
        var options = CheckoutOptions(
          key: "rzp_test_1DP5mmOlF5G5aa",
          amount: 2000,
          currency: "INR",
          name: "Acme Corp.",
          orderId: "order_EMBFqjDHEEn80l", // Generate order_id using Orders API
          description: "Fine T-Shirt",
          prefill: CheckoutPrefill(
            contact: '8888888888',
            email: 'test@razorpay.com',
          ),
        );

        razorpay.open(options);

        expect(log, <Matcher>[isMethodCall('open', arguments: options)]);
      });

      /* Now user cannot create [CheckoutOptions] object without passing the key */
      /*
        test('throws error if key is not passed', () async {
          var options = {
            'amount': 2000,
            'name': 'Acme Corp.',
            'description': 'Fine T-Shirt',
            'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'}
          };

          var errorHandler = (PaymentFailureResponse response) {
            expect(response.code, equals(Razorpay.INVALID_OPTIONS));
          };

          razorpay.on(
              Razorpay.EVENT_PAYMENT_ERROR, expectAsync1(errorHandler, count: 1));

          razorpay.open(options);
        });
      */
    });
  });
}
