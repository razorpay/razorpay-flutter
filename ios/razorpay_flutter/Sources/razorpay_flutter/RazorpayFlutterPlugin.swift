import Flutter

/// Swift Package Manager entry point.
///
/// Flutter's generated registrant calls `[RazorpayFlutterPlugin registerWithRegistrar:]`, the
/// `pluginClass` from pubspec.yaml. Under CocoaPods that class is the Objective-C shim in
/// `ios/Classes`, which forwards to `SwiftRazorpayFlutterPlugin`. SwiftPM targets cannot mix
/// Objective-C and Swift, so this package instead exposes the same name as a subclass of the
/// shared Swift implementation. This file exists only in the SwiftPM package; the shared sources
/// next to it are symlinks into `ios/Classes`, so CocoaPods is unaffected.
@objc(RazorpayFlutterPlugin)
public final class RazorpayFlutterPlugin: SwiftRazorpayFlutterPlugin {}
