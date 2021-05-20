//
//  ZoopSession.swift
//  EMVConnectiOS
//
//  Created by Alexsander Rocha on 04/01/2018.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public class ZoopSession: NSObject {

    public static let sharedInstance = ZoopSession()

    private override init() {}

    @objc public func syncCall(method: ZoopMethod, token: String, marketplaceId: String, sellerId: String? = nil, parameters: [String: Any]? = nil, query: [String: String]? = nil, endpoint: String, onCompleted: @escaping (_ response: Dictionary<String, Any>?) -> Void) {

        var url: String = Url.getMarketplacesUrl(marketplaceId: marketplaceId)

        if let _sellerId = sellerId {
            url += "/sellers/\(_sellerId)"
        }

        url += "/\(endpoint)"
       
        if let _query = query {
            url += "?\(self.transformDataToQueryString(_query))"
        }
        
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data, error == nil {
                if let responseString = String(data: data, encoding: .utf8) {
                    let dict = self.convertToDictionary(text: responseString)
                    DispatchQueue.main.async {
                        onCompleted(dict)
                    }
                }
            }
            return
        }

        task.resume()
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

    public func getTransactions(token: String, marketplaceId: String, sellerId: String, limit: Int = 20, status: TransactionStatus = .all, sort: Sort = .timeDescending, startDate: TimeInterval = 1.0, onCompleted: @escaping (_ response: Dictionary<String, Any>?) -> Void) {

        let parameters: [String: String] = ["sort": sort.rawValue.camelCaseToWords(), "limit": "\(limit)", "date_range[gte]": "\(Int(startDate))"]

        syncCall(method: .get, token: token, marketplaceId: marketplaceId, sellerId: sellerId, query: parameters, endpoint: "transactions") { (response) in
            onCompleted(response)
        }
    }

    @objc public func getPlans(token: String, marketplaceId: String, onCompleted: @escaping (_ response: Dictionary<String, Any>?) -> Void) {
        syncCall(method: .get, token: token, marketplaceId: marketplaceId, endpoint: "plans") { (response) in
            onCompleted(response)
        }
    }

    @objc public func getSubscriptions(token: String, marketplaceId: String, sellerId: String, onCompleted: @escaping (_ response: Dictionary<String, Any>?) -> Void) {
        syncCall(method: .get, token: token, marketplaceId: marketplaceId, sellerId: sellerId, endpoint: "subscriptions") { (response) in
            onCompleted(response)
        }
    }

    private func transformDataToQueryString(_ data: [String: String]) -> String {
        var queryString = ""
        for (key, value) in data {
            queryString += ("\(key)=\(value)&")
        }
        return String(queryString.dropLast())
    }
    
    @objc public func getTransaction(token: String, marketplaceId: String, transactionId: String, onCompleted: @escaping (_ response: Dictionary<String, Any>?) -> Void) {
         
          let url: String = Url.getTransactionsUrl(marketplaceId: marketplaceId, transactionId: transactionId)
    
          var request = URLRequest(url: URL(string: url)!)
          request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
          request.httpMethod = "GET"

          let task = URLSession.shared.dataTask(with: request) {data, response, error in
              if let data = data, error == nil {
                  if let responseString = String(data: data, encoding: .utf8) {
                      let dict = self.convertToDictionary(text: responseString)
                      DispatchQueue.main.async {
                          onCompleted(dict)
                      }
                  }
              }
              return
          }

          task.resume()
      }
}
