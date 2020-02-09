//
//  LRRadio.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper

class LRRadio: Mappable {
    
    var radioId: Int?
    var radioName: String?
    var channels: [LRChannel]?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        radioId      <- map["radio_id"]
        radioName    <- map["radio_name"]
        channels     <- map["channels"]
    }
}

