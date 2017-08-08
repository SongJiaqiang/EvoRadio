//
//  Common.swift
//  EvoRadio
//
//  Created by Jarvis on 07/08/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

import UIKit

class Common: NSObject {
    
    
    /// 打印当前毫秒数
    class func printTime(prefix: Any?) -> TimeInterval {
        let time = Date().timeIntervalSince1970
        
        if let pre = prefix {
            print("[\(pre)] 加载耗时：\(time)")
        }else {
            print("加载耗时：\(time)")
        }
        
        return time
    }
    
}
