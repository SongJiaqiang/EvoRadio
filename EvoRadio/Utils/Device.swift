//
//  Device.swift
//  CameraReqairman
//
//  Created by Whisper-JQ on 16/3/24.
//  Copyright © 2016年 SongJiaqiang. All rights reserved.
//

import UIKit

class Device: NSObject {

    static func width() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    static func height() -> CGFloat {
        return UIScreen.mainScreen().bounds.size.height
    }
    static func size() -> CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    static func screenScale() -> CGFloat {
        return UIScreen.mainScreen().scale
    }
    
    static func systemVersionString() -> String{
        return UIDevice.currentDevice().systemVersion
    }
    static func systemVersion() -> Float{
        let sys = UIDevice.currentDevice().systemVersion
        return Float(sys)!
    }
    
    static func aboveIOS9() -> Bool{
        let sys = UIDevice.currentDevice().systemVersion
        return (Float(sys)! > 9.0)
    }
    static func aboveIOS8() -> Bool{
        let sys = UIDevice.currentDevice().systemVersion
        return (Float(sys)! > 8.0)
    }
    static func aboveIOS7() -> Bool{
        let sys = UIDevice.currentDevice().systemVersion
        return (Float(sys)! > 7.0)
    }
    
    static func keyWindow() -> UIWindow {
        return UIApplication.sharedApplication().keyWindow!
    }
    static func frontWindow() -> UIWindow {
        return UIApplication.sharedApplication().windows.last!
    }
    static func rootController() -> UIViewController {
        return UIApplication.sharedApplication().keyWindow!.rootViewController!
    }
    
    static func mainScreen() -> UIScreen {
        return UIScreen.mainScreen()
    }
    static func shareApplication() -> UIApplication {
        return UIApplication.sharedApplication()
    }
    static func appDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    static func defaultNotificationCenter() -> NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    static func fileManager() -> NSFileManager {
        return NSFileManager.defaultManager()
    }
    
    static func isInBackground() -> Bool {
        return Device.shareApplication().applicationState == .Background
    }
}


private var _UDID:String? = nil

func GET_UDID() -> String {
    if (_UDID == nil) {
        if let udid = NSUserDefaults.standardUserDefaults().objectForKey("UDID") as! String? {
            _UDID = udid
        } else {
            let uuid = UUID()
            _UDID = uuid
            NSUserDefaults.standardUserDefaults().setObject(uuid, forKey: "UDID")
        }
    }
    return _UDID!
}

func UUID() -> String {
    return NSUUID().UUIDString
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
}
