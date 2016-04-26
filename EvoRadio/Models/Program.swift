//
//  Program.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
/*
 {
 "program_id": "7115",
 "program_name": "Beautiful Day",
 "program_desc": "",
 "uid": "59",
 "create_time": "1460367467",
 "modify_time": "1460962462",
 "subscribe_num": "0",
 "song_num": "15",
 "play_num": "44",
 "share_num": "0",
 "recommend": "1460962462",
 "lavadj": "0",
 "pub_time": "1460962379",
 "audit_status": "2",
 "apply_time": "1460899401",
 "ref_link": "",
 "vip_level": "1",
 "status": "1",
 "sort_order": "8",
 "channels": [
 {
 "recommend": "1460962462",
 "channel_id": "140",
 "radio_id": "5",
 "channel_name": "Lounge",
 "pic_url": "http://img4.lavaradio.com/688/483/6884838140598437692.jpg"
 },
 ]
 "user": {
 "uid": "59",
 "uname": "庞舸",
 },
 "pic_url": "http://img1.lavaradio.com/462/286/4622865212364653384.jpg"
 */
class Program: NSObject {
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
    
    
    class func programWithDict(dict: [String : AnyObject]) -> Program {
        let program = Program()
        
        program.programID = dict["program_id"] as? String
        program.programName = dict["program_name"] as? String
        program.programDesc = dict["program_desc"] as? String
        program.picURL = dict["pic_url"] as? String
        program.createTime = dict["create_time"] as? String
        program.modifyTime = dict["modify_time"] as? String
        program.pubTime = dict["pub_time"] as? String
        program.applyTime = dict["apply_time"] as? String
        program.subscribeNum = dict["subscribe_num"] as? String
        program.songNum = dict["song_num"] as? String
        program.playNum = dict["play_num"] as? String
        program.shareNum = dict["share_num"] as? String
        program.refLink = dict["ref_link"] as? String
        program.vipLevel = dict["vip_level"] as? String
        program.auditStatus = dict["audit_status"] as? String
        program.status = dict["status"] as? String
        program.sortOrder = dict["sort_order"] as? String
        program.uID = dict["uid"] as? String
        
        if let u =  dict["user"]{
            program.user = User.userWithDict(u as! [String : AnyObject])
        }
        
        if let co = dict["cover"] {
            let num = co["num"] as! Int
            let pics = co["pics"] as! [String]
            program.cover = Cover(num: num, pics: pics)
        }
        
        if let ch = dict["channels"] {
            program.channels = Channel.channelsWithDict(ch as! [[String : AnyObject]])
        }
        
        return program
    }
    
    class func programsWithDict(dicts: [[String : AnyObject]]) -> [Program] {
        var programs = [Program]()
        for dict in dicts {
            programs.append(Program.programWithDict(dict))
        }
        return programs
    }
}



struct Cover {
    var num: Int?
    var pics: [String]?
}
