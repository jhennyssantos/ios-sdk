//
//  VoidTransactionProtocol.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 17/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public protocol VoidTransactionProtocol {
    func voidTransactionSuccessful(var1: AnyObject)
    func voidTransactionFailed(var1: AnyObject)
    func currentVoidTransactionCanBeAbortedByUser(var1: Bool)
}
