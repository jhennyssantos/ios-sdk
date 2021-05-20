//
//  Data+AppendingToFile.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino on 2/14/18.
//  Copyright © 2018 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
