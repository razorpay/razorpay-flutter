# razorpay_flutter

Flutter plugin for Razorpay SDK.

## Getting Started

This flutter plugin is a wrapper around our Android and iOS SDKs.

## Installation

This plugin is available on Pub: <link>

Add this to `dependencies` in your app's `pubspec.yml`

`<package_name>: <version>`

**Note for Android**: Make sure that the minimum API level for your app is 19 or higher.

**Note for iOS**: Make sure that the minimum deployment target for your app is iOS 10.0 or higher. Also, don't forget to enable bitcode for your project.

Run `flutter packages get` in the root directory of your app.

## Usage

Sample code to integrate can be found in [example/lib/main.dart](example/lib/main.dart).

#### Import package 

```dart
import 'package:razorpay_flutter/razorpay_flutter.dart';
```

#### Create Razorpay instance

```dart
_razorpay = Razorpay();
```

#### Attach event listeners

The plugin uses event-based communication, and emits events when payment fails or succeeds.

The event names are exposed via the constants `EVENT_PAYMENT_SUCCESS`, `EVENT_PAYMENT_ERROR` and `EVENT_EXTERNAL_WALLET` from the `Razorpay` class.

Use the `on(String event, Function handler)` method on the `Razorpay` instance to attach event listeners.

```dart

_razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
_razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
_razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
```

The handlers would be defined somewhere as

```dart

void _handlePaymentSuccess(PaymentSuccessResponse response) {
  // Do something when payment succeeds
}

void _handlePaymentError(PaymentFailureResponse response) {
  // Do something when payment fails
}

void _handleExternalWallet(ExternalWalletResponse response) {
  // Do something when an external wallet was selected
}
```

#### Setup options

```dart
var options = {
  'key': '<YOUR_KEY_HERE>',
  'amount': 100,
  'name': 'Acme Corp.',
  'description': 'Fine T-Shirt',
  'prefill': {
    'contact': '8888888888',
    'email': 'test@razorpay.com'
  },
  'external': {
    'wallets': ['paytm']
  }
};
```

A detailed list of options can be found [here](https://razorpay.com/docs/payment-gateway/integrations-guide/checkout/standard/#checkout-form).

#### Open checkout

```dart
_razorpay.open(options);
```

## Caveats
