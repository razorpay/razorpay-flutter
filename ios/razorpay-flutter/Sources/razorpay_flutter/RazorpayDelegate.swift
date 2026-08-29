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

    private var pendingResult: FlutterResult!
    private var razorpayCheckout: RazorpayCheckout?
    private var subscribedAnalyticsEvents: [String]?
    var merchantEventSink: FlutterEventSink?

    @objc public func onExternalWalletSelected(_ walletName: String, withPaymentData paymentData: [AnyHashable : Any]?) {
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_EXTERNAL_WALLET

        var data = [String:Any]()
        data["external_wallet"] = walletName
        response["data"] = data

        pendingResult(response as NSDictionary)
    }

    public func subscribeToAnalyticsEvents(events: [String]) {
        subscribedAnalyticsEvents = events
    }

    public func onEvent(_ payloadJson: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let sink = self.merchantEventSink else {
                print("[RazorpayFlutter] Analytics event received but Flutter listener is not connected")
                return
            }
            sink(payloadJson)
        }
    }

    @objc public func onPaymentError(_ code: Int32, description message: String, andData data: [AnyHashable : Any]?) {
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_ERROR

        var errorData = [String:Any]()
        errorData["code"] = RazorpayDelegate.translateRzpPaymentError(errorCode: Int(code))
        errorData["message"] = message
        errorData["responseBody"] = data

        response["data"] = errorData
        pendingResult(response as NSDictionary)
    }

    @objc public func onPaymentSuccess(_ payment_id: String, andData data: [AnyHashable: Any]?) {
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_SUCCESS
        response["data"] = data

        pendingResult(response as NSDictionary)
    }

    public func open(options: Dictionary<String, Any>, result: @escaping FlutterResult, from viewController: UIViewController?) {
        self.pendingResult = result

        guard let key = options["key"] as? String, !key.isEmpty else {
            reportInvalidOptions(message: "Key is required. Please check if key is present in options.")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let razorpay = RazorpayCheckout.initWithKey(key, andDelegateWithData: self)
            razorpay.setExternalWalletSelectionDelegate(self)
            self.razorpayCheckout = razorpay

            if let events = self.subscribedAnalyticsEvents, !events.isEmpty {
                razorpay.subscribeToAnalyticsEvents(events, callback: self)
            }

            var checkoutOptions = options
            checkoutOptions["integration"] = "flutter"
            checkoutOptions["FRAMEWORK"] = "flutter"

            if let viewController = viewController {
                razorpay.open(checkoutOptions, displayController: viewController)
            } else {
                razorpay.open(checkoutOptions)
            }
        }
    }

    public func resync(result: @escaping FlutterResult) {
        result(nil)
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

    private func reportInvalidOptions(message: String) {
        var response = [String: Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_ERROR

        var errorData = [String: Any]()
        errorData["code"] = RazorpayDelegate.INVALID_OPTIONS
        errorData["message"] = message
        response["data"] = errorData

        pendingResult(response as NSDictionary)
    }

}
