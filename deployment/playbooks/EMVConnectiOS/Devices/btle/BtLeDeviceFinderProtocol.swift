//
//  BleDeviceFinderProtocol.swift
//  EMVConnectiOS
//
//  Created by Paulo Leal on 02/03/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol BtLeDeviceFinderProtocol {
    func btLeBluetoothDisabled()
    func btLeDidConnect(device: Device)
    func btLeDidFindDevice(device: Device)
}
