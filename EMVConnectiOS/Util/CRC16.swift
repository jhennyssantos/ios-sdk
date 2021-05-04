//
//  CRC16.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 12/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

//
//  CRC16.swift
//  CRC16
//
//  Created by LimChihi on 11/30/16.
//  Copyright © 2016 linzhiyi. All rights reserved.
//
import Foundation

class CRC16 {
    private var crcTable: [Int] = []
    /// Seed, You should change this seed.
    private let gPloy = 0x0000

    init() {
        computeCrcTable()
    }

    public func getCurrentCRC(bufferIn: [UInt8], bytes: Int) -> Int {
        let msb = bufferIn[bytes - 2]
        let lsb = bufferIn[bytes - 1]
        let shiftedMSB = (Int(msb) & 0xff) << 8

        let result = (shiftedMSB + Int(lsb & 0xff))
        return result
    }

    public func getCRCBytes_V2(crc: Int) -> [UInt8] {
        var result = [UInt8]()
        result.append(UInt8((crc & 0xff00) >> 8))
        result.append(UInt8(crc & 0xff))
        return result
    }

    func getCRCBytes (data: [UInt8]) -> [UInt8] {
        var crc = calcCRC16(data: data)
        var crcArr: [UInt8] = [0, 0]
        ////        Swift3.0
        //        for i in (0..<2).reversed() {
        //
        //        }
        for i in (0..<2).reversed() {
            crcArr[i] = UInt8(crc % 256)
            crc >>= 8
        }

        return crcArr
    }

    /**
     Generate CRC16 Code of 0-255
     */
    private func computeCrcTable() {
        for i in 0..<256 {
            crcTable.append(getCrcOfByte(aByte: i))
        }
    }

    private func getCrcOfByte(aByte: Int) -> Int {
        var value = aByte << 8
        for _ in 0 ..< 8 {
            if (value & 0x8000) != 0 {
                value = (value << 1) ^ gPloy
            } else {
                value = value << 1
            }
        }

        value = value & 0xFFFF //get low 16 bit value

        return value
    }

    public func calcCRC16_v2(buffer: [UInt8]) -> Int {
        let CRC_MASK = 4129
        var crc = 0
        var wData = 0
        var i = 0
        while (i < buffer.count) {
            wData = Int(buffer[i])
            wData = wData << 8
            //wData <<= 8
            wData = wData & 0xffff
            //wData &= 0xffff
            var j = 0
            while (j < 8) {
                if (((crc ^ wData) & 0x8000) != 0) {
                    let temp = crc << 1 & 0xffff
                    crc = temp ^ CRC_MASK
                } else {
                    crc = crc << 1
                    //crc <<= 1
                }
                crc = crc & 0xffff
                //crc &= 0xffff
                wData = wData << 1
                //wData <<= 1
                wData = wData & 0xffff
                //wData &= 0xffff
                j = j + 1
            }
            i = i + 1
        }
        crc = crc & 0xffff
        //crc &= 0xffff
        return crc
    }

    func calcCRC16(data: [UInt8]) -> UInt16 {
        var crc = 0
        let dataInt: [Int] = data.map {Int( $0) }

        let length = data.count

        for i in 0 ..< length {
            crc = ((crc & 0xFF) << 8) ^ crcTable[(((crc & 0xFF00) >> 8) ^  dataInt[i]) & 0xFF]
        }

        crc = crc & 0xFFFF
        return UInt16(crc)
    }

}
