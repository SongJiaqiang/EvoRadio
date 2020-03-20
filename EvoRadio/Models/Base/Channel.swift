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
    var channelNameEnglish: String?
    var channelDesc: String?
    var radioId: String?
    var radioName: String?
    var pubTime: String?
    var picURL: String?
    var status: String?
    var recommend: String?

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        channelId    <- map["channel_id"]
        channelName    <- map["channel_name"]
        channelNameShengmu    <- map["channel_name_shengmu"]
        channelNameEnglish    <- map["english_name"]
        channelDesc    <- map["channel_desc"]
        radioId    <- map["radio_id"]
        radioName    <- map["radio_name"]
        pubTime    <- map["pub_time"]
        picURL    <- map["pic_url"]
        status    <- map["status"]
        recommend    <- map["recommend"]
    }
    
}
