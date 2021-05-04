//
//  DeviceManager.swift
//  EMVConnectiOS
//
//  Created by Paulo Leal on 27/02/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation
import ExternalAccessory

public class DevicesManager: BtLeDeviceFinderProtocol, BtAccessoryDeviceFinderProtocol {

    public static let shared = DevicesManager()

    var deviceListener: DeviceProtocol?
    var userSelectedDevice: Device?

    let btLeDeviceFinder = BtLeDeviceFinder.shared
    let btAccessoryDeviceFinder = BtAccessoryDeviceFinder.shared

    private init() {
        Log(message: "Iniciando DevicesManager")

        btLeDeviceFinder.setDelegate(delegate: self)
        btAccessoryDeviceFinder.setDelegate(delegate: self)
    }

    public func setDeviceListener(deviceListener: DeviceProtocol) {
        self.deviceListener = deviceListener
    }

    public func selectDevice(device: Device) {
        self.userSelectedDevice = device
        self.userSelectedDevice?.setup()

        self.deviceListener?.deviceDidConnect(device: device)
        stopSearching()
    }

    public func getSelectedDevice() -> Device? {
        if self.userSelectedDevice != nil {
            //self.userSelectedDevice?.setup()
            return self.userSelectedDevice
        }

        if getConnectedDevicesList().count > 0 {
            getConnectedDevicesList()[0].setup()
            return getConnectedDevicesList()[0]
        }

        return nil
    }

    public func getConnectedDevicesList() -> [Device] {
        return btAccessoryDeviceFinder.getConnectedDevicesList() + btLeDeviceFinder.getConnectedDevicesList()
    }

    public func searchDevice() {
        btLeDeviceFinder.startScan()
        btAccessoryDeviceFinder.startScan()
    }

    public func stopSearching() {
        btLeDeviceFinder.cancelScan()
        btAccessoryDeviceFinder.cancelScan()
    }

    // ----

    public func btLeBluetoothDisabled() {
        print("Bluetooth desligado!")
    }

    public func btLeDidConnect(device: Device) {
        self.userSelectedDevice = device
    }

    public func btLeDidFindDevice(device: Device) {
        self.deviceListener?.devicesListDidUpdate()
    }

    // -----

    public func btAccessoryDidFindDevice(device: Device) {
        self.deviceListener?.devicesListDidUpdate()
    }

    public func btAccessoryDidConnect(device: Device) {
        self.selectDevice(device: device)
        device.setup()
    }

    public func btAccessoryDidDisconnect(device: Device) {
        self.userSelectedDevice = nil
        self.deviceListener?.deviceDidDisconnect(device: device)
    }
}
