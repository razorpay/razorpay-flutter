import Flutter
import Razorpay

@objc(RazorpayFlutterPlugin)
public class RazorpayFlutterPlugin: NSObject, FlutterPlugin {

    private var razorpayDelegate = RazorpayDelegate()
    private static let channelName = "razorpay_flutter"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = RazorpayFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "open":
            let options = call.arguments as! Dictionary<String, Any>
            razorpayDelegate.open(options: options, result: result)
        case "resync":
            razorpayDelegate.resync(result: result)
        default:
            print("no method")
        }
    }
}
