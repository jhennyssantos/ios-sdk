//
//  EMVConnectiOSTests.swift
//  EMVConnectiOSTests
//
//  Created by Carla Galdino Wanderley on 10/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import XCTest
@testable import EMVConnectiOS

class EMVConnectiOSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testTerminalProtocolBuildMessage() {
        let terminalProtocol = TerminalProtocolChannel.shared
        
        let sInputCommandBuffer = "OPN"
        let bufferOut = terminalProtocol.buildMessage(inputString: sInputCommandBuffer)
        let expectedBufferOut:[Int8] = [22, 79, 80, 78, 23, -88, -87]
        let uintArray = expectedBufferOut.map { UInt8(bitPattern: $0) }
        
        let intArray = uintArray.map { Int8(bitPattern: $0) }
        
        XCTAssertEqual(expectedBufferOut, intArray)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
