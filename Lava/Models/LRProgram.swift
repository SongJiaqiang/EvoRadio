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
    var refLink: String?
    var vipLevel: String?
    var auditStatus: String?
    var status: String?
    var channels: [LRChannel]?
    var cover: LRCover?
    var user: LRUser?
    var uid: String?
    var lavadj: String?
    var recommend: String?
    var songNum: Int64?
    
    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        programId    <- map["program_id"]
        programName    <- map["program_name"]
        programDesc    <- map["program_desc"]
        picURL    <- map["pic_url"]
        createTime    <- map["create_time"]
        modifyTime    <- map["modify_time"]
        refLink    <- map["ref_link"]
        vipLevel    <- map["vip_level"]
        auditStatus    <- map["audit_status"]
        
        channels    <- map["channels"]
        cover    <- map["cover"]
        user    <- map["user"]
        
        uid    <- map["uid"]
        lavadj    <- map["lavadj"]
        recommend    <- map["recommend"]
        songNum    <- map["song_num"]
    }
    
}
