//
//  HudManager.swift
//  EvoRadio
//
//  Created by Jarvis on 6/8/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation
import MBProgressHUD

class HudManager {
    
    var canceled = false
    
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
    
    class func showAnnularDeterminate(text: String, completion: (() -> Void)?) {
        let hud = MBProgressHUD.showHUDAddedTo(Device.keyWindow(), animated: true)
        hud.mode = .AnnularDeterminate
        hud.labelText = text
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { Void in
            // Do something useful in the background and update the HUD periodically.
            HudManager.simulateProgress(hud)
            dispatch_async(dispatch_get_main_queue(), { Void in
                hud.hide(true)
                if let _ = completion {
                    completion!()
                }
            })
        })
    }
    
    class func simulateProgress(hud: MBProgressHUD) {
        var progress: Float = 0;
        while progress < 1 {
            progress += 0.01
            dispatch_async(dispatch_get_main_queue(), { Void in
                hud.progress = progress
            })
            usleep(50000)
        }
    }
}