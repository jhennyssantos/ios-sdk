//
//  DeviceFinder.swift
//  EMVConnectiOS
//
//  Created by Paulo Leal on 28/02/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BtLeDeviceFinder: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    public static let shared = BtLeDeviceFinder()

    var centralManager: CBCentralManager!
    var _timer = Timer()

    var _peripheral: CBPeripheral?

    private var delegate: BtLeDeviceFinderProtocol?
    private var devicesList: [BtLeDevice] = []

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    public func setDelegate(delegate: BtLeDeviceFinderProtocol) {
        self.delegate = delegate
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            if central.state != CBManagerState.poweredOn {
                print("Bluetooth DisaBtLed- Make sure your Bluetooth is turned on")
                self.delegate?.btLeBluetoothDisabled()
                cancelScan()
            }
        }
    }

    /*
     Chamado quando um device é descoberto durante o scan
     */
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let peripheralName = peripheral.name ?? ""

        //        print("Found new pheripheral devices with services")
        //        print("Peripheral name: \(peripheralName)")
        //        print("**********************************")
        //        print ("Advertisement Data : \(advertisementData)")

        self._peripheral = peripheral
        self._peripheral?.delegate = self

        let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool

        if (isConnectable && (peripheralName.contains("-"))) {
            let device = self.deviceFromPeripheral(peripheral: peripheral, withCharacteristics: nil)

            if (self.devicesList.first(where: {$0.name == device.getName()}) == nil) {
                self.devicesList.append(device)
                self.delegate?.btLeDidFindDevice(device: device)
            }
        }
    }

    func deviceFromPeripheral(peripheral: CBPeripheral, withCharacteristics: [CBCharacteristic]?) -> BtLeDevice {
        let components = peripheral.name!.components(separatedBy: "-")
        return BtLeDevice(name: peripheral.name!, serialNumber: components[1], manufacturer: components[0], peripheral: peripheral, cBCentralManager: self.centralManager, characteristics: withCharacteristics)
    }

    func getConnectedDevicesList() -> [Device] {
        return self.devicesList
    }

    /*
     Chamado quando um device é conectado. (parar o scan)
     */
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to \(peripheral.name!)")
        peripheral.discoverServices(nil)
        cancelScan()
    }

    /*
     Chamado quando um device é identificado pelos seus serviços.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if (service.uuid == CBUUID(string: BtleDevicesUUID.PAX_D150_UUID)) { //Lista das maquinas BTLE suportadas
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING CHARACTERISTICS: \(String(describing: error?.localizedDescription))")
            return
        }

        let device = deviceFromPeripheral(peripheral: peripheral, withCharacteristics: service.characteristics)
        self.delegate?.btLeDidConnect(device: device)

        print("============================================================")
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                peripheral.discoverDescriptors(for: characteristic)
                print(characteristic.uuid.uuidString)
            }
        }
        print("============================================================")
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print()
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        (DevicesManager.shared.getSelectedDevice() as! BtLeDevice).btLeDidUpdateCharacteristic(characteristic: characteristic)
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print()
    }

    func startScan() {
        if #available(iOS 10.0, *) {
            if (!self.centralManager.isScanning) {
                print("Now Scanning...")
                var c = 0
                self._timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer: Timer) in
                    c += 1
                    print("scanning... \(c)")
                    self.centralManager.scanForPeripherals(withServices: nil, options: nil)
                }
            }
        }
    }

    func cancelScan() {
        if #available(iOS 10.0, *) {
            self._timer.invalidate()
            self.centralManager?.stopScan()
            print("Scan Stopped")
        }
    }

}
