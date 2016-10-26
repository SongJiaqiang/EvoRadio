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
    open static let shared = AssistiveTouch()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        backgroundColor = UIColor.black
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
        layer.borderColor = UIColor.gray.cgColor
        
    }

    func prepareUI() {
        imageView = UIImageView()
        addSubview(imageView)
        imageView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        if let image = UIImage(named: "touch_ring") {
            imageView.image = image
        }
        
        
    }
    
    func show() {
        UIView.animate(withDuration: 0.2, animations: {[weak self] in
            self?.alpha = 0.8
        }) 
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2, animations: {[weak self] in
            self?.alpha = 0
        }) 
    }
    
    func drawIcon() {
        
    }
    
    func updateImage(_ image: UIImage) {
        if image == imageView.image {
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {[weak self] in
            self?.imageView.alpha = 0
            }, completion: {[weak self] (finished) in
                self?.imageView.image = image
                UIView.animate(withDuration: 0.2, animations: {[weak self] in
                    self?.imageView.alpha = 1
                })
        }) 
        
    }
}

