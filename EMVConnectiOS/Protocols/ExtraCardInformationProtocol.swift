//
//  ExtraCardInformationProtocol.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 17/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public protocol ExtraCardInformationProtocol {
    func cardLast4DigitsRequested()
    func cardExpirationDateRequested()
    func cardCVCRequested()
}
