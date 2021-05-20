//
//  Connection.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 17/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation
import UIKit

class Connection: WebsocketObserverProtocol, WebsocketTimeoutProtocol {
    let nPort: Int = 2300
    var host: String?
    var tpc: TerminalProtocolChannel?
    var messageHandler: MessageHandler?
    var adl: ApplicationDisplayProtocol?
    var deviceId: String = ""
    var isConnected: Bool = false
    var i: Int = 1
    var messageServer: String = ""
    let PROC_COMMANDS: [String] = ["GOC", "GPN" ]
    var wsComm: WebsocketComm?
    var paymentSucceeded = false
    var paymentWasAborted = false

    public init() {
        setupInitialConnection()
    }

    private func setupInitialConnection() {
        //TODO: UUID é reiniciado quando app é reinstalado. Procurar forma de resgatar ID que identifica o dispositivo
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            deviceId = uuid
            Log(message: "Device id: \(deviceId)")
            
            let selectedDevice = DevicesManager.shared.getSelectedDevice()
            let terminalIdentifier = selectedDevice?.getName()
            
            guard let terminId = terminalIdentifier else {
                Log(message: "Invalid terminal identifier")
                return
            }
            
            host = Url.getBaseUrlZec() + "\(deviceId)/\(terminId)"
            
        } else {
            Log(message: "ERRO: Device UUID could not be registered")
        }

        wsComm = nil
        tpc = nil
        messageHandler = nil
        adl = nil
        paymentSucceeded = false
    }

    public func getMessageHandler() -> MessageHandler? {
        return messageHandler
    }

    // MARK - WebsocketObserverProtocol
    public func onMessage(response: String) {
        if !self.paymentWasAborted {
            messageServer = response
            Log(message: "WebsocketObserverProtocol::onMessage: " + response)

            self.messageHandler?.handleServerMessage(dataReceived: response)
        }
    }

    public func setApplicationDisplayListener(padl: ApplicationDisplayProtocol) {
        adl = padl
        self.messageHandler?.setApplicationDisplayListener(padl: adl!)
    }

    public init(tpc: TerminalProtocolChannel) {
        setupInitialConnection()
        self.tpc = tpc
    }
   
    public func sendCommandResponseToServer(iReturnCode: Int) {
        var terminalByteResponse = [UInt8]()
        terminalByteResponse.append(UInt8(iReturnCode))
        checkProcess()
        wsComm?.send(messageInBytes: terminalByteResponse)
    }

    public func checkProcess() {
        if(messageServer.count>2) {
            if(PROC_COMMANDS.joined().contains(messageServer.substring(firstIndex: 0, lastIndex: 3))) {
                adl?.showMessage(var1: "Processando...", var2: TerminalMessageType.WAIT)
                _ = tpc?.terminalDisplay(psMsg: "Processando...", didTerminalDisplay: {(_) in })
            }
        }
    }

    public func sendCommandResponseToServer(iReturnCode: Int, sbOut: [UInt8]) {
        var terminalByteResponse: [UInt8] = [UInt8]()
        terminalByteResponse.append(UInt8(iReturnCode))
        terminalByteResponse.append(contentsOf: sbOut)
        checkProcess()
        self.wsComm?.send(messageInBytes: terminalByteResponse)
    }

    public func connect() -> Bool {
        if let host = self.host {
            wsComm = WebsocketComm(hostURL: host, observer: self, observerTimeout: self)
            wsComm?.websocket.open()
            return true
        }
        return false
    }

    public func createMessageHandler() {
        self.messageHandler = MessageHandler(terminalProtocolChannel: self.tpc!, connection: self)
    }

    public func closeConnection(_ code: Int?) {
        if let code = code {
            wsComm?.websocket.close(code)
        }
    }

    func retryConnection() {
        if !paymentSucceeded {
            if(i <= 6) {
                print("i <= 6")
                let queue = DispatchQueue(label: "test", qos: .utility)
                queue.sync {
                    self.adl?.showMessage(var1: "Reconectando \(self.i)", var2: TerminalMessageType.WAIT_TIMEOUT_OCURRED)
                    self.tpc?.terminalDisplay(psMsg: "Reconectando \(self.i)", didTerminalDisplay: {(_) in
                        self.i = self.i+1
                        if self.connect() {
                            self.wsComm?.send(messageInBytes: ZoopTerminalPayment.chargeRetry!)
                        }
                        sleep(1)
                    })
                }

            } else {
                self.adl?.showMessage(var1: "Erro de conexao", var2: TerminalMessageType.ERROR)
            }
        }

        messageHandler?.stopTimer()
    }

    func connectionError() {
        if !paymentSucceeded {
            self.adl?.showMessage(var1: "Erro de conexão", var2: .ERROR)
            _ = tpc?.terminalClose(psIdleMsg: "Erro de conexao", didTerminalClose: {(_) in })
        }
        messageHandler?.stopTimer()
    }
}
