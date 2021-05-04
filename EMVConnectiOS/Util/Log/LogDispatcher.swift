//
//  LogPersistence.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino on 2/9/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

public class LogDispatcher: WebsocketObserverProtocol, WebsocketTimeoutProtocol {

    public static let sharedInstance = LogDispatcher()
    private var logFilePath: URL?

    private init() {
        let file = "transaction_log.txt" //this is the file. we will write to and read from it

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            logFilePath = dir.appendingPathComponent(file)
        }
    }

    public func onMessage(response: String) {
        print("LOGGER RESPONSE: \(response)")

        if response == "LOG0" {
            LogDispatcher.sharedInstance.eraseLog()
        }
    }

    public func retryConnection() {

    }

    public func connectionError() {
        print("Logger connection error")
    }

    public func eraseLog() {
        if let filePath = logFilePath {
            do {
                Log(message: "Will erase the file: \(filePath.absoluteString)")

                try FileManager.default.removeItem(atPath: filePath.absoluteString)
            } catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }
    }

    public func dispatchLog() {
        if let filePath = logFilePath {
            Log(message: "Will create the file: \(filePath.absoluteString)")

            //reading
            do {
                let logText = try String(contentsOf: filePath, encoding: .utf8)

                if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                    let deviceId = uuid
                    let host = Url.getLogUrl() + "\(deviceId)"
                 
                    Log(message: "Connecting to logs host: \(host)")

                    let wsComm = WebsocketComm(hostURL: host, observer: self, observerTimeout: self)
                    wsComm.websocket.open()

                    Log(message: "Connection opened: \(host)")

                    let messageSize = String(format: "%04d", logText.count + 3).utf8

                    Log(message: "Message size: \(messageSize)")

                    let messageToBeSent = "LOG\(messageSize)||\(logText)"
                    Log(message: "Message to be sent: \(messageToBeSent)")

                    wsComm.send(message: messageToBeSent)
                }
            } catch {
                print("Logger exception")
            }
        }
    }
}
