//
//  ZoopParameters.swift
//  EMVConnectiOS
//
//  Created by Ana Vidal on 19/12/2017.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

public class ZoopParameters {
    /*
    static let sharedInstance = ZoopParameters()
    
    var db:SQLiteDatabase? = nil
    var parameterSetId:String? = nil
    
    private init() {
        db = SQLiteDatabase()
        if( db?.open(filename: "ZoopSettings") != .ok) {
            SQLiteDatabase.createDatabase(withFilename: "ZoopSettings.sqlite", blankDatabaseFilename: "ZoopSettings.sqlite")
        }
    }
    
    public func getBooleanParameter(parameterKey: String, defaultValue:Bool, bForceGlobalParameter:Bool) -> Bool {
        let statement = SQLiteStatement(database: db!)
        
        if statement.prepare(sqlQuery: "SELECT value, setid FROM ZoopParameters WHERE name='\(parameterKey)' and setId is null") != .ok {
            
            /* handle error */
        }
        
        statement.bind(int: 1, at: 123)
        
        if statement.step() == .row {
            
            /* do something with statement */
            
            let id: Int? = statement.int(at: 0)
        }
    }
    
    public func putBooleanParameter(parameterKey:String, booleanValue:Bool) {
        //TODO Implement
    }
 */
}
