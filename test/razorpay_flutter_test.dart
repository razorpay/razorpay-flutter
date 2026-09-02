import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Regression tests for: type 'String' is not a subtype of type 'Map<dynamic, dynamic>?'
  // When the native layer (Android/iOS) sends a plain-text error string instead of a
  // structured JSON object (e.g. FPX cancellation, UPI Turbo errors), the hard cast in
  // PaymentFailureResponse.fromMap() crashes before onPaymentError fires.
  group("PaymentFailureResponse", () {
    group("#fromMap", () {
      test('parses correctly when responseBody is a Map (happy path)', () {
        final map = {
          'code': 2,
          'message': 'Payment cancelled',
          'responseBody': {
            'code': 'BAD_REQUEST_ERROR',
            'description': 'Payment cancelled by user',
            'source': 'customer',
            'step': 'payment_authentication',
            'reason': 'payment_cancelled',
            'metadata': {'payment_id': 'pay_abc123', 'order_id': 'order_xyz'},
          }
        };

        final response = PaymentFailureResponse.fromMap(map);

        expect(response.code, equals(2));
        expect(response.message, equals('Payment cancelled'));
        expect(response.error, isA<Map>());
        expect(response.error!['code'], equals('BAD_REQUEST_ERROR'));
      });

      test('does not crash when responseBody is a String (FPX/plain-text error path)', () {
        final map = {
          'code': 2,
          'message': 'Post payment parsing error',
          'responseBody': 'Post payment parsing error',
        };

        expect(() => PaymentFailureResponse.fromMap(map), returnsNormally);

        final response = PaymentFailureResponse.fromMap(map);
        expect(response.code, equals(2));
        expect(response.message, equals('Post payment parsing error'));
        expect(response.error, isNull);
      });

      test('handles absent responseBody gracefully (INVALID_OPTIONS path)', () {
        final map = {
          'code': 1,
          'message': 'Key is required.',
        };

        final response = PaymentFailureResponse.fromMap(map);

        expect(response.code, equals(1));
        expect(response.message, equals('Key is required.'));
        expect(response.error, isNull);
      });
    });
  });

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
        var options = {
          'key': 'rzp_test_1DP5mmOlF5G5aa',
          'amount': 2000,
          'name': 'Acme Corp.',
          'description': 'Fine T-Shirt',
          'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'}
        };

        razorpay.open(options);

        expect(log, <Matcher>[isMethodCall('open', arguments: options)]);
      });

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

      group('with rawMap: true', () {
        test('emits raw map for payment success', () async {
          channel.setMockMethodCallHandler((MethodCall call) async {
            if (call.method == 'resync') {
              return null;
            }
            return {
              'type': 0,
              'data': {
                'razorpay_payment_id': 'pay_123',
                'razorpay_order_id': 'order_456',
              }
            };
          });

          razorpay.clear();

          var successHandler = (Map<dynamic, dynamic> response) {
            expect(response['razorpay_payment_id'], equals('pay_123'));
            expect(response['razorpay_order_id'], equals('order_456'));
          };

          razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
              expectAsync1(successHandler, count: 1),
              rawMap: true);

          razorpay.open({'key': 'rzp_test_xxx'});
        });

        test('emits raw map for payment error', () async {
          channel.setMockMethodCallHandler((MethodCall call) async {
            if (call.method == 'resync') {
              return null;
            }
            return {
              'type': 1,
              'data': {
                'code': Razorpay.NETWORK_ERROR,
                'message': 'Network error',
              }
            };
          });

          razorpay.clear();

          var errorHandler = (Map<dynamic, dynamic> response) {
            expect(response['code'], equals(Razorpay.NETWORK_ERROR));
            expect(response['message'], equals('Network error'));
          };

          razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
              expectAsync1(errorHandler, count: 1),
              rawMap: true);

          razorpay.open({'key': 'rzp_test_xxx'});
        });

        test('emits raw map for external wallet', () async {
          channel.setMockMethodCallHandler((MethodCall call) async {
            if (call.method == 'resync') {
              return null;
            }
            return {
              'type': 2,
              'data': {'external_wallet': 'paytm'}
            };
          });

          razorpay.clear();

          var walletHandler = (Map<dynamic, dynamic> response) {
            expect(response['external_wallet'], equals('paytm'));
          };

          razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
              expectAsync1(walletHandler, count: 1),
              rawMap: true);

          razorpay.open({'key': 'rzp_test_xxx'});
        });
      });
    });
  });
}
