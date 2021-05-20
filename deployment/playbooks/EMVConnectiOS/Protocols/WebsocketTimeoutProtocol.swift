//
//  WebsocketTimeoutProtocol.swift
//  EMVConnectiOS
//
//  Created by Thiago Mainente de S. G. Gomes on 11/13/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public protocol WebsocketTimeoutProtocol {
    func retryConnection()
    func connectionError()
}
