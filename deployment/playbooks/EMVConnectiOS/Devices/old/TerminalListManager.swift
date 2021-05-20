////
////  MPOSCommunicationHandler.swift
////  EMVConnectiOS
////
////  Created by Carla Galdino Wanderley on 11/10/17.
////  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
////
//
//import Foundation
//import ExternalAccessory
//
//public class TerminalListManagerOld {
//
//    var connectionCallback: (String) -> Void
//    var disconnectionCallback: (String) -> Void
//    var eaSessionController: EADSessionController
//    var supportedProtocolsStrings = [String]()
//    var currentAccessory: EAAccessory?
//    var currentAccessoryIdentifier: String?
//    var terminalListener: TerminalListManagerProtocolOld?
//
//    public static let shared = TerminalListManagerOld()
//
//    private init() {
//        Log(message: "Iniciando TerminalListManager")
//        connectionCallback = {_ in }
//        disconnectionCallback = {_ in }
//        eaSessionController = EADSessionController.shared()
//
//        let supportedStringsArray = Bundle.main.object(forInfoDictionaryKey: "UISupportedExternalAccessoryProtocols")
//        supportedProtocolsStrings = supportedStringsArray as! [String]
//
//        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidConnect), name: .EAAccessoryDidConnect, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidDisconnect), name: .EAAccessoryDidDisconnect, object: nil)
//
//        EAAccessoryManager.shared().registerForLocalNotifications()
//    }
//
//    public func getAccessoryList() -> [EAAccessory] {
//        return EAAccessoryManager.shared().connectedAccessories
//    }
//
//    public func setTerminalListener(listener: TerminalListManagerProtocolOld) {
//        self.terminalListener = listener
//    }
//
//    public func bluetoothPairingCallback(error: Error?) {
//        if let _error = error {
//            print(_error.localizedDescription)
//        }
//    }
//
//    public func startTerminalsDiscovery() {
//        if self.getAccessoryList().count == 0 {
//
//            EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: nil, completion: bluetoothPairingCallback)
//        }
//
//        if self.getAccessoryList().count == 1 {
//            TerminalListManagerOld.shared.registerCurrentAccessory(accessory: self.getAccessoryList()[0])
//            self.terminalListener?.deviceSelectedResult(terminalIdentifier: self.getAccessoryList()[0].name)
//        }
//    }
//
//    //TODO: Salvar observer para que não seja necessário enviar no método de remoção
//    public func startTerminalsDiscovery(_ observer: Any, connected uiUpdaterDeviceConnected: @escaping (_ deviceName: String) -> Void, disconnected         uiUpdaterDeviceDisconnected: @escaping (_ deviceName: String) -> Void) {
//        Log(message: "Starting terminal discovery")
//
//        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidConnect), name: .EAAccessoryDidConnect, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidDisconnect), name: .EAAccessoryDidDisconnect, object: nil)
//
//        EAAccessoryManager.shared().registerForLocalNotifications()
//
//        connectionCallback = uiUpdaterDeviceConnected
//
//        disconnectionCallback = uiUpdaterDeviceDisconnected
//    }
//
//    public func stopTerminalsDiscovery(_ observer: Any) {
//        Log(message: "Stopping terminal discovery")
//        NotificationCenter.default.removeObserver(observer, name: .EAAccessoryDidConnect, object: nil)
//        NotificationCenter.default.removeObserver(observer, name: .EAAccessoryDidDisconnect, object: nil)
//    }
//
//    private func registerCurrentAccessory(accessory: EAAccessory) {
//        self.currentAccessory = accessory
//        self.currentAccessoryIdentifier = (currentAccessory?.manufacturer)! + "-" + (currentAccessory?.serialNumber)!
//        eaSessionController.setupController(for: accessory, withProtocolString: "com.paxsz.iPOS")
//    }
//
//    public func checkIfTerminalIsConnectedAndRegister(terminalToCheckIdentifier: String) -> Bool {
//
//        for accessory in self.getAccessoryList() {
//            let accessoryIdentifier = (accessory.manufacturer) + "-" + (accessory.serialNumber)
//
//            if (terminalToCheckIdentifier == accessoryIdentifier) {
//                registerCurrentAccessory(accessory: accessory)
//                return true
//            }
//        }
//
//        return false
//    }
//
//    public func checkIfTerminalNameIsAZoopTerminalAndIsConnected(deviceId: String) -> Bool {
//
//        if let deviceIds = APISettings.sharedInstance.getParameterNamesByString(sParameterNameToMatch: "ZTL#", bForceGlobalParameter: true) {
//
//            var accessoryAlreadyConnected = false
//
//            for accessory in self.getAccessoryList() {
//                let accessoryIdentifier = (accessory.manufacturer) + "-" + (accessory.serialNumber)
//
//                if (deviceIds.contains(accessoryIdentifier)) {
//                    accessoryAlreadyConnected = true
//                }
//            }
//
//            return accessoryAlreadyConnected
//        }
//
//        return false
//    }
//
//    @objc func accessoryDidConnect(_ notification: Notification) {
//        print("FW terminal connected")
//        let connectedAccessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory
//        let sessionController = EADSessionController.shared()
//        sessionController?.setupController(for: connectedAccessory, withProtocolString: "com.paxsz.iPOS")
//        let accessoryName = (connectedAccessory?.manufacturer)! + "-" + (connectedAccessory?.serialNumber)!
//
//        if connectedAccessory != nil {
//            connectionCallback(accessoryName)
//            terminalListener?.posDidConnect(accessoryName: accessoryName)
//        }
//
//        //        if terminalListManager.checkIfTerminalNameIsAZoopTerminalAndIsConnected(deviceId: accessoryName) {
//    }
//
//    @objc func accessoryDidDisconnect(_ notification: Notification) {
//        print("FW terminal disconnected")
//        let disconnectedAccessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory
//        let disconnectedAccessoryName = disconnectedAccessory?.name
//
//        print("Removendo acessorio: %@", disconnectedAccessoryName!)
//        disconnectionCallback(disconnectedAccessoryName!)
//        terminalListener?.posDidDisconnect(accessoryName: disconnectedAccessoryName!)
//    }
//
//    public func registerAZoopTerminal(deviceId: String) {
//        APISettings.sharedInstance.addParameterForName(sParameterNameToMatch: "ZTL#", value: deviceId)
//    }
//
//    public func getCurrentSelectedZoopTerminal() -> EAAccessory? {
//        return self.currentAccessory
//    }
//
//    public func getCurrentTerminalIdentifier() -> String {
//        if let identifier = self.currentAccessoryIdentifier {
//            return identifier
//        }
//
//        Log(message: "ERROR - CURRENT ACCESSORY IDENTIFIER IS NULL")
//        return ""
//    }
//}
