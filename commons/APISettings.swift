//
//  APISettings.swift
//  EMVConnectiOS
//
//  Created by Ana Vidal on 19/12/2017.
//  Copyright © 2017 Carla Galdino Wanderley. All rights reserved.
//

import Foundation

class APISettings {
    static let sharedInstance = APISettings()
    
    private var parameterSetId:String? = nil
    
    public func addParameterForName(sParameterNameToMatch:String, value:String) {
        
        if let parameterList = UserDefaults.standard.stringArray(forKey: sParameterNameToMatch) {
            var mutatingParameterList = parameterList
            mutatingParameterList.append(value)
            UserDefaults.standard.setValue(mutatingParameterList, forKey: sParameterNameToMatch)
        } else {
            var strList = [String]()
            strList.append(value)
            UserDefaults.standard.setValue(strList, forKey: sParameterNameToMatch)
        }
    }
    
    //"ZTL#"
    public func getParameterNamesByString(sParameterNameToMatch:String, bForceGlobalParameter:Bool) -> [String]? {
        return UserDefaults.standard.stringArray(forKey: sParameterNameToMatch)
    }
    
    public func addParameterForName(sParameterNameToMatch:String, value:Bool) {
            UserDefaults.standard.setValue(value, forKey: sParameterNameToMatch)
      
    }
    public func getParameterNamesByBool(sParameterNameToMatch:String, bForceGlobalParameter:Bool) -> Bool {
        return UserDefaults.standard.bool(forKey: sParameterNameToMatch)
    }
    
}
