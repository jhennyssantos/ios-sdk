//
//  CGPath+Points.swift
//  SignatureTest
//
//  Created by Carla Galdino Wanderley on 09/11/17.
//  Copyright © 2017 Yuppielabel. All rights reserved.
//

import UIKit
import CoreGraphics

extension CGPath {
    func points() -> [CGPoint] {
        var bezierPoints = [CGPoint]()
        self.forEach(body: { (element: CGPathElement) in
            let numberOfPoints: Int = {
                switch element.type {
                case .moveToPoint:
                    return 1
                case .addLineToPoint:
                    return 1
                case .addQuadCurveToPoint:
                    return 2
                case .addCurveToPoint:
                    return 3
                case .closeSubpath:
                    return 0
                }
            }()
            for index in 0..<numberOfPoints {
                let point = element.points[index]
                bezierPoints.append(point)
            }
        })
        return bezierPoints
    }

    func pointsToString() -> String {
        var strPoints = String()
        var bezierPoints = [CGPoint]()
        var byteArrayPoints = Data()
        self.forEach(body: { (element: CGPathElement) in
            let numberOfPoints: Int = {
                switch element.type {
                case .moveToPoint:
                    strPoints.append("MP1")
                    return 1
                case .addLineToPoint:
                    strPoints.append("AL1")
                    return 1
                case .addQuadCurveToPoint:
                    strPoints.append("AQ2")
                    return 2
                case .addCurveToPoint:
                    strPoints.append("AC3")
                    return 3
                case .closeSubpath:
                    strPoints.append("CP0")
                    return 0
                }
            }()
            for index in 0..<numberOfPoints {
                let point = element.points[index]
                bezierPoints.append(point)

                // Tratando extremos
                var xCoordinate = point.x < 0.0 ? 0 : point.x
                xCoordinate = xCoordinate > 255.0 ? 255 : xCoordinate

                // Tratando extremos
                var yCoordinate = point.y < 0.0 ? 0 : point.y
                yCoordinate = yCoordinate > 255.0 ? 255 : yCoordinate

                byteArrayPoints.append(UInt8(xCoordinate))
                byteArrayPoints.append(UInt8(yCoordinate))
            }
        })
        return "\(strPoints)|\(byteArrayPoints.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)))"
    }

    func forEach(body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        
        func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info!, to: Body.self)
            body(element.pointee)
        }
        
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)

        self.apply(info: unsafeBody, function: callback as CGPathApplierFunction)
    }
}
