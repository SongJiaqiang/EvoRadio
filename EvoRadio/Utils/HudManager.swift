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
    
    class func showText(_ text: String) {
        HudManager.showText(text, inView: Device.keyWindow())
    }
    
    class func showText(_ text: String, inView: UIView) {
        let hud = MBProgressHUD.showAdded(to: inView, animated: true)
        hud.mode = .text
        hud.label.text = text
        hud.offset.y = Device.height()*0.5-60
        hud.hide(animated: true, afterDelay: 1)
    }
    
    class func showAnnularDeterminate(_ text: String, completion: (() -> Void)?) {
        let hud = MBProgressHUD.showAdded(to: Device.keyWindow(), animated: true)
        hud.mode = .annularDeterminate
        hud.label.text = text
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { Void in
            // Do something useful in the background and update the HUD periodically.
            HudManager.simulateProgress(hud)
            DispatchQueue.main.async(execute: { Void in
                hud.hide(animated: true)
                if let _ = completion {
                    completion!()
                }
            })
        })
    }
    
    class func simulateProgress(_ hud: MBProgressHUD) {
        var progress: Float = 0;
        while progress < 1 {
            progress += 0.01
            DispatchQueue.main.async(execute: { Void in
                hud.progress = progress
            })
            usleep(50000)
        }
    }
}
