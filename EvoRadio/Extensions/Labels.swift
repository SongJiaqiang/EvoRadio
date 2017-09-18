//
//  Labels.swift
//  EvoRadio
//
//  Created by Jarvis on 11/26/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

extension UILabel {
    func textSize() -> CGSize {
        guard let labelText = self.text else {
            return CGSize.zero
        }
        
        let textString = NSString(string: labelText)
        let rect = textString.boundingRect(with: Device.size(), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: self.font], context: nil)
        
        return rect.size
    }
}
