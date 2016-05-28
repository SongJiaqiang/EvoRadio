//
//  Colors.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/17.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int, alpha: CGFloat) {
        self.init(red:CGFloat((netHex >> 16) & 0xff)/255.0, green:CGFloat((netHex >> 8) & 0xff)/255.0, blue:CGFloat(netHex & 0xff)/255.0, alpha: alpha)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    
    static func goldColor() -> UIColor{
        return UIColor(netHex: 0xB89406)
    }
    
    
    static func blackColor1() -> UIColor{
        return UIColor(netHex: 0x121212)
    }
    static func blackColor2() -> UIColor{
        return UIColor(netHex: 0x1C1C1C)
    }
    static func blackColor3() -> UIColor{
        return UIColor(netHex: 0x282828)
    }
    static func blackColor4() -> UIColor{
        return UIColor(netHex: 0x414141)
    }
    static func blackColor5() -> UIColor{
        return UIColor(netHex: 0x4C4C4C)
    }
    static func blackColor6() -> UIColor{
        return UIColor(netHex: 0x979797)
    }
    static func blackColor7() -> UIColor{
        return UIColor(netHex: 0xBFBFBF)
    }
    
}