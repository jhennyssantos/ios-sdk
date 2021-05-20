//
//  Receipt.swift
//  ZoopCheckoutiOS
//
//  Created by Alexsander on 26/12/17.
//  Copyright © 2017 Zoop. All rights reserved.
//

import Foundation

@objc public class Receipt: NSObject {
    public static let sharedInstance = Receipt()
    
    private override init() {}
    
    @objc public func getReceiptText(receiptId: String, marketplaceId: String, token: String, onComplete: @escaping (_ receiptText: String) -> Void) {
        
        
        if let url = URL(string: Url.getReceiptsUrl(marketplaceId: marketplaceId, receiptId: receiptId)) {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                if let data = data, error == nil {
                    if let responseString = String(data: data, encoding: .utf8), let responseDict = self.convertToDictionary(text: responseString), let originalReceipt = responseDict["original_receipt"] as? [String: String], let merchantReceipt = originalReceipt["sales_receipt_cardholder"] {
                        let receipt = merchantReceipt.replacingOccurrences(of: "@", with: "\n")
                        onComplete(receipt)
                    }
                }
                return
            }
            
            task.resume()
        }
    }
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @objc public func sendEmailReceipt (receiptId: String, marketplaceId: String, token: String, email: String, onComplete: @escaping (_ success: Bool) -> Void) {
        
        let url = Url.getReceiptsEmailUrl(marketplaceId: marketplaceId, receiptId: receiptId)
        let parameters = ["subscription_track": "false", "bypass_list_management": "true", "to": "\(email)"]
        sendReceiptText(token: token, sUrl: url, receiptType: .email, parameters: parameters, onComplete: onComplete)
    }
    
    @objc public func sendSMSReceipt (receiptId: String, marketplaceId: String, token: String, phoneNumber: String, onComplete: @escaping (_ success: Bool) -> Void) {
        let url = Url.getReceiptsSMSUrl(marketplaceId: marketplaceId, receiptId: receiptId)
        let parameters = ["to": "\(phoneNumber)"]
        sendReceiptText(token: token, sUrl: url, receiptType: .sms, parameters: parameters, onComplete: onComplete)
    }
    
    @objc public func sendReceiptText(token: String , sUrl: String, receiptType: ReceiptSendType, parameters: [String: String], onComplete: @escaping (_ success: Bool) -> Void) {
    
        if let url = URL(string: sUrl) {
            var request = URLRequest(url: url)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            
            var postString = ""
            
            for (key, value) in parameters {
                postString = postString + "\(key)=\(value)&"
            }
            
            let truncatedPostString = String(postString.dropLast())
            request.httpBody = truncatedPostString.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                if let validatedResponse = (response as! HTTPURLResponse?) {
                    DispatchQueue.main.sync {
                        if validatedResponse.statusCode == 200 || validatedResponse.statusCode == 201 {
                            onComplete(true)
                        } else {
                            onComplete(false)
                        }
                    }
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                task.resume()
            }
        }
    }
}
