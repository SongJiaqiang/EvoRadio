//
//  Radio.swift
//  EvoRadio
//
//  Created by Jarvis on 2020/3/29.
//  Copyright © 2020 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper

public class Radio: Mappable {
    
    var radioId: Int?
    var radioName: String?
    var channels: [Channel]?
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        radioId      <- map["radio_id"]
        radioName    <- map["radio_name"]
        channels     <- map["channels"]
    }
}
