//
//  Radio.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import EVReflection

class Radio: EVObject {
    
    var radioID: NSNumber?
    var radioName: String?
    var channels: [Channel]?
    
    override func propertyMapping() -> [(String?, String?)] {
        return [
            ("radioID", "radio_id"),
            ("radioName", "radio_name")
        ]
    }
    
    class func dictForRadio(_ radio: Radio) -> [String : AnyObject]{
        var radioDict = [String : AnyObject]()
        radioDict["radio_id"] = radio.radioID
        radioDict["radio_name"] = radio.radioName as AnyObject?
        
        return radioDict
    }
    
    class func dictArrayForRadios(_ radios: [Radio]) -> [[String : AnyObject]]{
        var dictArray = [[String : AnyObject]]()
        for radio in radios {
            var radioDict = [String : AnyObject]()
            radioDict["radio_id"] = radio.radioID
            radioDict["radio_name"] = radio.radioName as AnyObject?
            
            dictArray.append(radioDict)
        }
        return dictArray
    }
}

