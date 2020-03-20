//
//  User.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {

    var uid: String?
    var uName: String?
    var userType: NSNumber? // JSON返回的数据有的是string，有的是int，郁闷啊！
    var picURL: String?
 
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        uid    <- map["uid"]
        uName    <- map["uName"]
        userType    <- map["user_type"]
        picURL    <- map["picURL"]
    }
    
}
