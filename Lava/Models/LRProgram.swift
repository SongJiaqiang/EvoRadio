//
//  LRProgram.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper

class LRProgram: Mappable{
    var programId: String?
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
    var channels: [LRChannel]?
    var cover: LRCover?
    var user: LRUser?
    var uid: String?
    var lavadj: String?
    var recommend: String?
    
    
    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        programId    <- map["program_id"]
        programName    <- map["program_name"]
        programDesc    <- map["program_desc"]
        picURL    <- map["pic_url"]
        createTime    <- map["create_time"]
        modifyTime    <- map["modify_time"]
        pubTime    <- map["pub_time"]
        applyTime    <- map["apply_time"]
        subscribeNum    <- map["subscribe_num"]
        songNum    <- map["song_num"]
        playNum    <- map["play_num"]
        shareNum    <- map["share_num"]
        refLink    <- map["ref_link"]
        vipLevel    <- map["vip_level"]
        auditStatus    <- map["audit_status"]
        sortOrder    <- map["sort_order"]
        
        channels    <- map["channels"]
        cover    <- map["cover"]
        user    <- map["user"]
        
        uid    <- map["uid"]
        lavadj    <- map["lavadj"]
        recommend    <- map["recommend"]
    }
    
}
