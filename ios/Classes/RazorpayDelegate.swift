import Flutter
import Razorpay
import RazorpayCore
import UIKit

public class RazorpayDelegate: NSObject, RazorpayPaymentCompletionProtocolWithData, ExternalWalletSelectionProtocol, RazorpayEventCallback {
    
    static let CODE_PAYMENT_SUCCESS = 0
    static let CODE_PAYMENT_ERROR = 1
    static let CODE_PAYMENT_EXTERNAL_WALLET = 2
    
    static let NETWORK_ERROR = 0
    static let INVALID_OPTIONS = 1
    static let PAYMENT_CANCELLED = 2
    static let TLS_ERROR = 3
    static let INCOMPATIBLE_PLUGIN = 3
    static let UNKNOWN_ERROR = 100
    
    private var paymentCompleted = false
    private weak var presentingViewController: UIViewController?
    private var pendingReply: NSDictionary?
    
    public func onExternalWalletSelected(_ walletName: String, withPaymentData paymentData: [AnyHashable : Any]?) {
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_EXTERNAL_WALLET
        
        var data = [String:Any]()
        data["external_wallet"] = walletName
        response["data"] = data
        
        sendReply(response as NSDictionary)
    }
    
    private var pendingResult: FlutterResult!
    private var subscribedAnalyticsEvents: [String]?
    var merchantEventSink: FlutterEventSink?

    private let logTag = "RazorpayFlutter"

    public func subscribeToAnalyticsEvents(events: [String]) {
        subscribedAnalyticsEvents = events
    }

    public func onEvent(_ payloadJson: String) {
        if !paymentCompleted {
            let lower = payloadJson.lowercased()
            if lower.contains("payment.captured") || lower.contains("payment.authorized") || lower.contains("payment.success") {
                paymentCompleted = true
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let sink = self.merchantEventSink else {
                print("[RazorpayFlutter] Analytics event received but Flutter listener is not connected")
                return
            }
            sink(payloadJson)
        }
    }

    public func onPaymentError(_ code: Int32, description message: String, andData data: [AnyHashable : Any]?) {
        let translatedCode = RazorpayDelegate.translateRzpPaymentError(errorCode: Int(code))
        if translatedCode == RazorpayDelegate.PAYMENT_CANCELLED && paymentCompleted {
            var response = [String:Any]()
            response["type"] = RazorpayDelegate.CODE_PAYMENT_SUCCESS
            response["data"] = data ?? [String:Any]()
            sendReply(response as NSDictionary)
            cleanupPresentation()
            return
        }
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_ERROR
        
        var errorData = [String:Any]()
        errorData["code"] = translatedCode
        errorData["message"] = message 
        errorData["responseBody"] = data
        
        response["data"] = errorData
        paymentCompleted = true
        sendReply(response as NSDictionary)
        cleanupPresentation()
    }
    
    public func onPaymentSuccess(_ payment_id: String, andData data: [AnyHashable: Any]?) {
        paymentCompleted = true
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_SUCCESS
        response["data"] = data
        
        sendReply(response as NSDictionary)
        cleanupPresentation()
    }
    
    public func open(options: Dictionary<String, Any>, result: @escaping FlutterResult, from viewController: UIViewController?) {
        self.pendingResult = result
        self.paymentCompleted = false
        self.presentingViewController = viewController
        let key = options["key"] as? String
        var options = options
        options["integration"] = "flutter"
        options["FRAMEWORK"] = "flutter"

        DispatchQueue.main.async {
            let razorpay = RazorpayCheckout.initWithKey(key ?? "", andDelegateWithData: self)
            razorpay.setExternalWalletSelectionDelegate(self)
            if let events = self.subscribedAnalyticsEvents, !events.isEmpty {
                razorpay.subscribeToAnalyticsEvents(events, callback: self)
            }
            if let vc = viewController {
                razorpay.open(options, displayController: vc)
            } else {
                razorpay.open(options)
            }
        }
    }
    
    public func resync(result: @escaping FlutterResult) {
        result(pendingReply)
        pendingReply = nil
    }
    
    private func sendReply(_ response: NSDictionary) {
        if pendingResult != nil {
            pendingResult(response)
            pendingReply = nil
        } else {
            pendingReply = response
        }
    }
    
    private func cleanupPresentation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var vc = self.presentingViewController
            while let presented = vc?.presentedViewController {
                if presented.isBeingDismissed {
                    break
                }
                presented.dismiss(animated: false, completion: nil)
                vc = presented
            }
        }
    }
    
    static func translateRzpPaymentError(errorCode: Int) -> Int {
        switch (errorCode) {
        case 0:
            return NETWORK_ERROR
        case 1:
            return INVALID_OPTIONS
        case 2:
            return PAYMENT_CANCELLED
        default:
            return UNKNOWN_ERROR
        }
    }
    
}
