//
//  Windows.swift
//  EvoRadio
//
//  Created by Jarvis on 5/26/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

extension UIWindow {
    
    func topMostController() -> UIViewController? {
        
        var topController = rootViewController
        
        while let _ = topController?.presentedViewController {
            topController = topController?.presentedViewController
        }
        
        return topController
    }
}
