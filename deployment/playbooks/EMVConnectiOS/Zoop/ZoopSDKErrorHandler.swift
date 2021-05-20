//
//  ZoopSDKLog.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino on 2/9/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public class ZoopSDKErrorHandler: NSObject {

    public static let sharedInstance = ZoopSDKErrorHandler()

    private override init() {}

    public func notifyFailure() {
        LogDispatcher.sharedInstance.dispatchLog()
    }

}
