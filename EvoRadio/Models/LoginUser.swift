//
//  LoginUser.swift
//  EvoRadio
//
//  Created by 宋佳强 on 16/4/24.
//  Copyright © 2016年 JQTech. All rights reserved.
//

/*
 
 {
 "uname": "那个_初次见面",
 "email": "",
 "sex": "0",
 "birthday": "20130715",
 "purl": "http://img4.lavaradio.com/435/303/4353037169678968356X.jpg",
 "third": [
 {
 "third_type": "1",
 "nickname": "那个_初次见面"
 }
 ]
 }
 */

import Foundation

struct ThirdLogin {
    var thirdType: String
    var nickname: String
}

class LoginUser: NSObject {
    
    var uID: String?
    var uName: String?
    var email: String?
    var birthday: String?
    var pURL: String?
    var third: ThirdLogin?
    
    class func userWithDict(dict: [String : AnyObject]) -> LoginUser {
        let user = LoginUser()
        user.uID = dict["uid"] as? String
        user.uName = dict["uname"] as? String
        user.email = dict["email"] as? String
        user.birthday = dict["birthday"] as? String
        user.pURL = dict["purl"] as? String
        user.third = ThirdLogin(thirdType: dict["third"]!["third_type"] as! String, nickname: dict["third"]!["nickname"] as! String)
        
        return user
    }
}