//
//  PlayerView.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/5/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import SnapKit

enum PlayerViewStatus: Int{
    case Closed = 0
    case WillClose = 1
    case Opened = 2
    case WillOpen = 3
}


let playerView = PlayerView.instance

class PlayerView: UIView {
    
    let playerBar = PlayerBar()
    
    var playerViewStatus: PlayerViewStatus = .Closed
    var playerViewTopConstraint: Constraint?
    
    //MARK: instance
    class var instance: PlayerView {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlayerView! = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = PlayerView()
        }
        return Static.instance
    }

    func prepare() {
        backgroundColor = UIColor.blackColor()
        
        let window = Device.keyWindow()
        window.addSubview(self)
        self.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(Device.width(), Device.height()))
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            playerViewTopConstraint = make.topMargin.equalTo(Device.height()-playerBarHeight).constraint
        }
        
        
        playerBar.delegate = self
        addSubview(playerBar)
        playerBar.snp_makeConstraints { (make) in
            make.height.equalTo(playerBarHeight)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            make.topMargin.equalTo(0)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlayerView.handleTap(_:)))
        addGestureRecognizer(tap)
    }
    
    //MARK: events
    func handleTap(gesture: UIGestureRecognizer) {
        print("press player bar")
        
        hide()
        Device.keyWindow().topMostController()?.presentViewController(playerControler, animated: true, completion: nil)
    }
    
    
    
    func show() {
        UIView.animateWithDuration(0.5, animations: {[weak self] Void in self?.alpha = 1 })
    }
    
    func hide() {
        UIView.animateWithDuration(0.5, animations: {[weak self] Void in self?.alpha = 0 })
    }
    
}

extension PlayerView: PlayerBarDelegate {
    
    func playerBarPressed() {
        
    }
    
    
    func playerBarPressedOnStart() {}
    func playerBarPressedOnCover() {}
    func playerBarSlided(direction: SlideDirection, offset: CGPoint) {}
    
}
