//
//  TerminalPaymentProtocol.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 17/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public protocol TerminalPaymentProtocol {
    func paymentFailed(var1: AnyObject)
    func paymentSuccessful(var1: AnyObject)
    func paymentAborted()
    func cardholderSignatureRequested()
    func currentChargeCanBeAbortedByUser(var1: Bool)
    func signatureResult(var1: Int)
}
