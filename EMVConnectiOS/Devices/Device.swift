//
//  Device.swift
//  EMVConnectiOS
//
//  Created by Paulo Leal on 27/02/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol Device {
    func getName() -> String
    func getSerialNumber() -> String
    func getManufacturer() -> String
    func setup()

    // -----

    func open()
    func close()
    func isOpen() -> Bool

    func isAvailable() -> Bool
    func write(data: Data)
    func read(len: Int, onComplete: (Data) -> Void)
    func readCRCData(onComplete: ([UInt8]) -> Void)
    func clearBuffer()
}

public extension Device {

}
