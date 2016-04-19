//
//  Channel.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
/*
 {
 "channel_id": "129",
 "radio_id": "1",
 "channel_name": "醒来",
 "program_fine": "246",
 "pub_time": "1416640291",
 "sort_order": "0",
 "status": "1",
 "channel_name_shengmu": "cl",
 "radio_name": "活动电台",
 "pic_url": "http://img2.lavaradio.com/176/269/176269667730103844X.jpg"
 },
 */
class Channel: NSObject {
    var channelID: String?
    var channelName: String?
    var channelNameShengmu: String?
    var radioID: String?
    var radioName: String?
    var programFine: String?
    var pubTime: String?
    var sortOrder: String?
    var picURL: String?
    var status: String?
    var recommend: String?
    
    class func channelWithDict(dict: [String : AnyObject]) -> Channel {
        let channel = Channel()
        channel.channelID = dict["channel_id"] as? String
        channel.channelName = dict["channel_name"] as? String
        channel.channelNameShengmu = dict["channel_name_shengmu"] as? String
        channel.radioID = dict["radio_id"] as? String
        channel.radioName = dict["radio_name"] as? String
        channel.programFine = dict["program_fine"] as? String
        channel.pubTime = dict["pub_time"] as? String
        channel.sortOrder = dict["sort_order"] as? String
        channel.picURL = dict["pic_url"] as? String
        channel.status = dict["status"] as? String
        channel.recommend = dict["recommend"] as? String
        
        return channel
    }
    
    class func channelsWithDict(dicts: [[String : AnyObject]]) -> [Channel] {
        var channels = [Channel]()
        for dict in dicts {
            channels.append(Channel.channelWithDict(dict))
        }
        return channels
    }
}
