//
//  BtLeDevice.swift
//  EMVConnectiOS
//
//  Created by Paulo Leal on 04/03/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation
import CoreBluetooth

class BtLeDevice: Device {

    public let name: String
    public let serialNumber: String
    public let manufacturer: String
    private let peripheral: CBPeripheral
    private let cBCentralManager: CBCentralManager
    private let writeCharacteristic: CBCharacteristic?
    private let readCharacteristic: CBCharacteristic?

    private var buffer: UnsafeMutablePointer<UInt8>
    private var _isOpen: Bool = false

    init(name: String, serialNumber: String, manufacturer: String, peripheral: CBPeripheral,
         cBCentralManager: CBCentralManager,
         characteristics: [CBCharacteristic]?) {
        self.name = name
        self.serialNumber = serialNumber
        self.manufacturer = manufacturer

        self.peripheral = peripheral
        self.cBCentralManager = cBCentralManager
        self.writeCharacteristic = characteristics?.first(where: {$0.uuid == CBUUID(string: BtleDevicesUUID.PAX_D150_WRITE_CHARACTERISTICS)})
        self.readCharacteristic = characteristics?.first(where: {$0.uuid == CBUUID(string: BtleDevicesUUID.PAX_D150_READ_CHARACTERISTICS)})
        self.buffer = UnsafeMutablePointer.allocate(capacity: 10000)
    }

    func getName() -> String {
        return self.name
    }

    func getSerialNumber() -> String {
        return self.serialNumber
    }

    func getManufacturer() -> String {
        return self.manufacturer
    }

    func setup() {
        self.cBCentralManager.connect(self.peripheral, options: nil)
    }

    func open() {
        self._isOpen = true
    }

    func close() {
        self._isOpen = false
    }

    func write(data: Data) {
        if (self.writeCharacteristic != nil) {
            self.peripheral.writeValue(data, for: self.writeCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
    }

    private func getBufferData() -> Data {
        return Data(buffer: UnsafeMutableBufferPointer.init(start: self.buffer, count: 628))
    }

    func read(len: Int, onComplete: (Data) -> Void) {
        //        InputStream(data: getBufferData()).read(buffer, maxLength: len)
        if (self.readCharacteristic != nil) {
            self.peripheral.readValue(for: self.readCharacteristic!)
        }
    }

    func readCRCData(onComplete: ([UInt8]) -> Void) {

    }

    func isAvailable() -> Bool {
        return false
    }

    func isOpen() -> Bool {
        return self._isOpen
    }

    func clearBuffer() {

    }

    func btLeDidUpdateCharacteristic(characteristic: CBCharacteristic) {
        let value = characteristic.value!

        //        if (!value.isEmpty) {
        value.copyBytes(to: self.buffer, count: value.count)
        //            print("==> btLeDidUpdateCharacteristic = \(value.count) - \(value.base64EncodedString())")
        //        }
        //
        //        if #available(iOS 10.0, *) {
        //            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer: Timer) in
        //                if (self.isOpen()) {
        //                    self.peripheral.readValue(for: characteristic)
        //                }
        //            }
        //        }
    }
}
