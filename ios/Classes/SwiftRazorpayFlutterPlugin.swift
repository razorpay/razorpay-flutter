import Flutter
import Razorpay
import UIKit

public class SwiftRazorpayFlutterPlugin: NSObject, FlutterPlugin {

    private var razorpayDelegate = RazorpayDelegate()
    private static let CHANNEL_NAME = "razorpay_flutter"
    private static let MERCHANT_EVENT_CHANNEL_NAME = "razorpay_flutter/merchant_events"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftRazorpayFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let merchantEventChannel = FlutterEventChannel(name: MERCHANT_EVENT_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        merchantEventChannel.setStreamHandler(instance)
    }

    /// Returns the root view controller so the SDK can present checkout. Prefers scene-based API (iOS 13+).
    private static func rootViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                if let vc = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                    return vc
                }
                if let vc = windowScene.windows.first?.rootViewController {
                    return vc
                }
            }
        }
        return UIApplication.shared.keyWindow?.rootViewController
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "open":
            let options = call.arguments as! Dictionary<String, Any>
            let viewController = Self.rootViewController()
            razorpayDelegate.open(options: options, result: result, from: viewController)
        case "resync":
            razorpayDelegate.resync(result: result)
        case "subscribeToAnalyticsEvents":
            let args = call.arguments as? [String: Any]
            let events = (args?["events"] as? [String]) ?? []
            razorpayDelegate.subscribeToAnalyticsEvents(events: events)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension SwiftRazorpayFlutterPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        razorpayDelegate.merchantEventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        razorpayDelegate.merchantEventSink = nil
        return nil
    }
}
