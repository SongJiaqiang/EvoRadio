//
//  LRNowChannel.swift
//  EvoRadio
//
//  Created by Jarvis on 07/08/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper

class LRNowChannel: Mappable {

    var dayofweek: String?
    var timeid: String?
    var channels: [LRChannel]?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        dayofweek    <- map["dayofweek"]
        timeid    <- map["timeid"]
        channels    <- map["channels"]
    }
    
}
