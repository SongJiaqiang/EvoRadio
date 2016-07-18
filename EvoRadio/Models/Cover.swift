//
//  Cover.swift
//  EvoRadio
//
//  Created by Jarvis on 5/24/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation
import EVReflection

class Cover: EVObject {
    var num: NSNumber?
    var pics: [String]?
    
    convenience init(num: NSNumber, pics: [String]) {
        self.init()
        
        self.num = num
        self.pics = pics
    }
    
}