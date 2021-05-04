//
//  ReceiptSendType.swift
//  EMVConnectiOS
//
//  Created by Alexsander Rocha on 04/01/2018.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public enum ReceiptSendType: Int {
    case email = 1
    case sms = 2
    case defaultType = 3
}
