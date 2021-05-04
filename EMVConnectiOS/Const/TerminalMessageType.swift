//
//  TerminalMessageType.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 17/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

@objc public enum TerminalMessageType: Int {
    case ACTION
    case ACTION_INSERT_CARD
    case ACTION_ENTER_PIN
    case ACTION_SWIPE_MAGSTRIPE
    case ACTION_INSERT_CHIP_CARD
    case ACTION_INPUT_DEVICE_KEYPAD
    case ACTION_INPUT_SIGNATURE
    case ACTION_OTHER
    case ACTION_REMOVE_CARD
    case TRANSACTION_APPROVED
    case TRANSACTION_DENIED
    case TRANSACTION_APPROVED_REMOVE_CARD
    case TRANSACTION_DENIED_REMOVE_CARD
    case TRANSACTION_CANCELLED
    case TRANSACTION_CANCELLED_REMOVE_CARD
    case ERROR
    case CANCELLED
    case INTERROGATION
    case EXCLAMATION
    case WAIT
    case WAIT_PROCESSING
    case WAIT_INITIALIZING
    case WAIT_COMMUNICATION
    case WAIT_TIMEOUT_PRETIMEOUT_WARNING
    case WAIT_TIMEOUT_OCURRED
    case WAIT_BLUETOOTH_CONNECTING
    case WAIT_BLUETOOTH_CONNECTED
    case WAIT_FIRST_TERMINAL_CONFIG

    /*
     init?(raw: Int) {
     self.init(raw: raw)
     }
     */
}
