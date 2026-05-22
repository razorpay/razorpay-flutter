import Flutter
import Razorpay
import UIKit

public class RazorpayDelegate: NSObject, RazorpayPaymentCompletionProtocolWithData, ExternalWalletSelectionProtocol {

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

    @objc public func onExternalWalletSelected(_ walletName: String, withPaymentData paymentData: [AnyHashable : Any]?) {
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_EXTERNAL_WALLET

        var data = [String:Any]()
        data["external_wallet"] = walletName
        response["data"] = data

        pendingResult(response as NSDictionary)
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

    public func open(options: Dictionary<String, Any>, result: @escaping FlutterResult) {
        self.pendingResult = result

        guard let key = options["key"] as? String, !key.isEmpty else {
            reportInvalidOptions(message: "Key is required. Please check if key is present in options.")
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.presentCheckout(key: key, options: options)
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

    private func presentCheckout(key: String, options: Dictionary<String, Any>) {
        let razorpay = RazorpayCheckout.initWithKey(key, andDelegateWithData: self)
        razorpay.setExternalWalletSelectionDelegate(self)
        razorpayCheckout = razorpay

        var checkoutOptions = options
        checkoutOptions["integration"] = "flutter"
        checkoutOptions["FRAMEWORK"] = "flutter"

        if let viewController = Self.topViewController() {
            razorpay.open(checkoutOptions, displayController: viewController)
        } else {
            razorpay.open(checkoutOptions)
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

    private static func topViewController() -> UIViewController? {
        guard let rootViewController = keyWindow()?.rootViewController else {
            return nil
        }
        return topViewController(from: rootViewController)
    }

    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: \.isKeyWindow)
    }

    private static func topViewController(from controller: UIViewController) -> UIViewController {
        if let presented = controller.presentedViewController {
            return topViewController(from: presented)
        }
        if let navigationController = controller as? UINavigationController,
           let visible = navigationController.visibleViewController {
            return topViewController(from: visible)
        }
        if let tabBarController = controller as? UITabBarController,
           let selected = tabBarController.selectedViewController {
            return topViewController(from: selected)
        }
        return controller
    }
}
