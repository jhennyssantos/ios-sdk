//
//  Logger.swift
//  EMVConnectiOS
//
//  Created by Carla Galdino Wanderley on 03/11/17.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

public class MetadataManager {

    public static let sharedInstance = MetadataManager()
    private var metadata: String

    private init() {
        metadata = ""
    }

    func getMetadata() -> String {
        return metadata
    }

    func setMetadata(key: String, value: String) {
        metadata.append("[\(key): \(value)]")
    }

    func eraseMetadata() {
        metadata = ""
    }
}

func Log(message: String) {

    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = Date()
    let dateString = dateFormatter.string(from: date)
    let logWithDate = "[\(dateString)] \(message)"
    let logWithMetadata = "[\(dateString)] \(MetadataManager.sharedInstance.getMetadata()) \(message)"

    #if DEBUG
    print("[ZOOP SDK]\(logWithDate)")
    #else
    let file = "transaction_log.txt" //this is the file. we will write to and read from it

    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

        let fileURL = dir.appendingPathComponent(file)

        //writing
        do {
            try logWithMetadata.appendLineToURL(fileURL: fileURL)
        } catch {
            print("ERROR WRITTING LOG")
        }
    }
    #endif
}
