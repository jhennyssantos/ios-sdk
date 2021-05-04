//
//  WebsocketComm.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 12/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

class WebsocketComm {

    public var websocket: WebSocket
    var observer: WebsocketObserverProtocol?
    var observerTimeout: WebsocketTimeoutProtocol?

    public init(hostURL: String, observer: WebsocketObserverProtocol, observerTimeout: WebsocketTimeoutProtocol) {
        Log(message: "Starting websocket")

        Log(message: hostURL)

        self.observer = observer
        self.observerTimeout = observerTimeout

        websocket = WebSocket(hostURL)
        websocket.event.open = {
            Log(message: "opened")

        }
        websocket.event.close = { code, reason, clean in
            print("[WEBSOCKET] close...")
            print("[WEBSOCKET] Code \(code)")
            print("[WEBSOCKET] Reason \(reason)")
            print("[WEBSOCKET] Clean \(clean)")
            if code == 1006 {
                self.observerTimeout?.connectionError()
            }
        }

        websocket.event.end = { code, reason, wasClean, error in
            print("[WEBSOCKET] end...")
            print("[WEBSOCKET] Code \(code)")
            print("[WEBSOCKET] Reason \(reason)")
            print("[WEBSOCKET] WasClean \(wasClean)")
            print("[WEBSOCKET] Error \(String(describing: error))")
        }

        websocket.event.error = { error in
            Log(message: "error \(error)")
            let sError = "\(error)"
            if sError.contains("Network") {
                observerTimeout.retryConnection()
            }
        }

        websocket.event.message = { message in

            let dataBytes = message as! Array<Swift.UInt8>
            //            let datastring = NSString(bytes: message as! Array<Swift.UInt8>, length: dataBytes.count, encoding: String.Encoding.utf8.rawValue)
            let datastring = String(data: Data(bytes: dataBytes), encoding: .utf8)

            if let text = datastring as String? {
                Log(message: "[WEBSOCKET] recv: \(text)")
                self.observer?.onMessage(response: text)
            }
        }
    }

    public func send(message: String) {
        Log(message: "[WEBSOCKET] send: \(message)")
        websocket.send(message.utf8)
    }

    public func send(messageBytes: String) {
        let buf = [UInt8](messageBytes.utf8)
        Log(message: "[WEBSOCKET] send: \(messageBytes)")
        websocket.send(buf)
    }

    public func send(messageInBytes: [UInt8]) {
        //        Log(message: "[WEBSOCKET] send: \(messageInBytes)")
        Log(message: "[WEBSOCKET] send: \(String(data: Data(bytes: messageInBytes), encoding: .utf8)!)")
        websocket.send(messageInBytes)
    }

}
