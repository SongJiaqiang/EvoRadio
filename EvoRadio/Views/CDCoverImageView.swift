//
//  CDCoverImageView.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 5/29/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class CDCoverImageView: UIImageView {

    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let holeRect = CGRectMake((rect.size.width-40)*0.5, (rect.size.height-40)*0.5, 40, 40)
        
        let holeRectIntersection = CGRectIntersection(holeRect, rect)
        UIColor.clearColor().setFill()
        UIRectFill(holeRectIntersection)
    }

}
