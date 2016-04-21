//
//  PlayerBar.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/17.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class PlayerBar: UIView {
    private var coverView = UIImageView()
    private var titleLabel = UILabel()
    private var subTitleLabel = UILabel()
    private var playButton = UIButton()
    
    
    init() {
        super.init(frame: CGRectMake(0, Device.width()-50, Device.width(), 50))
        
        insertGradientLayer()
        
        prepareUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PlayerBar.onTap))
        addGestureRecognizer(tapGesture)
        userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertGradientLayer() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(netHex:0x52554A, alpha: 0.75).CGColor,UIColor(netHex: 0x414643, alpha: 1).CGColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0.5)
        gradientLayer.endPoint = CGPointMake(1, 0.5)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func prepareUI() {
        addSubview(coverView)
        coverView.image = UIImage(named: "placeholder_cover")
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 20
        coverView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.leftMargin.equalTo(10)
            make.centerY.equalTo(snp_centerY)
        }
        
        addSubview(playButton)
        playButton.setTitle("播放", forState: .Normal)
        
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.rightMargin.equalTo(-10)
            make.centerY.equalTo(snp_centerY)
        }
        
        addSubview(titleLabel)
        titleLabel.text = "灵魂中的歌声"
        titleLabel.font = UIFont.sizeOf12()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverView.snp_right).inset(-10)
            make.right.equalTo(playButton.snp_left).inset(10)
            make.bottom.equalTo(snp_centerY)
        }
        
        addSubview(subTitleLabel)
        subTitleLabel.text = "活动电台 - 睡眠"
        subTitleLabel.font = UIFont.sizeOf10()
        subTitleLabel.textColor = UIColor.blackColor6()
        subTitleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverView.snp_right).inset(-10)
            make.right.equalTo(playButton.snp_left).inset(10)
            make.top.equalTo(snp_centerY)
        }
        
        
    }
    
    //MARK: event
    func onTap(gesture: UITapGestureRecognizer) {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(PlayerViewController(), animated: true, completion: nil)
    }
}
