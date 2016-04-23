//
//  Radio.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation

class Radio: NSObject {
    
    var radioID: Int?
    var radioName: String?
    var channels: [Channel]?
    
    class func radioWithDict(dict: [String : AnyObject]) -> Radio {
        let radio = Radio()
        radio.radioID = dict["radio_id"] as? Int
        radio.radioName = dict["radio_name"] as? String
        
        let channelsData = dict["channels"] as? [[String : AnyObject]]
        var channels = [Channel]()
        for item in channelsData! {
            channels.append(Channel.channelWithDict(item))
        }
        radio.channels = channels
        
        return radio
    }
    
    class func radiosWithDict(dicts: [[String : AnyObject]]) -> [Radio] {
        var radios = [Radio]()
        for dict in dicts {
            radios.append(Radio.radioWithDict(dict))
        }
        return radios
    }
}

