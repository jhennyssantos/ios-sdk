//
//  WebsocketObserver.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 12/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public protocol WebsocketObserverProtocol {
    func onMessage(response: String)
}
