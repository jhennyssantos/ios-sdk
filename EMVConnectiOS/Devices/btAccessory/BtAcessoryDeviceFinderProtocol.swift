//
//  BtAcessoryDeviceFinderProtocol.swift
//  EMVConnectiOS
//
//  Created by Paulo Leal on 02/03/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

public protocol BtAccessoryDeviceFinderProtocol {
    //    func btLeBluetoothDisabled()
    func btAccessoryDidConnect(device: Device)
    func btAccessoryDidDisconnect(device: Device)
    func btAccessoryDidFindDevice(device: Device)
}
