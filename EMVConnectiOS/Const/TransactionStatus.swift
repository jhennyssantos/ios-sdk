//
//  TransactionStatus.swift
//  EMVConnectiOS
//
//  Created by Alexsander Rocha on 08/01/2018.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public enum TransactionStatus: Int {
    case all, succeeded, failed, canceled
}
