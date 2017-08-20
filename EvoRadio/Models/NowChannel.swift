//
//  NowChannel.swift
//  EvoRadio
//
//  Created by Jarvis on 07/08/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

import UIKit
import ObjectMapper

class NowChannel: Mappable {

    var dayofweek: String?
    var timeid: String?
    var channels: [Channel]?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        dayofweek    <- map["dayofweek"]
        timeid    <- map["timeid"]
        channels    <- map["channels"]
    }
    
}
