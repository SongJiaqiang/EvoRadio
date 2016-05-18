//
//  LoginUser.swift
//  EvoRadio
//
//  Created by 宋佳强 on 16/4/24.
//  Copyright © 2016年 JQTech. All rights reserved.
//


import Foundation

struct ThirdLogin {
    var thirdType: String
    var nickname: String
}

class LoginUser: Reflect {
    
    var uID: String?
    var uName: String?
    var email: String?
    var birthday: String?
    var pURL: String?
    var third: ThirdLogin?
    
    override func mappingDict() -> [String : String]? {
        return [
            "uID":"uid",
            "uName":"uname",
            "pURL":"purl",
        ]
    }
    
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