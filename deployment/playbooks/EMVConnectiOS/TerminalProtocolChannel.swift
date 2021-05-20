//
//  TerminalProtocolChannel.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 12/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation
import ExternalAccessory

@objc public class TerminalProtocolChannel: NSObject {
    
    let EOT = UInt8(4)
    let ACK = UInt8(6)
    let NAK = UInt8(21)
    let SYN = UInt8(22)
    let ETB = UInt8(23)
    let CAN = UInt8(24)
    let TIMEOUT = UInt8(34)
    var timer: Timer?
    var inputTimer: Timer?
    
    var readTimeoutReached: Bool = false
    var readInputTimeoutReached: Bool = false
    
    var dataInput: Data?
    var totalBytesRead: UInt = 0
    var dataAvailable = false
    
    let semaphore = DispatchSemaphore(value: 1)
    
    static let shared = TerminalProtocolChannel()
    
    private override init() {
        Log(message: "Starting protocol channel")
    }
    
    public func terminalOpen(didTerminalOpen: (Int) -> Void) {
        sendACommand(sInputCommand: "OPN", isAsync: false, didSendACommand: {(sbOut: [UInt8]?, returnCode: UInt8) in
            Log(message: String(format: "Terminal open response: ", Int(returnCode)))
            didTerminalOpen(Int(returnCode))
        })
    }
    
    public func terminalClose(psIdleMsg: String, didTerminalClose: (Int) -> Void) {
        let message = psIdleMsg.count <= 32 ? psIdleMsg : psIdleMsg.substring(firstIndex: 0, lastIndex: 32)
        let command: String = "CLO" + getLength(sMessage: message) + message
        sendACommand(sInputCommand: command, isAsync: false, didSendACommand: {(sbOut: [UInt8]?, returnCode: UInt8) in
            Log(message: String(format: "Terminal close response: ", Int(returnCode)))
            didTerminalClose(Int(returnCode))
        })
    }
    
    public func sendACommand(sInputCommand: String, isAsync: Bool, didSendACommand: ([UInt8]?, UInt8) -> Void) {
        
        cleanInputBuffer()
        
        sendToTerminal(sInputCommandBuffer: sInputCommand, isAsync: isAsync, didSendToTerminal: {(sbOutputTemp: [UInt8]?, rc: UInt8) in
           // print("sendACommand sInputCommand-> \(sInputCommand)")
         //   print("sendACommand sbOutputTemp-> \(sbOutputTemp) rc -> \(rc)")
            var returnCode: UInt8 = 0
            var _sbOut = sbOutputTemp ?? []
            let result = String(data: Data(bytes: _sbOut), encoding: .utf8)!
            
            
           // print("sendACommand _sbOut-> \(_sbOut)")
          //  print("sendACommand result-> \(result)")
          //  print("sendACommand result count -> \(result.count)")
           
            if(sbOutputTemp == nil){
                returnCode = PP.PP_INTERR.rawValue
            }
            
            if (result.count > 9) {
                let strSub = result.substring(firstIndex: 9, lastIndex: result.count)
                let byteResult: [UInt8] = [UInt8](strSub.utf8)
                _sbOut = byteResult
            }
            
            if (result.substring(firstIndex: 0, lastIndex: 3) == "NTM") {
                returnCode = PP.PP_NOTIFY.rawValue
            }
            
            if (result.elementsEqual("GDU042")) {
                returnCode = PP.PP_ERRPIN.rawValue
            }
            
            didSendACommand(_sbOut, returnCode)
        })
    }
    
    private func validateCommandLenght(sInputCommand: String) -> String {
        
        let startIndex = sInputCommand.index(sInputCommand.startIndex, offsetBy: 3)
        let endIndex = sInputCommand.index(sInputCommand.startIndex, offsetBy: 6)
        let length = String(sInputCommand[startIndex..<endIndex])
        
        let sIndex = sInputCommand.index(sInputCommand.startIndex, offsetBy: 6)
        let eIndex = sInputCommand.index(sInputCommand.startIndex, offsetBy: sInputCommand.count)
        let newString = String(sInputCommand[sIndex..<eIndex])
        
        if(newString.count > Int(length)!){
            //print("message bigger than length")
            let startIndex = newString.index(newString.startIndex, offsetBy: 0)
            let endIndex = newString.index(newString.startIndex, offsetBy: Int(length)!)
            let newStringFinal = String(newString[startIndex..<endIndex])
            return newStringFinal
        }
        
        return sInputCommand
    }
    
    private func getLength(sMessage: String) -> String {
        return String(format: "%03d", (sMessage.count))
    }
    
    public func sendToTerminal(sInputCommandBuffer: String, isAsync: Bool, didSendToTerminal: ([UInt8]?, UInt8) -> Void) {
        var returnCode = PP.PP_OK.rawValue
        
        //        Thread.sleep(forTimeInterval: 1)
        trySend(sInputCommandBuffer: sInputCommandBuffer, isAsync: isAsync, didTrySend: {(sbOut: [UInt8]?, rc: UInt8) in
            if (rc == PP.PP_TABERR.rawValue) {
                if (!isAsync) {
                    abort()
                }
                returnCode = PP.PP_COMMTOUT.rawValue
            }
            
            didSendToTerminal(sbOut, returnCode)
        })
    }
    
    public func abort() {
        
        Log(message: "Terminal protocol channel ABORT")
        
        var canCommand = [UInt8]()
        canCommand.append(CAN)
        
        write(bytes: canCommand)
    }
    
    public func terminalDisplay(psMsg: String, didTerminalDisplay: (Int) -> Void) {
        var message: String
        if psMsg.count <= 32 {
            message = psMsg
        } else {
            message = psMsg.substring(firstIndex: 0, lastIndex: 32)
        }
        
        let input =  "DSP\(getLength(sMessage: message))\(message)"
        
        sendACommand(sInputCommand: input, isAsync: false, didSendACommand: {(sbOut: [UInt8]?, rc: UInt8) in
            didTerminalDisplay(Int(rc))
        })
    }
    
    public func cleanInputBuffer() {
        DevicesManager.shared.getSelectedDevice()?.clearBuffer()
    }
    
    public func trySend(sInputCommandBuffer: String, isAsync: Bool, didTrySend: ([UInt8]?, UInt8) -> Void) {
        Log(message: "Trying to send command: \(sInputCommandBuffer)")
        
        if sInputCommandBuffer.count > 0 {
            let bufferOut = buildMessage(inputString: sInputCommandBuffer)
            write(bytes: bufferOut)
        }
        
        return tryRead(isAsync: isAsync, count: 0, inLength: sInputCommandBuffer.count, didRead: {(sbOut: [UInt8]?, data: UInt8) in
            didTrySend(sbOut, data)
        })
    }
    
    func write(bytes: [UInt8]) {
        
        let intArray = bytes.map { Int8(bitPattern: $0) }
        
        Log(message: "[BLUETOOTH] - writting data: \(intArray)")
        
        if bytes.count > 0 {
            var mutableBytes = [Int8]()
            mutableBytes.append(contentsOf: intArray)
            
            DevicesManager.shared.getSelectedDevice()?.write(data: Data(bytes: mutableBytes, count: Int(mutableBytes.count)))
        }
    }
    
    private func sendNAK(isAsync: Bool, didSendNAK: ([UInt8]?, UInt8) -> Void) {
        var message = [UInt8()]
        message.append(NAK)
        write(bytes: message)
        
        tryRead(isAsync: isAsync, count: 0, inLength: 0, didRead: {(sbOut: [UInt8]?, data: UInt8) in
            didSendNAK(sbOut, data)
        })
    }
    
    private func readData(numBytes: Int, onComplete: (Data) -> Void) {
        DevicesManager.shared.getSelectedDevice()?.read(len: numBytes, onComplete: onComplete)
    }
    
    private func getCurrentCRC(buffer: [UInt8]) -> Int {
        return CRC16().getCurrentCRC(bufferIn: buffer, bytes: buffer.count)
    }
    
    private func calculateCRC(buffer: [UInt8]) -> Int {
        return CRC16().calcCRC16_v2(buffer: [UInt8](buffer[0...buffer.count - 3]))
    }
    
    private func readInput(isAsync: Bool, didReadInput: ([UInt8]?, UInt8) -> Void) {
        
        DevicesManager.shared.getSelectedDevice()?.readCRCData(onComplete: { (readBuffer: [UInt8]) in
            Log(message: String(describing: readBuffer))
            
            let bufferIn = readBuffer
            
            let currentCRC = getCurrentCRC(buffer: bufferIn)
            let calculatedCRC = calculateCRC(buffer: bufferIn)
            
            if currentCRC != calculatedCRC {
                sendNAK(isAsync: isAsync, didSendNAK: {(sbOut: [UInt8]?, data: UInt8) in
                    didReadInput(sbOut, data)
                })
            } else {
                let strBufferIn: [UInt8] = Array(bufferIn[0...(bufferIn.count - 4)])
                didReadInput(strBufferIn, PP.PP_OK.rawValue)
            }
        })
    }
    
    private func readFirstByte(didReadFirstByte: (UInt8) -> Void) {
        Log(message: "Waiting to read bytes...")
        
        let _ = DevicesManager.shared.getSelectedDevice()?.isAvailable()
        
        self.readData(numBytes: 1, onComplete: {(dataBytes: Data) in
            let firstByte = dataBytes.first!
            if firstByte != 21 && firstByte != 6 && firstByte != 22 {
                didReadFirstByte(21)
            } else {
                didReadFirstByte(firstByte)
            }
        })
    }
    
    public func tryRead(isAsync: Bool, count: Int, inLength: Int, didRead: ([UInt8]?, UInt8) -> Void) {
        
        if isAsync && DevicesManager.shared.getSelectedDevice()?.isAvailable() == false {
            didRead([], PP.PP_PROCESSING.rawValue)
            return
        }
        
        readFirstByte(didReadFirstByte: {(firstByte: UInt8) in
            
            Log(message: "---> First byte read: \(firstByte)")
            switch (firstByte) {
            case ACK:
                Log(message: "ACK received")
                if (!isAsync) {
                    tryRead(isAsync: isAsync, count: 1, inLength: inLength, didRead: { (sbOut: [UInt8]?, rc: UInt8) in
                        didRead(sbOut, rc)
                    })
                } else {
                    didRead([], PP.PP_PROCESSING.rawValue)
                }
                break
                
            case SYN:
                Log(message: "SYN received")
                readInput(isAsync: isAsync, didReadInput: {(sbOut: [UInt8]?, rc: UInt8) in
                    didRead(sbOut, PP.PP_OK.rawValue)
                })
                
                break
                
            case NAK:
                Log(message: "NAK received")
                didRead(nil, NAK)
                break
                
            default:
                didRead(nil, PP.PP_COMMERR.rawValue)
                
                
                break
            }
            
        })
    }
    
    internal func buildMessage(inputString: String) -> [UInt8] {
      //  print("buildMessage -> inputString: \(inputString)")
        let content: [UInt8] = [UInt8](inputString.utf8)
     //   print("buildMessage -> content: \(content)")
        let CRC = CRC16().calcCRC16_v2(buffer: getBufferWithETB(bytes: content))
    //    print("buildMessage -> CRC: \(CRC)")
        let crcBytes = CRC16().getCRCBytes_V2(crc: CRC)
    //    print("buildMessage -> crcBytes: \(crcBytes)")
        var bufferOut = [UInt8]()
        bufferOut.append(SYN)
    //    print("buildMessage -> 1bufferOut: \(bufferOut)")
        bufferOut.append(contentsOf: content)
   //     print("buildMessage -> 2bufferOut: \(bufferOut)")
        appendETB(byteArray: &bufferOut)
        bufferOut.append(contentsOf: crcBytes)
    //    print("buildMessage -> 3bufferOut: \(bufferOut)")
        
        return bufferOut
    }
    
    private func getBufferWithETB(bytes: [UInt8]) -> [UInt8] {
        //        var outputStream = OutputStream()
        //        outputStream.open()
        //        outputStream.write(bytes, maxLength: bytes.count)
        //        outputStream.write(ETB, maxLength: [UInt8] (ETB))
        //        outputStream.close()
        //
        
        var byteArray = [UInt8]()
        byteArray.append(contentsOf: bytes)
        byteArray.append(ETB)
        return byteArray
    }
    
    private func appendETB(byteArray: inout [UInt8]) {
        byteArray.append(ETB)
    }
    
    //TODO entender e refatorar para usar o sendACommand async
    public func checkKeyMpos() -> String {
        //        var terminalResponse: UInt8?
        //        var sbOut: [UInt8]? = [UInt8]()
        //        var dataReceived: String
        //        var ksn = ""
        //        for j in 16...17 {
        //            dataReceived = "GDU0033" + String(format: "%02d", j)
        //            terminalResponse = sendACommand(sInputCommand: dataReceived, sbOut: &sbOut, isAsync: false)
        //            if (terminalResponse == 0) {
        //                ksn += String(format: "%02d", j)
        //            }
        //        }
        //        if ksn == "" {
        //            for i in 1...99 {
        //                dataReceived = "GDU0033" + String(format: "%02d", i)
        //                terminalResponse = sendACommand(sInputCommand: dataReceived, sbOut: &sbOut, isAsync: false)
        //                if (terminalResponse == 0) {
        //                    ksn += String(format: "%02d", i)
        //                }
        //            }
        //        }
        //        return ksn
        return ""
    }
    
}
