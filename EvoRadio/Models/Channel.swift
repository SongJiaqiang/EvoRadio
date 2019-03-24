//
//  Channel.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper

class Channel: Mappable {
    var channelId: String?
    var channelName: String?
    var channelNameShengmu: String?
    var radioId: String?
    var radioName: String?
    var programNum: String?
    var programFine: String?
    var pubTime: String?
    var sortOrder: String?
    var picURL: String?
    var status: String?
    var recommend: String?

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        channelId    <- map["channel_id"]
        channelName    <- map["channel_name"]
        channelNameShengmu    <- map["channel_name_shengmu"]
        radioId    <- map["radio_id"]
        radioName    <- map["radio_name"]
        programNum    <- map["program_num"]
        programFine    <- map["program_fine"]
        pubTime    <- map["pub_time"]
        sortOrder    <- map["sort_order"]
        picURL    <- map["pic_url"]
        status    <- map["status"]
        recommend    <- map["recommend"]
    }
    
}
