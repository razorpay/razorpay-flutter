import Flutter
import TurboUpiPluginUI
import Razorpay

class RazorpayDelegate: NSObject, RazorpayPaymentCompletionProtocolWithData, ExternalWalletSelectionProtocol {
    
    static let CODE_PAYMENT_SUCCESS = 0
    static let CODE_PAYMENT_ERROR = 1
    static let CODE_PAYMENT_EXTERNAL_WALLET = 2
    
    static let NETWORK_ERROR = 0
    static let INVALID_OPTIONS = 1
    static let PAYMENT_CANCELLED = 2
    static let TLS_ERROR = 3
    static let INCOMPATIBLE_PLUGIN = 3
    static let UNKNOWN_ERROR = 100
    
    let CODE_EVENT_SUCCESS = 200
    
    var razorpay: RazorpayCheckout?

    var sessionToken: String?
    var sessionTokenCompletion: ((Session)-> Void)?
    var pendingResult: FlutterResult!
    var merchantKey: String = ""
    var eventSink: FlutterEventSink!

    func initilizeSDK(withKey key: String, result: @escaping FlutterResult) {
        guard key != "" else { return }
        guard self.razorpay == nil else { return }
        self.merchantKey = key
        pendingResult = result
        
        self.razorpay = RazorpayCheckout.initWithKey(key, andDelegateWithData: self, plugin: RZPTurboUPI.UIPluginInstance())
        self.razorpay?.upiTurboUI?.initialize(self)             
    }

    
    func onExternalWalletSelected(_ walletName: String, withPaymentData paymentData: [AnyHashable : Any]?) {
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_EXTERNAL_WALLET
        
        var data = [String:Any]()
        data["external_wallet"] = walletName
        response["data"] = data
        
        pendingResult(response as NSDictionary)
    }
    
    
    func onPaymentError(_ code: Int32, description message: String, andData data: [AnyHashable : Any]?) {
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_ERROR
        
        var errorData = [String:Any]()
        errorData["code"] = RazorpayDelegate.translateRzpPaymentError(errorCode: Int(code))
        errorData["message"] = message 
        errorData["responseBody"] = data
        
        response["data"] = errorData
        pendingResult(response as NSDictionary)
    }
    
    func onPaymentSuccess(_ payment_id: String, andData data: [AnyHashable: Any]?) {
        var response = [String:Any]()
        response["type"] = RazorpayDelegate.CODE_PAYMENT_SUCCESS
        response["data"] = data
        
        pendingResult(response as NSDictionary)
    }
    
    func open(options: Dictionary<String, Any>, result: @escaping FlutterResult) {
        
        let key = options["key"] as? String
        self.initilizeSDK(withKey: key ?? "", result: result)
        razorpay?.setExternalWalletSelectionDelegate(self)
        var options = options
        options["integration"] = "flutter"
        options["FRAMEWORK"] = "flutter"
        self.razorpay?.open(options, arrExternalPaymentEntities: [RZPTurboUPI.turboUIPaymentPlugin()])
    }
    
    func resync(result: @escaping FlutterResult) {
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
    
}

// MARK: Session Token Handle
extension RazorpayDelegate: TurboSessionDelegate {
     func fetchToken(completion: @escaping (Session) -> Void) {
        self.sessionTokenCompletion = completion
        var reply = TurboDictionary()
        reply["responseEvent"] = "refreshSessionToken"
        onEventSuccess(&reply)
    }
}
