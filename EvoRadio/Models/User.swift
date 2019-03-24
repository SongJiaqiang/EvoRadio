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
    
    var priLavahomeSimple : NSNumber?
    var priCreateProgram : NSNumber?
    var priAuditProgram : NSNumber?
    var priUserPage : NSNumber?
    var priItemEdit : NSNumber?
    var priItemView : NSNumber?
    var priTimer : NSNumber?
    var priLogin : NSNumber?
    var priVod : NSNumber?
    var priCp : NSNumber?
    var priQd : NSNumber?
    var priSc : NSNumber?
 
    required init?(map: Map) {
        
    }
    
    
    func mapping(map: Map) {
        uid    <- map["uid"]
        uName    <- map["uName"]
        userType    <- map["user_type"]
        picURL    <- map["picURL"]
        
        priAuditProgram    <- map["pri_audit_program"]
        priCreateProgram    <- map["pri_create_program"]
        priItemEdit    <- map["pri_item_edit"]
        priItemView    <- map["pri_item_view"]
        priLavahomeSimple    <- map["pri_lavahome_simple"]
        priLogin    <- map["pri_login"]
        priCp    <- map["pri_cp"]
        priQd    <- map["pri_qd"]
        priSc    <- map["pri_sc"]
        priVod    <- map["pri_vod"]
        priTimer    <- map["pri_timer"]
        priUserPage    <- map["pri_user_page"]
    }
    
}
