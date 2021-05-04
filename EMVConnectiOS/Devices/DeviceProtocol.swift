//
//  DeviceManagerProtocol.swift
//  EMVConnectiOS
//
//  Created by Paulo Leal on 27/02/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

public protocol DeviceProtocol {
    //    func deviceSelectedResult(terminalIdentifier: String)
    func devicesListDidUpdate()
    func deviceDidConnect(device: Device)
    func deviceDidDisconnect(device: Device)
}
