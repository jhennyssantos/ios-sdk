//
//  ZoopTerminalVoidPayment.swift
//  ZoopCheckout
//
//  Created by Thiago Mainente de S. G. Gomes on 10/31/17.
//  Copyright © 2017 Zoop. All rights reserved.
//

import Foundation

@objc public class ZoopTerminalVoidPayment: ZoopTerminalTransaction {

    var terminalVoidPaymentListener: VoidTransactionProtocol?
    var connectBluetooth: Bool

    @objc public override init() {
        connectBluetooth = false
    }

    @objc public func setTerminalPaymentListener(ptpl: VoidTransactionProtocol) {
        self.terminalVoidPaymentListener = ptpl
    }

    @objc public func voidTransaction(transactionId: String, marketplaceId: String, sellerId: String, publishableKey: String) throws {
        
        DevicesManager.shared.getSelectedDevice()?.open()

        print("Performing void transaction inside the framework")

        let terminalPaymentRef = self
        let queue = DispatchQueue(label: "test", qos: .utility, attributes: .concurrent)
        queue.async {
            do {
                print("Starting new thread")
                //TODO: Retentar conexão bluetooth
                terminalPaymentRef.openTerminalConnection()
                let terminalSelected = DevicesManager.shared.getSelectedDevice()
                if terminalSelected == nil {

                    print("Terminal selected == nil")

                    let connectionFailed: String = "{error:{i18n_checkout_message_explanation:\"Nenhum terminal configurado\",message:\"Configure sua maquininha e tente novamente\"}}"

                    let data: Data = connectionFailed.data(using: String.Encoding.utf8)! as Data
                    let connectionFailedObj = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    self.terminalVoidPaymentListener?.voidTransactionFailed(var1: connectionFailedObj as AnyObject)
                }

                self.openTerminalProtocolChannel(didOpenTerminalProtocol: { (tpc ) in
                    self.conn = Connection(tpc: tpc)
                    self.conn?.createMessageHandler()
                    self.conn?.getMessageHandler()?.setTerminalVoidPaymentListener(pvtp: self.terminalVoidPaymentListener!)
                    self.conn?.setApplicationDisplayListener(padl: self.applicationDisplayListener!)
                    self.conn?.getMessageHandler()?.setExtraCardInformationListener(pecil: self.extraCardInformationListener!)
                    self.conn?.connect()
                    self.connectBluetooth = true
                    self.applicationDisplayListener?.showMessage(var1: "Terminal conectado. Aguarde...", var2: TerminalMessageType.WAIT_INITIALIZING)
                    
                    var sbCommand = [UInt8]()
                    sbCommand.append(contentsOf: [UInt8](marketplaceId.utf8))
                    sbCommand.append(contentsOf: [UInt8](sellerId.utf8))
                    sbCommand.append(contentsOf: [UInt8](publishableKey.utf8))
                    sbCommand.append(contentsOf: [UInt8](transactionId.utf8))
                    
                    let selectedDevice = DevicesManager.shared.getSelectedDevice()
                    let terminalIdentifier = selectedDevice?.getName()
                    
                    guard let terminId = terminalIdentifier else {
                        Log(message: "Invalid terminal identifier")
                        return
                    }

                    let terminalIdWithPaddingLeft = terminId.leftPadding(toLength: 20, withPad: " ")
                    
                    print(terminalIdWithPaddingLeft)
                    sbCommand.append(contentsOf: [UInt8](terminalIdWithPaddingLeft.utf8))

                    let sCommandVoid="VOI"
                    let iCommandHeaderSize = sCommandVoid.count + 3 // Message size with 3 digits
                    let sCommandString =  "\(sCommandVoid)\((String(format: "%03d", sbCommand.count + iCommandHeaderSize)))\(String(data: Data(bytes: sbCommand), encoding: .utf8)!)"
                    let b: [UInt8] = [UInt8](sCommandString.utf8)
                    self.conn?.wsComm?.send(messageInBytes: b)
                })
            }
        }
    }

}
