//
//  AssistiveTouch.swift
//  EvoRadio
//
//  Created by Jarvis on 9/2/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class AssistiveTouch: UIControl {

    
    var imageView: UIImageView!
    
    //MARK: instance
    class var sharedTouch: AssistiveTouch {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var sharedTouch: AssistiveTouch! = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.sharedTouch = AssistiveTouch(frame: CGRectZero)
        }
        return Static.sharedTouch
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = UIColor.blackColor()
        alpha = 0.8
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.grayColor().CGColor
        
    }

    func prepareUI() {
        imageView = UIImageView()
        addSubview(imageView)
        imageView.frame = CGRectMake(10, 10, 20, 20)
        if let image = UIImage(named: "ring_white") {
            imageView.image = image
        }
        
        
    }
    
    func show() {
        UIView.animateWithDuration(0.2) {[weak self] in
            self?.alpha = 0.8
        }
    }
    
    func hide() {
        UIView.animateWithDuration(0.2) {[weak self] in
            self?.alpha = 0
        }
    }
    
    func drawIcon() {
        
    }
    
    func setImage(image: UIImage, forState state: UIControlState) {
        imageView.image = image
    }
}

