//
//  Views.swift
//  EvoRadio
//
//  Created by Jarvis on 9/7/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit


extension UIView {
    convenience init(color: UIColor, andSize size: CGSize) {
        self.init()
        
        self.frame = CGRect(origin: CGPoint.zero, size: size)
        self.backgroundColor = color
    }
}
