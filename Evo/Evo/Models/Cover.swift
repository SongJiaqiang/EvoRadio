//
//  Cover.swift
//  EvoRadio
//
//  Created by Jarvis on 5/24/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Cocoa
import ObjectMapper

class Cover: Mappable {
    var num: NSNumber?
    var pics: [String]?
    
//    convenience init(num: NSNumber, pics: [String]) {
//        self.init()
//        
//        self.num = num
//        self.pics = pics
//    }
    
    
    required /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        num    <- map["num"]
        pics   <- map["pics"]
    }

}
