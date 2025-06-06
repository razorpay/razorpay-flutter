import Flutter
import Razorpay

public class SwiftRazorpayFlutterPlugin: NSObject, FlutterPlugin {
    
    private var razorpayDelegate = RazorpayDelegate()
    private static var CHANNEL_NAME = "razorpay_flutter";
    private var eventSink: FlutterEventSink!
    
    private static var TURBO_CHANNEL_NAME = "razorpay_turbo_with_turbo_upi"
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftRazorpayFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: TURBO_CHANNEL_NAME, binaryMessenger: registrar.messenger()) // timeHandlerEvent is event name
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "open":
            let options = call.arguments as! Dictionary<String, Any>
            razorpayDelegate.open(options: options, result: result);
            break
        case "resync":
            razorpayDelegate.resync(result: result)
            break
        case "initialize":
            if let key = call.arguments as? String {
                razorpayDelegate.initilizeSDK(withKey: key, result: result)
            }
            break
        case "isTurboPluginAvailable":
            razorpayDelegate.isTurboPluginAvailable(result: result,eventSink: self.eventSink);
            break
        case "linkNewUpiAccount":
            if let args = call.arguments as? [String: Any] {
                let customerMobile = args["customerMobile"] as? String ?? ""
                let color = args["color"] as? String ?? ""
                razorpayDelegate.linkNewUpiAccount(mobileNumber: customerMobile, color: color, result: result, eventSink: self.eventSink)
            }
        case "manageUpiAccounts":
            if let args = call.arguments as? [String: Any] {
                let customerMobile = args["customerMobile"] as? String ?? ""
                let color = args["color"] as? String ?? ""
                razorpayDelegate.manageAccount(customerMobile: customerMobile, color: color, result: result, eventSink: self.eventSink)
            }
            break
        case "refreshSessionToken":
            if let newToken = call.arguments as? String {
                razorpayDelegate.updateToken(token: newToken)
            }
        default:
            print("no method")
        }
    }
    
}

extension SwiftRazorpayFlutterPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        print("onListen......")
        self.eventSink = eventSink
        return nil
    }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
