//
//  ChannelCollectionHeaderView.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/26.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class ChannelCollectionHeaderView: UICollectionReusableView {
    
    let weekLabel = UILabel()
    let timeLabel = UILabel()
    let weatherImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        

        prepareUI()
        
        updateContent()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onTap(gesture: UITapGestureRecognizer) {
        
        let panel = SelectiveTimePanel(frame: Device.keyWindow().bounds)
        Device.keyWindow().addSubview(panel)
        
    }

    func prepareUI() {
        let leftView = UIView()
        let rightView = UIView()
//        leftView.backgroundColor = UIColor.redColor()
//        rightView.backgroundColor = UIColor.greenColor()
        addSubview(leftView)
        addSubview(rightView)

        leftView.snp_makeConstraints { (make) in
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
            make.leftMargin.equalTo(15)
            make.right.equalTo(rightView.snp_left)
            make.width.equalTo(rightView.snp_width)
        }
        rightView.snp_makeConstraints { (make) in
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
            make.rightMargin.equalTo(-15)
            make.left.equalTo(leftView.snp_right)
            make.width.equalTo(leftView.snp_width)
        }
        
        let clockView = UIView()
        leftView.addSubview(clockView)
        clockView.clipsToBounds = true
        clockView.layer.cornerRadius = 40
        clockView.layer.borderWidth = 2
        clockView.layer.borderColor = UIColor.goldColor().CGColor
        clockView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(80, 80))
            make.center.equalTo(leftView.snp_center)
        }
        
        clockView.addSubview(weekLabel)
        weekLabel.textAlignment = .Center
        weekLabel.font = UIFont.sizeOf14()
        weekLabel.textColor = UIColor.goldColor()
        weekLabel.snp_makeConstraints { (make) in
            make.left.equalTo(clockView.snp_left)
            make.right.equalTo(clockView.snp_right)
            make.centerY.equalTo(clockView.snp_centerY).inset(10)
        }
        
        clockView.addSubview(timeLabel)
        timeLabel.textAlignment = .Center
        timeLabel.font = UIFont.sizeOf12()
        timeLabel.textColor = UIColor.goldColor()
        timeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(clockView.snp_left)
            make.right.equalTo(clockView.snp_right)
            make.centerY.equalTo(clockView.snp_centerY).inset(-10)
        }
        
        rightView.addSubview(weatherImageView)
        weatherImageView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(50, 50))
            make.right.equalTo(rightView.snp_right)
            make.topMargin.equalTo(15)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChannelCollectionHeaderView.onTap(_:)))
        clockView.addGestureRecognizer(tap)
    }
    
    func updateContent() {
        weekLabel.text = CoreDB.currentDayOfWeekString()
        timeLabel.text = CoreDB.currentTimeOfDayString()
        
        weatherImageView.image = UIImage(named: "weather_sun")
    }
    
}

protocol ChannelCollectionHeaderViewDelegate {
    func pressedClockView()
}
