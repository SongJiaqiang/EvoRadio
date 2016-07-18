//
//  NavigationController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/17.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}
