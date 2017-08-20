//
//  Radio.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper

class Radio: Mappable {
    
    var radioID: Int?
    var radioName: String?
    var channels: [Channel]?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        radioID      <- map["radio_id"]
        radioName    <- map["radio_name"]
        channels     <- map["channels"]
    }
}

