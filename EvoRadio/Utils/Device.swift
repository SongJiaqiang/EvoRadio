//
//  Device.swift
//  CameraReqairman
//
//  Created by Jarvis on 16/3/24.
//  Copyright © 2016年 SongJiaqiang. All rights reserved.
//

import UIKit

class Device: NSObject {

    class func width() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    class func height() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    class func size() -> CGSize {
        return UIScreen.main.bounds.size
    }
    class func screenScale() -> CGFloat {
        return UIScreen.main.scale
    }
    
    class func systemVersionString() -> String{
        return UIDevice.current.systemVersion
    }
    class func systemVersion() -> Float{
        let sys = UIDevice.current.systemVersion
        return Float(sys)!
    }
    
    class func appVersionString() -> String {
        if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] {
            return version as! String
        }
        return "未知"
    }
    
    class func aboveIOS9() -> Bool{
        let sys = UIDevice.current.systemVersion
        return (Float(sys)! > 9.0)
    }
    class func aboveIOS8() -> Bool{
        let sys = UIDevice.current.systemVersion
        return (Float(sys)! > 8.0)
    }
    class func aboveIOS7() -> Bool{
        let sys = UIDevice.current.systemVersion
        return (Float(sys)! > 7.0)
    }
    
    class func keyWindow() -> UIWindow {
        return UIApplication.shared.keyWindow!
    }
    class func frontWindow() -> UIWindow {
        return UIApplication.shared.windows.last!
    }
    class func rootController() -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    class func mainScreen() -> UIScreen {
        return UIScreen.main
    }
    class func shareApplication() -> UIApplication {
        return UIApplication.shared
    }
    class func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    class func fileManager() -> FileManager {
        return FileManager.default
    }
    
    class func isInBackground() -> Bool {
        return Device.shareApplication().applicationState == .background
    }
}


private var _UDID:String? = nil

func GET_UDID() -> String {
    if (_UDID == nil) {
        if let udid = UserDefaults.standard.object(forKey: "UDID") as! String? {
            _UDID = udid
        } else {
            let uuid = UUID()
            _UDID = uuid
            UserDefaults.standard.set(uuid, forKey: "UDID")
        }
    }
    return _UDID!
}

func UUID() -> String {
    return Foundation.UUID().uuidString
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
}
