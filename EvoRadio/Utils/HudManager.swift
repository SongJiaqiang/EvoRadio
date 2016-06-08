//
//  HudManager.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 6/8/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation
import MBProgressHUD

class HudManager {
    
    class func showText(text: String) {
        HudManager.showText(text, inView: Device.keyWindow())
    }
    
    class func showText(text: String, inView: UIView) {
        let hud = MBProgressHUD.showHUDAddedTo(inView, animated: true)
        hud.mode = .Text
        hud.labelText = text
        hud.yOffset = Float(Device.height()*0.5-60)
        hud.hide(true, afterDelay: 1)
    }
}