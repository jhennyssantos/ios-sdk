//
//  BtAccessoryDevice.swift
//  EMVConnectiOS
//
//  Created by Paulo Leal on 02/03/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation
import ExternalAccessory

class BtAccessoryDevice: Device {
    public let name: String
    public let serialNumber: String
    public let manufacturer: String

    private var _isOpen: Bool = false

    init(name: String, serialNumber: String, manufacturer: String) {
        self.name = name
        self.serialNumber = serialNumber
        self.manufacturer = manufacturer
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
        let possibleAccessories = EAAccessoryManager.shared().connectedAccessories.filter { $0.serialNumber == self.serialNumber}
        
        if possibleAccessories.count > 0 {
            let connectedAccessory = possibleAccessories[0]
            let manufacturerName = connectedAccessory.manufacturer.lowercased()
            
            if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                let myDict = NSDictionary(contentsOfFile: path) {
                
                let protocols:NSArray = myDict.object(forKey: "UISupportedExternalAccessoryProtocols") as! NSArray
                
                let sessionController = EADSessionController.shared()
                
                for comProtocol in protocols {
                    let strComProtocol = comProtocol as! String
                    if strComProtocol.range(of: manufacturerName) != nil {
                        sessionController?.setupController(for: connectedAccessory, withProtocolString: strComProtocol)
                    }
                }
            }
        }
    }

    func open() {
        //        print("BtAccessoryDevice::open")
        if (EADSessionController.shared().getSession() == nil) {
            self._isOpen = true
            EADSessionController.shared().openSession()
        }
    }

    func close() {
        //        print("BtAccessoryDevice::close")
        if (EADSessionController.shared().getSession() != nil) {
            self._isOpen = false
            EADSessionController.shared().closeSession()
        }
    }

    func isAvailable() -> Bool {
        return self.isAvailable(timeout: 1000)
    }

    func write(data: Data) {
        print("BtAccessoryDevice::write -> data: \(data)")
        EADSessionController.shared().write(data)
    }

    private func isAvailable(timeout: Int) -> Bool {
        let initialTime = Int(Date().timeIntervalSince1970)

        if EADSessionController.shared().getSession() == nil {
            return false
        }

        var hasByteAvailable = true
        if let isByteAvailable = EADSessionController.shared().getSession().inputStream?.hasBytesAvailable {
            hasByteAvailable = isByteAvailable
            while(hasByteAvailable == false) {
                hasByteAvailable = EADSessionController.shared().getSession().inputStream?.hasBytesAvailable ?? false

                if (Int(Date().timeIntervalSince1970) - initialTime) > (timeout / 1000) {
                    return false
                }
            }

            return true
        }

        return true
    }

    func read(len: Int, onComplete: (Data) -> Void) {
        //        print("BtAccessoryDevice::read")

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        if (isAvailable(timeout: 1000)) {
            EADSessionController.shared().getSession().inputStream?.read(buffer, maxLength: len)
        }

        onComplete(Data(bytes: buffer, count: len))

    }

    func readCRCData(onComplete: ([UInt8]) -> Void) {
        var bufferIn = [UInt8]()
        //        clearBuffer()

        let ETB = UInt8(23)

        while (!isAvailable(timeout: 1000)) { }

        var etbHit: Bool = false
        var c: Int = 0

        while (c <= 2) {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
            EADSessionController.shared().getSession().inputStream?.read(buffer, maxLength: 1)

            let b = buffer[0]
            if b == 0 {
                continue
            }
            
            if (b == ETB) {
                etbHit = true
            }

            if (etbHit) {
                c = c + 1
            }

            bufferIn.append(b)
        }

        onComplete(bufferIn)
    }

    func clearBuffer() {
        print("BtAccessoryDevice::clearBuffer")
        let len: Int = 99999
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        EADSessionController.shared().getSession().inputStream?.read(buffer, maxLength: len)
    }

    func isOpen() -> Bool {
        //        print("BtAccessoryDevice::isOpen")
        return self._isOpen
    }
}
