//
//  User.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
/*
 "user": {
 "uid": "59",
 "uname": "庞舸",
 "user_type": "6",
 "pri_login": 0,
 "pri_create_program": 1,
 "pri_item_view": 1,
 "pri_item_edit": 0,
 "pri_audit_program": 0,
 "pri_user_page": 1,
 "pri_timer": 0,
 "pri_sc": 1,
 "pri_vod": 0,
 "pri_qd": 0,
 "pri_cp": 0,
 "pri_lavahome_simple": 0,
 "pic_url": "http://img3.lavaradio.com/143/727/1437278527257050584.jpg"
 },
 */
class User: NSObject {
    var uID: String?
    var uName: String?
    var userType: String?
    var picURL: String?
 
    class func userWithDict(dict: [String : AnyObject]) -> User {
        let user = User()
        user.uID = dict["uid"] as? String
        user.uName = dict["uname"] as? String
        user.userType = dict["user_type"] as? String
        user.picURL = dict["pic_url"] as? String
        
        return user
    }
    
    class func usersWithDict(dicts: [[String : AnyObject]]) -> [User] {
        var users = [User]()
        for dict in dicts {
            users.append(User.userWithDict(dict))
        }
        return users
    }
}
