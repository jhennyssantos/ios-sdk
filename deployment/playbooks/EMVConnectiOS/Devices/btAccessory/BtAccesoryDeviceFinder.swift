//
//  BtAccesoryDeviceFinder.swift
//  EMVConnectiOS
//
//  Created by Paulo Leal on 02/03/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

class BtAccessoryDeviceFinder {
    public static let shared = BtAccessoryDeviceFinder()

    private var delegate: BtAccessoryDeviceFinderProtocol?

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidConnect), name: .EAAccessoryDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidDisconnect), name: .EAAccessoryDidDisconnect, object: nil)

        EAAccessoryManager.shared().registerForLocalNotifications()
    }

    public func setDelegate(delegate: BtAccessoryDeviceFinderProtocol) {
        self.delegate = delegate
    }

    func startScan() {
    }

    func cancelScan() {
        //        NotificationCenter.default.removeObserver(self, name: .EAAccessoryDidConnect, object: nil)
        //        NotificationCenter.default.removeObserver(self, name: .EAAccessoryDidDisconnect, object: nil)
        //
        //        EAAccessoryManager.shared().unregisterForLocalNotifications()
    }

    func deviceFromAccessory(eaAccessory: EAAccessory) -> BtAccessoryDevice {
        let name = "\(eaAccessory.manufacturer)-\(eaAccessory.serialNumber)"
        return BtAccessoryDevice(name: name, serialNumber: eaAccessory.serialNumber, manufacturer: eaAccessory.manufacturer)
    }

    func getConnectedDevicesList() -> [Device] {
        return EAAccessoryManager.shared().connectedAccessories.map { deviceFromAccessory(eaAccessory: $0) }
    }

    @objc func accessoryDidConnect(_ notification: Notification) {
        print("FW terminal connected")

        let connectedAccessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory

        let device = deviceFromAccessory(eaAccessory: connectedAccessory!)

        print("Adicionando acessorio: \(device.getName())")
        self.delegate?.btAccessoryDidFindDevice(device: device)
    }

    @objc func accessoryDidDisconnect(_ notification: Notification) {
        print("FW terminal disconnected")
        let disconnectedAccessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory

        let device = deviceFromAccessory(eaAccessory: disconnectedAccessory!)

        print("Removendo acessorio: \(device.getName())")
        self.delegate?.btAccessoryDidDisconnect(device: device)

    }
}
