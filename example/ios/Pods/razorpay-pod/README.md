# razorpay-pod

[![Version](https://img.shields.io/cocoapods/v/razorpay-pod.svg?style=flat)](http://cocoapods.org/pods/razorpay-pod)
[![License](https://img.shields.io/cocoapods/l/razorpay-pod.svg?style=flat)](http://cocoapods.org/pods/razorpay-pod)
[![Platform](https://img.shields.io/cocoapods/p/razorpay-pod.svg?style=flat)](http://cocoapods.org/pods/razorpay-pod)
[![SPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)

This repository implements pod for Razorpay's iOS Framework.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation | Docs

### Note:

If your integrating this on Objective-C please replace the line

```
#import <Razorpay/Razorpay.h>
```

with

```
# import <Razorpay/Razorpay-Swift.h> in your viewcontroller.m file
```

razorpay-pod is available through [CocoaPods]. To install
it, simply add the following line to your Podfile

```ruby
pod 'razorpay-pod', '1.2.5'
```

### Note:

for older cocoapod versions check [CHANGELOG](https://github.com/razorpay/razorpay-pod/blob/1.1.12/CHANGELOG.md).

Refer to the documentation from [here](https://razorpay.com/docs/payment-gateway/ios-integration/standard/)

## Swift Package Manager (iOS 13+)

[Swift Package Manager](https://www.swift.org/package-manager/) razorpay-pod is also distributed as Swift Package, follow the below steps for installing the package in your iOS app.

### Installation:

Click File -> Swift Packages -> Add Package Dependency, enter [razorpay-pod repo's URL](https://github.com/razorpay/razorpay-pod). You can also select the dependency rule to select major and minor versions of package and also from a specific branch or commit.

Refer to our documentation [here](https://razorpay.com/docs/payments/payment-gateway/ios-integration/standard/)

## Contributing

See the [CONTRIBUTING] document.
Thank you, [contributors]!

## License

razorpay-pod is free software, and may be redistributed
under the terms specified in the [LICENSE] file.

We :heart: open source software!
See [our other supported plugins / SDKs]
or [contact us](mailto:integrations@razorpay.com?subject=Help with iOS Integration using CocoaPods) to help you with integrations.

[cocoapods]: http://cocoapods.org
[razorpay.com/mobile]: https://razorpay.com/mobile
[contributing]: CONTRIBUTING.md
[contributors]: https://github.com/razorpay/razorpay-pod/graphs/contributors
[license]: /LICENSE
[our other supported plugins / sdks]: https://razorpay.com/integrations "List of our supported integrations"
