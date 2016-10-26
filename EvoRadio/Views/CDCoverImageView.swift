//
//  CDCoverImageView.swift
//  EvoRadio
//
//  Created by Jarvis on 5/29/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import pop


class CDCoverImageView: UIImageView {

    var rotateAnimation:POPBasicAnimation
    
    var rotateTimer: CADisplayLink?

    override init(frame: CGRect) {
        
        self.rotateAnimation = POPBasicAnimation(propertyNamed: kPOPLayerRotation)
        
        super.init(frame: frame)
        
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = 120
        layer.borderWidth = 10
        layer.borderColor = UIColor(white: 0, alpha: 0.8).cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let _ = rotateTimer {
            rotateTimer?.invalidate()
            rotateTimer = nil
        }
    }
    
    
    func prepareAnimation()  {
        
        rotateAnimation.toValue = M_PI * 2
        rotateAnimation.duration = 16
        rotateAnimation.repeatForever = true
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rotateAnimation.beginTime = CACurrentMediaTime()+0.2
        layer.pop_add(rotateAnimation, forKey: "rotateAnimation")
        
        pauseAnimate()
    }
    
    func resetAnimation() {
        
        rotateAnimation.toValue = 0
        rotateAnimation.duration = 0.5
        layer.pop_add(rotateAnimation, forKey: "rotateAnimation")
        
    }
    
    func pauseAnimate() {
        rotateAnimation.isPaused = true
    }
    
    func resumeAnimate() {
        rotateAnimation.isPaused = false
    }
    
    
    
}
