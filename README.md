# Razorpay Flutter

Flutter plugin for Razorpay SDK.

[![pub package](https://img.shields.io/pub/v/razorpay_flutter.svg)](https://pub.dartlang.org/packages/razorpay_flutter)

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [API](#api)
- [Example App](https://github.com/razorpay/razorpay-flutter/tree/master/example)

## Getting Started

This flutter plugin is a wrapper around our Android and iOS SDKs.

The following documentation is only focused on the wrapper around our native Android and iOS SDKs. To know more about our SDKs and how to link them within the projects, refer to the following documentation:

**Android**: [https://razorpay.com/docs/checkout/android/](https://razorpay.com/docs/checkout/android/)

**iOS**: [https://razorpay.com/docs/ios/](https://razorpay.com/docs/ios/)

To know more about Razorpay payment flow and steps involved, read up here: [https://razorpay.com/docs/](https://razorpay.com/docs/)

## Prerequisites

- Learn about the <a href="https://razorpay.com/docs/payment-gateway/payment-flow/" target="_blank">Razorpay Payment Flow</a>.
- Sign up for a <a href="https://dashboard.razorpay.com/#/access/signin">Razorpay Account</a> and generate the <a href="https://razorpay.com/docs/payment-gateway/dashboard-guide/settings/#api-keys/" target="_blank">API Keys</a> from the Razorpay Dashboard. Using the Test keys helps simulate a sandbox environment. No actual monetary transaction happens when using the Test keys. Use Live keys once you have thoroughly tested the application and are ready to go live.

## Installation

This plugin is available on Pub: [https://pub.dev/packages/razorpay_flutter](https://pub.dev/packages/razorpay_flutter)

Add this to `dependencies` in your app's `pubspec.yaml`

```yaml
razorpay_flutter: ^1.3.0
```

**Note for Android**: Make sure that the minimum API level for your app is 19 or higher.

### Proguard rules

If you are using proguard for your builds, you need to add following lines to proguard files

```
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}
```

Follow [this](https://github.com/razorpay/razorpay-flutter/issues/42#issuecomment-550161626) for more details.

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

## Troubleshooting

### Enabling Bitcode

Open `ios/Podfile` and find this section:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

Set `config.build_settings['ENABLE_BITCODE'] = 'YES'`.

### Setting Swift version

Add the following line below `config.build_settings['ENABLE_BITCODE'] = 'YES'`:

`config.build_settings['SWIFT_VERSION'] = '5.0'`

### `CocoaPods could not find compatible versions for pod "razorpay_flutter"` when running `pod install`

```
Specs satisfying the `razorpay_flutter (from
    `.symlinks/plugins/razorpay_flutter/ios`)` dependency were found, but they
    required a higher minimum deployment target.
```

This is due to your minimum deployment target being less than iOS 10.0. To change this, open `ios/Podfile` in your project and add/uncomment this line at the top:

```ruby
# platform :ios, '9.0'
```

and change it to

```ruby
platform :ios, '10.0'
```

and run `pod install` again in the `ios` directory.

### iOS build fails with `'razorpay_flutter/razorpay_flutter-Swift.h' file not found`

Add use_frameworks! in `ios/Podfile` and run `pod install` again in the `ios` directory.

### Gradle build fails with `Error: uses-sdk:minSdkVersion 16 cannot be smaller than version 19 declared in library [:razorpay_flutter]`

This is due to your Android minimum SDK version being less than 19. To change this, open `android/app/build.gradle`, find `minSdkVersion` in `defaultConfig` and set it to at least `19`.

### A lot of errors saying `xxxx is not defined for the class 'Razorpay'`

We export a class `Razorpay` from `package:razorpay_flutter/razorpay_flutter.dart`. Check if your code is redeclaring the `Razorpay` class.

### Type 'xxxx' is not a subtype of type 'xxxx' of 'response' in `Razorpay.on.<anonymous closure>`

```
[VERBOSE-2:ui_dart_state.cc(148)] Unhandled Exception: type 'PaymentFailureResponse' is not a subtype of type 'PaymentSuccessResponse' of 'response'
#0      Razorpay.on.<anonymous closure> (package:razorpay_flutter/razorpay_flutter.dart:87:14)
#1      EventEmitter.emit.<anonymous closure> (package:eventify/src/event_emitter.dart:94:14)
#2      List.forEach (dart:core-patch/growable_array.dart:278:8)
#3      EventEmitter.emit (package:eventify/src/event_emitter.dart:90:15)
#4      Razorpay._handleResult (package:razorpay_flutter/razorpay_flutter.dart:81:19)
#5      Razorpay.open (package:razorpay_flutter/razorpay_flutter.dart:49:5)
```

Check the signatures of the callbacks for payment events. They should match the ones described [here](#onstring-eventname-function-listener).

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

| Field Name | Type   | Description                               |
| ---------- | ------ | ----------------------------------------- |
| walletName | String | The name of the external wallet selected. |
