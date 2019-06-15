# Razorpay Flutter

Flutter plugin for Razorpay SDK.

## Getting Started

This flutter plugin is a wrapper around our Android and iOS SDKs.

The following documentation is only focused on the wrapper around our native Android and iOS SDKs. To know more about our SDKs and how to link them within the projects, refer to the following documentation:

**Android**: [https://razorpay.com/docs/checkout/android/](https://razorpay.com/docs/checkout/android/)

**iOS**: [https://razorpay.com/docs/ios/](https://razorpay.com/docs/ios/)

To know more about Razorpay payment flow and steps involved, read up here: [https://razorpay.com/docs/](https://razorpay.com/docs/)

## Installation

This plugin is available on Pub: [https://pub.dev/packages/razorpay_flutter](https://pub.dev/packages/razorpay_flutter)

Add this to `dependencies` in your app's `pubspec.yml`

```yaml
razorpay_flutter: 1.1.0
```

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

To clear event listeners, use the `clear` method on the `Razorpay` instance.

```dart
_razorpay.clear(); // Removes all listeners
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
  }
};
```

A detailed list of options can be found [here](https://razorpay.com/docs/payment-gateway/integrations-guide/checkout/standard/#checkout-form).

#### Open Checkout

```dart
_razorpay.open(options);
```

## API

### Razorpay

#### open(map<String, dynamic> options)

Open Razorpay Checkout. 

The `options` map has `key` as a required property. All other properties are optional. 
For a complete list of options, please see [the Checkout documentation](https://razorpay.com/docs/payment-gateway/integrations-guide/checkout/standard/#checkout-form).

#### on(String eventName, Function listener)

Register event listeners for payment events.

- `eventName`: The name of the event.
- `listener`: The function to be called. The listener should accept a single argument of the following type:
  - [`PaymentSuccessResponse`](#paymentsuccessresponse) for `EVENT_PAYMENT_SUCCESS`
  - [`PaymentFailureResponse`](#paymentfailureresponse) for `EVENT_PAYMENT_FAILURE`
  - [`ExternalWalletResponse`](#externalwalletresponse) for `EVENT_EXTERNAL_WALLET`

#### clear()

Clear all event listeners.

#### Error Codes

The error codes have been exposed as integers by the `Razorpay` class.

The error code is available as the `code` field of the `PaymentFailureResponse` instance passed to the callback.


| Error Code        | Description                                                          |
| ----------------- | -------------------------------------------------------------------- |
| NETWORK_ERROR     | There was a network error, for example loss of internet connectivity |
| INVALID_OPTIONS   | An issue with options passed in `Razorpay.open`                      |
| PAYMENT_CANCELLED | User cancelled the payment                                           |
| TLS_ERROR         | Device does not support TLS v1.1 or TLS v1.2                         |
| UNKNOWN_ERROR     | An unknown error occurred.                                           |

#### Event names

The event names have also been exposed as Strings by the `Razorpay` class.

| Event Name            | Description                      |
| --------------------- | -------------------------------- |
| EVENT_PAYMENT_SUCCESS | The payment was successful.      |
| EVENT_PAYMENT_ERROR   | The payment was not successful.  |
| EVENT_EXTERNAL_WALLET | An external wallet was selected. |

### PaymentSuccessResponse

| Field Name | Type   | Description                                                                                  |
| ---------- | ------ | -------------------------------------------------------------------------------------------- |
| paymentId  | String | The ID for the payment.                                                                      |
| orderId    | String | The order ID if the payment was for an order, `null` otherwise.                              |
| signature  | String | The signature to be used for payment verification. (Only valid for orders, `null` otherwise) |

### PaymentFailureResponse

| Field Name | Type   | Description        |
| ---------- | ------ | ------------------ |
| code       | int    | The error code.    |
| message    | String | The error message. |

### ExternalWalletResponse

| Field Name  | Type    | Description                               |
| ----------- | ------- | ----------------------------------------- |
| walletName  | String  | The name of the external wallet selected. |

