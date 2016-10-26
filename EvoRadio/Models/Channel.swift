//
//  Channel.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import EVReflection

class Channel: EVObject {
    var channelID: String?
    var channelName: String?
    var channelNameShengmu: String?
    var radioID: String?
    var radioName: String?
    var programNum: String?
    var programFine: String?
    var pubTime: String?
    var sortOrder: String?
    var picURL: String?
    var status: String?
    var recommend: String?
    
    override func propertyMapping() -> [(String?, String?)] {
        return [
            ("channelID", "channel_id"),
            ("channelName", "channel_name"),
            ("channelNameShengmu", "channel_name_shengmu"),
            ("radioID", "radio_id"),
            ("radioName", "radio_name"),
            ("programNum", "program_num"),
            ("programFine", "program_fine"),
            ("pubTime", "pub_time"),
            ("sortOrder", "sort_order"),
            ("picURL", "pic_url")
        ]
    }
    
    class func channelWithDict(_ dict: [String : AnyObject]) -> Channel {
        let channel = Channel()
        channel.channelID = dict["channel_id"] as? String
        channel.channelName = dict["channel_name"] as? String
        channel.channelNameShengmu = dict["channel_name_shengmu"] as? String
        channel.radioID = dict["radio_id"] as? String
        channel.radioName = dict["radio_name"] as? String
        channel.programFine = dict["program_fine"] as? String
        channel.programNum = dict["program_num"] as? String
        channel.pubTime = dict["pub_time"] as? String
        channel.sortOrder = dict["sort_order"] as? String
        channel.picURL = dict["pic_url"] as? String
        channel.status = dict["status"] as? String
        channel.recommend = dict["recommend"] as? String
        
        return channel
    }
    
    class func channelsWithDict(_ dicts: [[String : AnyObject]]) -> [Channel] {
        var channels = [Channel]()
        for dict in dicts {
            channels.append(Channel.channelWithDict(dict))
        }
        return channels
    }
}
