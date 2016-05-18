//
//  Program.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class Program: Reflect {
    var programID: String?
    var programName: String?
    var programDesc: String?
    var picURL: String?
    var createTime: String?
    var modifyTime: String?
    var pubTime: String?
    var applyTime: String?
    var subscribeNum: String?
    var songNum: String?
    var playNum: String?
    var shareNum: String?
    var refLink: String?
    var vipLevel: String?
    var auditStatus: String?
    var status: String?
    var sortOrder: String?
    var channels: [Channel]?
    var cover: Cover?
    var user: User?
    var uID: String?
    var lavadj: String?
    var recommend: String?
    
    override func mappingDict() -> [String : String]? {
        return [
            "programID":"program_id",
            "programName":"program_name",
            "programDesc":"program_desc",
            "picURL":"pic_url",
            "createTime":"create_time",
            "modifyTime":"modify_time",
            "pubTime":"pub_time",
            "applyTime":"apply_time",
            "subscribeNum":"subscribe_num",
            "songNum":"song_num",
            "playNum":"play_num",
            "shareNum":"share_num",
            "refLink":"ref_link",
            "vipLevel":"vip_level",
            "auditStatus":"audit_status",
            "sortOrder":"sort_order",
            "uID":"uid"
        ]
    }
    
}



class Cover: Reflect {
    var num: NSNumber?
    var pics: [String]?
    
    convenience init(num: NSNumber, pics: [String]) {
        self.init()
        
        self.num = num
        self.pics = pics
    }

}
