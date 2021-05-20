//
//  BluetoothNotificationProtocol.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 25/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

public protocol BluetoothNotificationProtocol {
    func dataReceived(data: Data)
}
