//
//  User.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import EVReflection

class User: EVObject {
    var uID: String?
    var uName: String?
    var userType: NSNumber? // JSON返回的数据有的是string，有的是int，郁闷啊！
    var picURL: String?
    var picUrl : String?
    
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
 
    override func propertyMapping() -> [(String?, String?)] {
        return [
            ("uID", "uid"),
            ("uName", "uname"),
            ("userType", "user_type"),
            ("picURL", "pic_url"),
            ("priAuditProgram", "pri_audit_program"),
            ("priCreateProgram", "pri_create_program"),
            ("priItemEdit", "pri_item_edit"),
            ("priItemView", "pri_item_view"),
            ("priLavahomeSimple", "pri_lavahome_simple"),
            ("priLogin", "pri_login"),
            ("priCp", "pri_cp"),
            ("priQd", "pri_qd"),
            ("priSc", "pri_sc"),
            ("priVod", "pri_vod"),
            ("priTimer", "pri_timer"),
            ("priUserPage", "pri_user_page")
        ]
    }
}
