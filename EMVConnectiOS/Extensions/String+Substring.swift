//
//  String+Substring.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 18/10/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

extension String {

    func substring(firstIndex: Int, lastIndex: Int) -> String {
        if lastIndex <= self.count {
            let startIndex = self.index(self.startIndex, offsetBy: firstIndex)
            let endIndex = self.index(self.startIndex, offsetBy: lastIndex)

            let range = startIndex..<endIndex
            Log(message: String(self.substring(with: range)))
            return String(self.substring(with: range))
        }
        return self
    }
    
    // Padding left
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let newLength = self.count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
        }
    }

    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func camelCaseToWords() -> String {

        return unicodeScalars.reduce("") {

            if CharacterSet.uppercaseLetters.contains($1) == true {

                return ($0 + "-" + String($1).lowercased())
            } else {

                return $0 + String($1).lowercased()
            }
        }
    }

    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}
