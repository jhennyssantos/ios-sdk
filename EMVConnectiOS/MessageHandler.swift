//
//  MessageHandler.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 17/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

class MessageHandler {
    let ASYNC_COMMANDS: [String] = ["GOC", "GCR", "GPN", "GKY", "GEN", "CKE", "CHP", "RMC" ]
    var tpc = TerminalProtocolChannel.shared
    var conn: Connection?
    var eci: ExtraCardInformationProtocol?
    var tpp: TerminalPaymentProtocol?
    var apdp: ApplicationDisplayProtocol?
    var vtp: VoidTransactionProtocol?
    var tpl: TerminalPaymentProtocol?
    var isComandAsync = false
    var result: UInt8?
    var terminalResponse: UInt8?
    var timer: Timer?
    var tlrTimer: Timer?

    public init(terminalProtocolChannel: TerminalProtocolChannel, connection: Connection) {
        tpc = terminalProtocolChannel
        conn = connection
    }

    public func setTerminalPaymentListener(ptpl: TerminalPaymentProtocol) {
        tpp = ptpl
    }

    public func setApplicationDisplayListener(padl: ApplicationDisplayProtocol) {
        apdp = padl
    }

    public func setExtraCardInformationListener(pecil: ExtraCardInformationProtocol) {
        eci = pecil
    }

    public func setTerminalVoidPaymentListener(pvtp: VoidTransactionProtocol) {
        vtp = pvtp
    }

    public func handleServerMessage(dataReceived: String) {

        print("handleServerMessage: \(dataReceived)")
        
        if (dataReceived == "ECL") {
            eci?.cardLast4DigitsRequested()
        } else if(dataReceived.hasPrefix("OPN")) {
            tpp?.currentChargeCanBeAbortedByUser(var1: true)
            conn?.sendCommandResponseToServer(iReturnCode: 0)
        } else if (dataReceived.hasPrefix("ECC")) {
            eci?.cardCVCRequested()
        } else if (dataReceived.hasPrefix("ECE")) {
            eci?.cardExpirationDateRequested()
        } else if (dataReceived.hasPrefix("CSR")) {
            tpp?.cardholderSignatureRequested()
            conn?.sendCommandResponseToServer(iReturnCode: 0)
        } else if (dataReceived.hasPrefix("CPF")) {
            let iMessageSize = Int((dataReceived.substring(firstIndex: 6, lastIndex: 9)))
            let strJSON = dataReceived.substring(firstIndex: 9, lastIndex: iMessageSize! + 9)

            // convert String to NSData
            let data: Data = strJSON.data(using: String.Encoding.utf8)! as Data

            let obj = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            tpp?.paymentFailed(var1: obj as AnyObject)
            conn?.sendCommandResponseToServer(iReturnCode: 0)
        } else if (dataReceived.hasPrefix("CPS")) {
            let iMessageSize = Int((dataReceived.substring(firstIndex: 3, lastIndex: 9)))
            let strJSON = dataReceived.substring(firstIndex: 9, lastIndex: iMessageSize! + 9)

            // convert String to NSData
            let data: Data = strJSON.data(using: String.Encoding.utf8)! as Data

            let obj = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            tpp?.paymentSuccessful(var1: obj as AnyObject)
            conn?.sendCommandResponseToServer(iReturnCode: 0)
            conn?.paymentSucceeded = true
        } else if (dataReceived.hasPrefix("VTF")) {
            let iMessageSize = Int((dataReceived.substring(firstIndex: 3, lastIndex: 9)))
            let strJSON = dataReceived.substring(firstIndex: 9, lastIndex: iMessageSize! + 9)

            // convert String to NSData
            let data: Data = strJSON.data(using: String.Encoding.utf8)! as Data

            let obj = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            vtp?.voidTransactionFailed(var1: obj as AnyObject)
            conn?.sendCommandResponseToServer(iReturnCode: 0)
        } else if (dataReceived.hasPrefix("VTS")) {
            let iMessageSize = Int((dataReceived.substring(firstIndex: 3, lastIndex: 6)))
            let strJSON = dataReceived.substring(firstIndex: 9, lastIndex: iMessageSize! + 9)

            // convert String to NSData
            let data: Data = strJSON.data(using: String.Encoding.utf8)! as Data

            let obj = try? JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            vtp?.voidTransactionSuccessful(var1: obj as AnyObject)
            conn?.sendCommandResponseToServer(iReturnCode: 0)
            conn?.paymentSucceeded = true
        } else if (dataReceived.hasPrefix("CPA")) {
            tpp?.paymentAborted()
            conn?.sendCommandResponseToServer(iReturnCode: 0)
        } else if (dataReceived.hasPrefix("END")) {
            conn?.sendCommandResponseToServer(iReturnCode: 0)
            conn?.closeConnection(1000) // 1000 is close code for success
        } else if (dataReceived.hasPrefix("DSA")) {
            // Parameters:
            // numeric 3 digits: Size of message
            let iMessageSize = Int(dataReceived.substring(firstIndex: 3, lastIndex: 6))

            // Message in the size described
            // Last 3 chars are message type
            let sMessage = dataReceived.substring(firstIndex: 6, lastIndex: iMessageSize! + 3)

            // 3 digits for message type following TerminalMessageType
            let iTerminalMessageType = Int(dataReceived.substring(firstIndex: iMessageSize! + 3, lastIndex: iMessageSize! + 6))
            Log(message: "application display listener method called with message" + sMessage)
            if iTerminalMessageType != nil {
                let messageType = TerminalMessageType(rawValue: iTerminalMessageType!)
                apdp?.showMessage(var1: String(sMessage), var2: messageType!)
            }
            conn?.sendCommandResponseToServer(iReturnCode: 0)
        } else if (dataReceived.hasPrefix("DSB")) {
            // Parameters:
            // numeric 3 digits: Size of message
            var iMessageParserPosition = 3
            let iMessageSize = Int((dataReceived.substring(firstIndex: iMessageParserPosition, lastIndex: 6)))
            iMessageParserPosition = iMessageParserPosition + 3

            // Message in the size described
            let sMessage = dataReceived.substring(firstIndex: 6, lastIndex: iMessageSize! + 6)
            iMessageParserPosition = iMessageParserPosition + iMessageSize!

            // 3 digits for message type following TerminalMessageType
            let iTerminalMessageType = Int((dataReceived.substring(firstIndex: iMessageParserPosition, lastIndex: iMessageParserPosition + 3)))
            iMessageParserPosition = iMessageParserPosition + 3

            // numeric 3 digits: Size of comment
            //_ = Int((dataReceived.substring(firstIndex: iMessageParserPosition, lastIndex: 3)))
            iMessageParserPosition = iMessageParserPosition + 3

            // Message in the size described
            let sComment = dataReceived.substring(firstIndex: iMessageParserPosition, lastIndex: iMessageSize! + iMessageParserPosition)
            Log(message: "application display listener method called with message" + sMessage)
            if (iTerminalMessageType != nil) {
                apdp?.showMessage(var1: sMessage, var2: TerminalMessageType(rawValue: iTerminalMessageType!)!, var3: sComment)
            }

            conn?.sendCommandResponseToServer(iReturnCode: 0)
            //        } else if (dataReceived.hasPrefix("TLE")) { //Temporariamente a sequencia da carga de tabelas está desativada.
            //            conn?.sendCommandResponseToServer(iReturnCode: 13)
        } else {
            if (dataReceived.hasPrefix("GCR")) {
                apdp?.showMessage(var1: "Insira ou Passe o Cartão", var2: TerminalMessageType.ACTION_INSERT_CARD)
            }
            
            Log(message: "[MESSAGE HANDLER] Proxying to pinpad: " + dataReceived)
            isComandAsync = ASYNC_COMMANDS.joined().contains(dataReceived.substring(firstIndex: 0, lastIndex: 3))

            print("handleServerMessage: dataReceived-> \(dataReceived)")
            tpc.sendACommand(sInputCommand: dataReceived, isAsync: isComandAsync, didSendACommand: {(sbOut: [UInt8]?, terminalResponse) in
                Log(message: "[MESSAGE HANDLER] Sending pinpad response to server. pinpad response \(terminalResponse)")

              if (isComandAsync) {
               // print("handleServerMessage:isComandAsync")
                    result = 255
                    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(waitForTerminalResponse), userInfo: nil, repeats: true)
                } else {
                   if dataReceived.hasPrefix("TLI"){
                        conn?.sendCommandResponseToServer(iReturnCode: Int(terminalResponse))
                   } else if dataReceived.hasPrefix("TLR") {
                       // print("handleServerMessage: hasPrefix(TLR) -> timer: \(tlrTimer)")
                        tlrTimer?.invalidate()
                       // print("handleServerMessage: hasPrefix(TLR) -> timer invalidate")
                        tlrTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(respondToTLR), userInfo: nil, repeats: false)
                       // print("handleServerMessage: hasPrefix(TLR) -> timer after scheduledTimer : \(tlrTimer)")
                    } else {
                       // let r = Int(terminalResponse)
                       // print("handleServerMessage: not hasPrefix(TLR) sent iReturnCode: \(r) sbOut: \(sbOut)")
                        conn?.sendCommandResponseToServer(iReturnCode: Int(terminalResponse), sbOut: sbOut ?? [])
                    }
                
                }
            })
        }
    }
    
    @objc private func respondToTLR() {
        // print("handleServerMessage: respondToTLR-> return 0")
        self.conn?.sendCommandResponseToServer(iReturnCode: Int(0))
    }

    @objc private func waitForTerminalResponse() {
        // print("waitForTerminalResponse")
        self.tpc.tryRead(isAsync: true, count: 1, inLength: 0, didRead: {(sbOut: [UInt8]?, result) in
            var bProcessing = true
            //print("waitForTerminalResponse -> result: \(result)")
            if (0 == result) {
                let sOutput = String(data: Data(bytes: sbOut!), encoding: .utf8)
              //  print("waitForTerminalResponse -> sOutput: \(sOutput)")
                // Notify message is async in the middle of async commands.
                // This has not been handled on previous versions. This is part of the BC SDK Client and SDK Server to avoid unnecessary traffic
                // and control.
                if (sOutput?.substring(firstIndex: 0, lastIndex: 3) == "NTM") {
                    //print("waitForTerminalResponse -> sOutput is NTM")
                    let sMessage = sOutput?.substring(firstIndex: 9, lastIndex: Int((sOutput?.substring(firstIndex: 6, lastIndex: 9))!)!)
                //      print("waitForTerminalResponse -> sOutput is NTM sMessage: \(sMessage)")
                    //ja existe no sdk android
                    self.apdp?.showMessage(var1: sMessage!, var2: TerminalMessageType.WAIT)
                } else {
                  // print("waitForTerminalResponse -> bProcessing false")
                    bProcessing = false
                }
            } else if ((1 != result) && (2 != result)) {
                //print("waitForTerminalResponse -> bProcessing false, result: \(result)")
                bProcessing = false
            } else if (1 == result) {
                print("PP PROCESSING")
            }

            if (false == bProcessing) {
               // print("waitForTerminalResponse -> bProcessing false, timer?.invalidate()")
                timer?.invalidate()
           // print("waitForTerminalResponse -> processTerminalResponse sbOut: \(sbOut)  result: \(result)")
                self.processTerminalResponse(sbOut: sbOut ?? [], result: result)
            }
        })
    }

    // TODO - Should be removed when async task be implemented
    public func stopTimer() {
        timer?.invalidate()
    }

    private func processTerminalResponse(sbOut: [UInt8], result: UInt8) {
        //print("processTerminalResponse: sbOut: \(sbOut) resutl: \(result)")
        let sOut = String(data: Data(bytes: sbOut), encoding: .utf8)

       // print("processTerminalResponse: sbOut string: \(sOut)")
        
        if (0 == result) {
           //print("processTerminalResponse: result == 0")
            var sbOutCommand = [UInt8]()
            if (sOut!.count > 0) {
                
             //   print("processTerminalResponse: sOut!.count > 0")
                let intResponse = sOut?.substring(firstIndex: 3, lastIndex: 6)
                
            //    print("processTerminalResponse: intResponse: \(intResponse)")
                terminalResponse = UInt8(Int(intResponse!)!)
                
             //   print("processTerminalResponse: intResponse to int: \(terminalResponse)")
                if (sOut!.count >= 9) {
                    //print("processTerminalResponse: sOut!.count >= 9")
                    sbOutCommand = [UInt8](sOut!.substring(firstIndex: 9, lastIndex: sOut!.count).utf8)
                    //print("processTerminalResponse: sbOutCommand: \(sbOutCommand)")
                }
            }
            //let cr = Int(terminalResponse ?? 0)
           // print("processTerminalResponse: send: iReturnCode: \(cr)  sbOut: \(sbOutCommand)")
            conn?.sendCommandResponseToServer(iReturnCode: Int(terminalResponse ?? 0), sbOut: sbOutCommand)
        } else {
            // print("processTerminalResponse: result != 0")
            // print("processTerminalResponse: send: iReturnCode: \(result)  sbOut: \(sbOut)")
            conn?.sendCommandResponseToServer(iReturnCode: Int(result), sbOut: sbOut)
        }
    }
}
