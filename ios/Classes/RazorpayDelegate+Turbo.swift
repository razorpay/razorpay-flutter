//
//  RazorpayDelegate+Turbo.swift
//  Pods
//
//  Created by Justin Joseph on 29/05/25.
//


import Flutter
import Razorpay
import WebKit
import TurboUpiPluginUI

typealias TurboDictionary = Dictionary<String,Any>
typealias TurboArrayDictionary = Array<TurboDictionary>

extension RazorpayDelegate {
    //MARK: Flutter call back methods
    func updateToken(token: String) {
        self.sessionTokenCompletion?(Session(token: token))
    }
    
    
    func isTurboPluginAvailable(result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink) {
        self.pendingResult = result
        self.eventSink = eventSink
        var reply = TurboDictionary()
#if canImport(TurboUpiPluginUI)
        reply["isTurboPluginAvailable"] =  true
#else
        reply["isTurboPluginAvailable"] =  false
#endif
        sendReply(data: reply)
    }
    
    //MARK: Custom UI
    func linkNewUpiAccount(mobileNumber: String, color: String, result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink){
        self.pendingResult = result
        self.initilizeSDK(withKey: self.merchantKey, result: result)
        self.razorpay?.upiTurbo?.linkNewUpiAccount(mobileNumber: mobileNumber, color: color, completionHandler: { response, error in
            guard error == nil else {
                let err = error as? TurboError
                self.handleAndPublishTurboError(error: err)
                return
            }
            if let accList = response as? [UpiAccount] {
                var reply = Dictionary<String,Any>()
                reply["data"] = self.getUpiAccountJSON(accList)
                self.sendReply(data: reply)
            }
        })
    }
    
    func manageAccount(customerMobile: String, color: String , result: @escaping FlutterResult, eventSink: @escaping FlutterEventSink) {
        self.pendingResult = result
        self.eventSink = eventSink
        self.initilizeSDK(withKey: self.merchantKey, result: result)
        self.razorpay?.upiTurbo?.manageUpiAccount(mobileNumber: customerMobile, color: color, completionHandler: {_,_ in
        })
    }
    
    func onEventSuccess(_ reply: inout TurboDictionary) {
          reply["type"] = CODE_EVENT_SUCCESS
          sendReplyByEventSink(reply)
      }
    
    func sendReplyByEventSink(_ reply: TurboDictionary) {
         self.eventSink(reply)
     }
    
    func sendReply(data: TurboDictionary) {
        pendingResult(data)
    }
    
    fileprivate func convertDictionaryToJSON<T: Any>(_ dictionary: T) -> String?  {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
            print("Something is wrong while converting dictionary to JSON data.")
            return nil
        }
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Something is wrong while converting JSON data to JSON string.")
            return nil
        }
        
        return jsonString
    }
    
    private func getUpiAccountJSON(_ upiAccounts: [UpiAccount]) -> String? {
        var upiAccountArrayDict = TurboArrayDictionary()
        if !upiAccounts.isEmpty {
            for account in upiAccounts {
                let dict = getUpiAccountDict(account)
                upiAccountArrayDict.append(dict)
            }
        }
        
        if let bankAccountStr = convertDictionaryToJSON(upiAccountArrayDict) {
            return bankAccountStr
        }
        
        return nil
    }
    
    func convertToDictionary(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    private func getUpiAccountDict(_ account: UpiAccount) -> TurboDictionary {
        var dict = TurboDictionary()
        dict["account_number"] = account.accountNumber
        dict["bank_logo_url"] = account.bankLogoUrl
        dict["bank_name"] = account.bankName
        dict["bankPlaceholderUrl"] = account.bankPlaceholderUrl
        dict["ifsc"] = account.ifsc
        //   dict["pinLength"] = account.pinLength
        
        if let vpa = account.vpa {
            var vpaDict = TurboDictionary()
            vpaDict["address"] = vpa.address
            vpaDict["handle"] = vpa.handle
            vpaDict["active"] = vpa.active
            vpaDict["default"] = vpa.isDefault
            vpaDict["validated"] = vpa.validated
            vpaDict["username"] = vpa.username
            if let account = vpa.bankAccount {
                vpaDict["bank_account"] = getUpiBankAccountDict(account)
            }
            dict["vpa"] = vpaDict
        }
        
        return dict
    }
    
    private func getUpiBankAccountDict(_ account: UpiBankAccount) -> TurboDictionary {
        var dict = TurboDictionary()
        dict["ifsc"] = account.ifsc
        dict["masked_account_number"] = account.accountNumber
        dict["beneficiary_name"] = account.beneficiaryName
        dict["state"] = self.getStringStateFromBankAccounutState(account.state)
        dict["id"] = "123"
        dict["type"] = "SAVING"
        if let bank = account.bank {
            var bankDict = bank.toDictionary()
            bankDict["data"] = nil
            bankDict["upi"] = true
            dict["bank"] = bankDict
        }
        if let creds = account.creds {
            var credDict = TurboDictionary()
            if let upiPIn = creds.upipin {
                credDict["upipin"] = upiPIn.toDictionary()
            }
            if let atmPin = creds.atmpin {
                credDict["atmpin"] = atmPin.toDictionary()
            }
            if let sms = creds.sms {
                credDict["sms"] = sms.toDictionary()
            }
            dict["creds"] = credDict
        }
        return dict
    }
    
    private func getStringStateFromBankAccounutState(_ state: UpiBankAccountState) -> String? {
        switch state {
            
        case .upiPinNotSet:
            return "upiPinNotSet"
            
        case .upiPinSet:
            return "upiPinSet"
            
        case .linkingInProgress:
            return "linkingInProgress"
            
        case .linkingSuccess:
            return "linkingSuccess"
            
        case .linkingFailed:
            return "linkingFailed"
            
        @unknown default:
            return "linkingSuccess"
            
        }
    }
    
    private func convertTurboErrorToJSON(turboError: TurboError?) -> String? {
        let turboErrorDict = [
            "errorCode": turboError?.errorCode ?? "",
            "errorDescription": turboError?.errorDescription ?? "",
            "errorReason": turboError?.errorReason ?? "",
            "errorSource": turboError?.errorSource ?? "",
            "errorStep": turboError?.errorStep ?? "",
        ]
        
        if let turboErrorStr = convertDictionaryToJSON(turboErrorDict) {
            return turboErrorStr
        }
        
        return nil
    }

    
    private func handleAndPublishTurboError(error: TurboError?) {
        print(self.pendingResult as Any)
        self.pendingResult(FlutterError.init(code: error?.errorCode ?? "",
                                             message: error?.errorDescription,
                                             details: nil))
    }
    
}


extension Array where Element: NSObject {
    func toArrayDictionary() -> TurboArrayDictionary {
        var localArray = TurboArrayDictionary()
        for object in self {
            localArray.append(object.toDictionary())
        }
        return localArray
    }
}

extension NSObject {
    func toDictionary() -> TurboDictionary {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
}
