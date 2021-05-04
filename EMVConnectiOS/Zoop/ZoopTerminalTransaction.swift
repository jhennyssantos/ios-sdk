//
//  ZoopTerminalTransaction.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 18/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

public class ZoopTerminalTransaction: NSObject {
    var applicationDisplayListener: ApplicationDisplayProtocol?
    var extraCardInformationListener: ExtraCardInformationProtocol?
    var conn: Connection?
    let closeCancel = 1110

    public func setExtraCardInformationListener(pExtraCardInformationListener: ExtraCardInformationProtocol) {
        extraCardInformationListener = pExtraCardInformationListener
    }

    public func setApplicationDisplayListener(padl: ApplicationDisplayProtocol) {
        applicationDisplayListener = padl
    }

    public func openTerminalConnection() {
        applicationDisplayListener?.showMessage(var1: "Conectando ao terminal. Aguarde.", var2: TerminalMessageType.WAIT_INITIALIZING)
        //EADSessionController.shared().openSession()
    }

    public func closeTerminalConnection() {
        DevicesManager.shared.getSelectedDevice()?.close()
    }

    public func openTerminalProtocolChannel(didOpenTerminalProtocol: (TerminalProtocolChannel) -> Void) {
        let tpc = TerminalProtocolChannel.shared

        _ = tpc.terminalOpen(didTerminalOpen: { (_) in
            _ = tpc.terminalDisplay(psMsg: "Conectando...", didTerminalDisplay: { (_) in
                applicationDisplayListener?.showMessage(var1: "Conectando...", var2: TerminalMessageType.WAIT_INITIALIZING)
                didOpenTerminalProtocol(tpc)
            })
        })

    }

    public func cancelConnection() {
        if(conn?.getMessageHandler()?.isComandAsync)! {
            conn?.sendCommandResponseToServer(iReturnCode: Int(PP.PP_CANCEL.rawValue))
        } else {
            var sCancel = "CABO000"
            var b: [UInt8] = [UInt8](sCancel.utf8)
            b[0] = 13
            self.conn?.wsComm?.send(messageInBytes: b)
            self.conn?.wsComm?.websocket.close(closeCancel, reason: "Operação abortada")
            self.conn?.paymentWasAborted = true

        }
    }

    public func addCardLast4Digits(sLast4Digits: String) throws {
        let scommand: [UInt8] = [UInt8] (("ECL\((String(format: "%03d", (sLast4Digits.count)))) \(sLast4Digits)").utf8)
        self.conn?.wsComm?.send(messageInBytes: scommand)
    }

    public func addCardExpirationDate(sCardExpirationDate: String) throws {
        let scommand: [UInt8] = [UInt8] (("ECE\((String(format: "%03d", (sCardExpirationDate.count)))) \(sCardExpirationDate)").utf8)
        self.conn?.wsComm?.send(messageInBytes: scommand)
    }

    public func addCardCVC(sCardCVC: String) throws {
        
        // Get the String.UTF8View.
        let bytes = sCardCVC.utf8
        
        // Get an array from the UTF8View.
        // ... This is a byte array of character data.
        var buffer = [UInt8](bytes)
        
        // Change the first byte in the byte array.
        // ... The byte array is mutable.
        buffer.insert(UInt8(48), at:0)
        
        // Get a string from the byte array.
        if let result = String(bytes: buffer, encoding: String.Encoding.ascii) {
            
            self.conn?.wsComm?.send(message: result)
        }
    }

    public func addSignature (signature: String, receiptId: String, token: String, marketplaceId: String)
        throws {

        if let url = URL(string:Url.getReceiptsUrl(marketplaceId: marketplaceId, receiptId: receiptId)) {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  
            let auth = "Baearer \(token)"
            request.setValue(auth, forHTTPHeaderField: "Authorization")
            request.httpMethod = "PUT"
            request.httpBody = "\("signature=")\(signature)".data(using: String.Encoding.ascii, allowLossyConversion: false)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    return
                }

                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 201, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")

                } else {
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString))")

                }
            }
            task.resume()
        }
    }
}
