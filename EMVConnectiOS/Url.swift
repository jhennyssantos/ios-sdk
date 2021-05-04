//
//  Url.swift
//  EMVConnectiOS
//
//  Created by Leonardo Valderas on 04/09/19.
//  Copyright © 2019 Carla Galdino Wanderley. All rights reserved.
//

import Foundation



class Url {
    
    private static var V1 = "v1/"
    private static var MARKETPLACES = "marketplaces/"
    private static var RECEIPTS = "/receipts/"
    private static var TRANSACTIONS = "/transactions/"
    private static var EMAILS = "/emails"
    private static var TEXTS = "/texts"
    
    
    //////////// URLS /////////////////
    
     
    // ZEC
    //Prod
    private static var BASE_URL_ZEC = "wss://zec.pagzoop.com/ios/"
    
    //private static var BASE_URL_ZEC = "wss://zec-qacp-develop.zoop.ws/ios/"
    
    //Prod + voucher
    //private static var BASE_URL_ZEC = "wss://zec.zoop.ws/ios/"
    //staging
    //private static var BASE_URL_ZEC = "wss://zoopsdk-api.staging.pagzoop.com/ios/"
    //dev
    //private static var BASE_URL_ZEC = "wss://zoopsdk-api.dev.pagzoop.com/ios/"
    //dev38
    //private static var BASE_URL_ZEC = "wss://zoopsdk2.dev.pagzoop.com/ios/"
    //Testing
    //private static var BASE_URL = "wss://zec-testing.dev.zoop.tech/ios/"
    //Zec2
    //private static var BASE_URL = "wss://zecv2-api.dev.pagzoop.com/ios/"
    // Log
    private static var LOG_URL = "wss://pos-logs.pagzoop.com/ios/"
    
    //172.25.50.116 dev116 # zoopsdk.dev.pagzoop.com
    //172.25.50.38 dev38 # zoopsdk2.dev.pagzoop.com
    //172.25.30.73 stg73 # zoopsdk-api.staging.pagzoop.com

    
    //API
    //prod
    private static var BASE_URL_API = "https://api.zoop.ws/"
    //staging
    //private static var BASE_URL_API = "https://api.staging.pagzoop.com/"

    
    /////////////////METHODS//////////////////
    static func getBaseUrlZec() -> String {
        return self.BASE_URL_ZEC
    }
    
    static func getBaseUrlApi() -> String {
        return self.BASE_URL_API
    }
    
    static func getLogUrl() -> String {
        return self.LOG_URL
    }
    
    static func getMarketplacesUrl(marketplaceId: String) -> String {
        return self.BASE_URL_API + V1 + MARKETPLACES + "\(marketplaceId)"
    }
    
    static func getReceiptsUrl(marketplaceId: String, receiptId: String) -> String {
        return getMarketplacesUrl(marketplaceId: marketplaceId) + RECEIPTS + "\(receiptId)"
    }
    
    static func getReceiptsEmailUrl(marketplaceId: String, receiptId: String) -> String {
        return getMarketplacesUrl(marketplaceId: marketplaceId) + RECEIPTS + "\(receiptId)" + EMAILS
    }
    
    static func getReceiptsSMSUrl(marketplaceId: String, receiptId: String) -> String {
        return getMarketplacesUrl(marketplaceId: marketplaceId) + RECEIPTS + "\(receiptId)" + TEXTS
    }
    
    static func getTransactionsUrl(marketplaceId: String, transactionId: String) -> String {
        return getMarketplacesUrl(marketplaceId: marketplaceId) + TRANSACTIONS + "\(transactionId)"
    }
              
}
