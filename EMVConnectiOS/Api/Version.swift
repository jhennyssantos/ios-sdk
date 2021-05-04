//
//  Version.swift
//  EMVConnectiOS
//
//  Created by Ana Vidal on 19/12/2017.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public class Version: NSObject {

    @objc public override init() {

    }

    @objc static func getBuildNumber() -> String {
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return buildNumber
    }

    @objc static func getVersionNumber() -> String {
        
        guard Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") != nil else {
            return "ERROR GETTING VERSION"
        }

        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    @objc public static func getVersion() -> String {
        return String(format: "Zoop iOS SDK %@_b%@", Version.getVersionNumber(), Version.getBuildNumber())
    }
}
