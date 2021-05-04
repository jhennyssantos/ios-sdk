//
//  ZoopTerminalPayment.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 18/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public class ZoopTerminalPayment: ZoopTerminalTransaction {
    var terminalPaymentListener: TerminalPaymentProtocol?

    let MAX_VALUE = 2147483647

    let RESULT_OK_EMAIL_SENT = 0
    let RESULT_OK_SMS_SENT = 0
    let RESULT_FAILED_SMS_ERROR = 1
    let RESULT_FAILED_INVALID_PHONE_NUMBER = 2
    var sMarketplaceId: String?
    var sPublishableKey: String?
    var sSellerId: String?
    static var chargeRetry: [UInt8]?
    var connectBluetooth: Bool

    @objc public override init() {
        sMarketplaceId = nil
        sPublishableKey = nil
        sSellerId = nil
        connectBluetooth = false
    }

    @objc public func setTerminalPaymentListener(ptpl: TerminalPaymentProtocol) {
        self.terminalPaymentListener = ptpl
    }
    
    @objc public func charge(valueToCharge: Double, paymentOption: PaymentType, iNumberOfInstallments: Int, marketplaceId: String, sellerId: String, publishableKey: String) throws {
        try! self._charge(valueToCharge: valueToCharge, paymentOption: paymentOption, iNumberOfInstallments: iNumberOfInstallments, marketplaceId: marketplaceId, sellerId: sellerId, publishableKey: publishableKey, metadata: nil)
    }
    
    /*
    @objc public func charge(valueToCharge: Double, paymentOption: PaymentType, iNumberOfInstallments: Int, marketplaceId: String, sellerId: String, publishableKey: String, metadata:String) throws {
        try! self._charge(valueToCharge: valueToCharge, paymentOption: paymentOption, iNumberOfInstallments: iNumberOfInstallments, marketplaceId: marketplaceId, sellerId: sellerId, publishableKey: publishableKey, metadata: metadata)
    }*/

    private func _charge(valueToCharge: Double, paymentOption: PaymentType, iNumberOfInstallments: Int, marketplaceId: String, sellerId: String, publishableKey: String, metadata:String?) throws {

        print(" mark \(marketplaceId) seller \(sellerId) public \(publishableKey) meta \(metadata)")
        let iValueToCharge = UInt64((valueToCharge * 100.0).rounded())

        if iValueToCharge > MAX_VALUE {
            throw NSError(domain: "Max value exceeded", code: 99, userInfo: ["value": iValueToCharge, "max value": MAX_VALUE])
        }

        let terminalPaymentRef = self

        DevicesManager.shared.getSelectedDevice()?.open()

        LogDispatcher.sharedInstance.eraseLog()
        MetadataManager.sharedInstance.setMetadata(key: "marketplaceId", value: marketplaceId)
        MetadataManager.sharedInstance.setMetadata(key: "sellerId", value: sellerId)

        DispatchQueue.global(qos: .userInitiated).async {
            //TODO: Retentar conexão bluetooth
            Log(message: String(format: "method charge called. Payment option %d ", paymentOption.rawValue))
            terminalPaymentRef.openTerminalConnection()

            print(" termina open")
            let terminalSelected = DevicesManager.shared.getSelectedDevice()
            if terminalSelected == nil {

                Log(message: "Terminal selected == nil")

                let connectionFailed: String = "{error:{i18n_checkout_message_explanation:\"Nenhum terminal configurado\",message:\"Configure sua maquininha e tente novamente\"}}"

                let data: Data = connectionFailed.data(using: String.Encoding.utf8)! as Data
                let connectionFailedObj = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))

                self.terminalPaymentListener?.paymentFailed(var1: connectionFailedObj as AnyObject)
            }

            self.openTerminalProtocolChannel(didOpenTerminalProtocol: { (tpc) in

                self.sMarketplaceId = marketplaceId
                self.sSellerId = sellerId
                self.sPublishableKey = publishableKey
                self.conn = Connection(tpc: tpc)
                self.conn?.createMessageHandler()
                self.conn?.getMessageHandler()?.setTerminalPaymentListener(ptpl: self.terminalPaymentListener!)
                self.conn?.setApplicationDisplayListener(padl: self.applicationDisplayListener!)
                self.conn?.getMessageHandler()?.setExtraCardInformationListener(pecil: self.extraCardInformationListener!)

                if let _ = self.conn?.connect() {
                    self.connectBluetooth = true
                    self.applicationDisplayListener?.showMessage(var1: "Terminal conectado. Aguarde...", var2: TerminalMessageType.WAIT_INITIALIZING)
                    Log(message: "sending data to server")

                    var iPaymentType = paymentOption
                    if iNumberOfInstallments == 0 && paymentOption == PaymentType.installment_credit {
                        iPaymentType = PaymentType.credit
                    }
                
                    var b: [UInt8] = [UInt8](self.paymentGatewayCharge(iChargeAmount: iValueToCharge, iPaymentType: iPaymentType.rawValue, iNumberOfInstallments: iNumberOfInstallments, sMarketplaceId: self.sMarketplaceId!, sSellerId: self.sSellerId!, sPublishableKey: self.sPublishableKey!, metadata: metadata).utf8)
                    b[6] = 8

                    ZoopTerminalPayment.chargeRetry = b
                    print(" command \(b)")
                    self.conn?.wsComm?.send(messageInBytes: b)
                }
            })
        }
    }

    private func paymentGatewayCharge( iChargeAmount: UInt64, iPaymentType: Int, iNumberOfInstallments: Int, sMarketplaceId: String, sSellerId: String, sPublishableKey: String, metadata:String?) -> String {

        print(" mark \(sMarketplaceId) seller \(sSellerId) public \(sPublishableKey) meta \(metadata)")
        var sbCommand = [UInt8]()
        sbCommand.append(contentsOf: [UInt8](String(format: "%01d", iPaymentType).utf8))
        sbCommand.append(contentsOf: [UInt8](String(format: "%02d", (iNumberOfInstallments)).utf8))
        sbCommand.append(contentsOf: [UInt8](String(format: "%012d", (iChargeAmount)).utf8))

        sbCommand.append(contentsOf: [UInt8](sMarketplaceId.utf8))
        sbCommand.append(contentsOf: [UInt8](sSellerId.utf8))
        sbCommand.append(contentsOf: [UInt8](sPublishableKey.utf8))

        let selectedDevice = DevicesManager.shared.getSelectedDevice()
        let terminalIdentifier = selectedDevice?.getName()

        guard let terminId = terminalIdentifier else {
            Log(message: "Invalid terminal identifier")
            return ""
        }
        
        let terminalIdWithPaddingLeft = terminId.leftPadding(toLength: 20, withPad: " ")
        
        print(terminalIdWithPaddingLeft)
        sbCommand.append(contentsOf: [UInt8](terminalIdWithPaddingLeft.utf8))

        let timestamp = Date().timeIntervalSince1970
        sbCommand.append(contentsOf: [UInt8](String(format: "%015d", Int(timestamp)).utf8))
        
        if let _metadata:String = metadata {
            // There is metadata to pass
            sbCommand.append(1)
            let metadataSize:Int = _metadata.count
            
            // Appending metadata size
            sbCommand.append(contentsOf: [UInt8](String(format: "%05d", (metadataSize)).utf8))
            
            // Appending metadata content
            sbCommand.append(contentsOf: [UInt8](_metadata.utf8))
        } else {
            // NO metadata to pass
            sbCommand.append(contentsOf: [UInt8]("000000".utf8))
        }

        let sCommandCharge="CHR"
        let sVersion="V"
        let iCommandHeaderSize = sCommandCharge.count + sVersion.count + 3 // Command size with 3 digits
        let sCommandString =  "\(sCommandCharge)\((String(format: "%03d", sbCommand.count + iCommandHeaderSize)))\(sVersion)\(String(data: Data(bytes: sbCommand), encoding: .utf8)!)"
        
        print("command \(sCommandString)")
        return sCommandString
    }

    @objc public func requestCancel() {

        if(self.conn?.wsComm != nil) {
            _ = TerminalProtocolChannel.shared.terminalClose(psIdleMsg: "    OPERACAO        CANCELADA", didTerminalClose: {(_) in
                _ = TerminalProtocolChannel.shared.abort()
                cancelConnection()
                terminalPaymentListener?.paymentAborted()
            })
        }
    }

    @objc public static func getCommandRetry() -> [UInt8] {

        return chargeRetry!

    }

}
