//
//  Program.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Cocoa
import ObjectMapper

class Program: Mappable{
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
    var collectNum: String?
    var shareNum: String?
    var refLink: String?
    var vipLevel: String?
    var auditStatus: String?
    var status: String?
    var sortOrder: String?
    var channels: [Channel]?
    var cover: Cover?
    var user: User?
    var uid: String?
    var lavadj: String?
    var recommend: String?
    var sourceId: String?
    var duration: String?
    var comment: String?
    var sortOrderSelf: String?
    var playOrder: String?
    var rejectTime: String?
    var genre: String?
    var genreChannelId: String?
    var key: String?
    var fullTag: String?
    var bPublic: String?
    
    
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
        collectNum    <- map["collect_num"]
        refLink    <- map["ref_link"]
        vipLevel    <- map["vip_level"]
        auditStatus    <- map["audit_status"]
        sortOrder    <- map["sort_order"]
        status    <- map["status"]
        channels    <- map["channels"]
        cover    <- map["cover"]
        user    <- map["user"]
        uid    <- map["uid"]
        lavadj    <- map["lavadj"]
        recommend    <- map["recommend"]
        sourceId    <- map["sourceid"]
        duration    <- map["duration"]
        comment    <- map["comment"]
        sortOrderSelf    <- map["sort_order_self"]
        playOrder    <- map["play_order"]
        rejectTime <- map["reject_time"]
        genre <- map["genre"]
        genreChannelId <- map["genre_channel_id"]
        key <- map["key"]
        fullTag <- map["full_tag"]
        bPublic <- map["b_public"]
        
    }
    
}
