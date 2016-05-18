//
//  User.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class User: Reflect {
    var uID: String?
    var uName: String?
    var userType: String?
    var picURL: String?
 
    override func mappingDict() -> [String : String]? {
        return [
            "uID":"uid",
            "uName":"uname",
            "userType":"user_type",
            "picURL":"pic_url",
        ]
    }
    
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
