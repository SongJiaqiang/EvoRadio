//
//  Colors.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/17.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit


//MARK: convenience init functions
extension UIColor {
    /** Initialize color with css integer value, example (2, 23, 234) */
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    /** Initialize color with Hex integer value and alpha */
    convenience init(netHex:Int, alpha: CGFloat) {
        self.init(red:CGFloat((netHex >> 16) & 0xff)/255.0, green:CGFloat((netHex >> 8) & 0xff)/255.0, blue:CGFloat(netHex & 0xff)/255.0, alpha: alpha)
    }
    
    /** Initialize color with Hex integer value */
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
}

//MARK: 
extension UIColor {
    func alpha(_ alpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }
}

//MARK: colors
extension UIColor {
    /** 0xB89406 D4AF37 */
    class func goldColor() -> UIColor{
        return UIColor(netHex: 0xD4AF37)
    }
    /** 0x121212 */
    class func grayColor12() -> UIColor{
        return UIColor(netHex: 0x121212)
    }
    /** 0x1C1C1C */
    class func grayColor1C() -> UIColor{
        return UIColor(netHex: 0x1C1C1C)
    }
    /** 0x282828 */
    class func grayColor28() -> UIColor{
        return UIColor(netHex: 0x282828)
    }
    /** 0x414141 */
    class func grayColor41() -> UIColor{
        return UIColor(netHex: 0x414141)
    }
    /** 0x4C4C4C */
    class func grayColor4C() -> UIColor{
        return UIColor(netHex: 0x4C4C4C)
    }
    /** 0x666666 */
    class func grayColor66() -> UIColor{
        return UIColor(netHex: 0x666666)
    }
    /** 0x979797 */
    class func grayColor97() -> UIColor{
        return UIColor(netHex: 0x979797)
    }
    /** 0xBFBFBF */
    class func grayColorBF() -> UIColor{
        return UIColor(netHex: 0xBFBFBF)
    }
    /** 0xFBFBFB */
    class func grayColorFB() -> UIColor{
        return UIColor(netHex: 0xFBFBFB)
    }
}
