//
//  ApplicationDisplayProtocol.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 17/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public protocol ApplicationDisplayProtocol {
    func showMessage(var1: String, var2: TerminalMessageType)
    func showMessage(var1: String, var2: TerminalMessageType, var3: String)
}
