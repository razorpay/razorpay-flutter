import Flutter
import Razorpay

public class RazorpayDelegate: NSObject, RazorpayPaymentCompletionProtocolWithData, ExternalWalletSelectionProtocol {
    
    let CODE_PAYMENT_SUCCESS = 0;
    let CODE_PAYMENT_ERROR = 1;
    let CODE_PAYMENT_EXTERNAL_WALLET = 2;
    
    public func onExternalWalletSelected(_ walletName: String, WithPaymentData paymentData: [AnyHashable : Any]?) {
        var response = [String:Any]()
        response["type"] = CODE_PAYMENT_EXTERNAL_WALLET
        
        var data = [String:Any]()
        data["external_wallet"] = walletName
        response["data"] = data
        
        pendingResult(response as NSDictionary)
    }
    
    
    private var pendingResult: FlutterResult!
    
    public func onPaymentError(_ code: Int32, description message: String, andData data: [AnyHashable : Any]?) {
        var response = [String:Any]()
        response["type"] = CODE_PAYMENT_ERROR
        
        var data = [String:Any]()
        data["code"] = code
        data["message"] = message
        
        response["data"] = data
        
        pendingResult(response as NSDictionary)
    }
    
    public func onPaymentSuccess(_ payment_id: String, andData data: [AnyHashable : Any]?) {
        var response = [String:Any]();
        response["type"] = CODE_PAYMENT_SUCCESS
        
        var data = [String:Any]()
        data["razorpay_payment_id"] = payment_id
        response["data"] = data
        
        pendingResult(response as NSDictionary)
    }
    
    public func open(options: Dictionary<String, Any>, result: @escaping FlutterResult) {
        
        self.pendingResult = result
        
        let key = options["key"] as? String
        
        let razorpay = Razorpay.initWithKey(key ?? "", andDelegateWithData: self)
        razorpay.setExternalWalletSelectionDelegate(self)
        
        razorpay.open(options)
        
    }
    
    public func resync(result: @escaping FlutterResult) {
        result(nil)
    }
    
}
