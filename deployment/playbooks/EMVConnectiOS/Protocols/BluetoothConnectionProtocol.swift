//
//  BluetoothConnectionProtocol.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 22/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public protocol BluetoothConnectionProtocol {
    func sendMessage(bytes: [Int8])
    func readBytesAvailable() -> UInt
    func readData(bytesToRead: UInt) -> Data
}
