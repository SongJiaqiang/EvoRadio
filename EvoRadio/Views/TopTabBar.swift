//
//  TopTabBar.swift
//  EvoRadio
//
//  Created by Jarvis on 9/2/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import SnapKit

class TopTabBar: UIView {

    
    
    var titles: [String]!
    var contentView: UIView!
    var label0: UILabel!
    var label1: UILabel!
    var label2: UILabel!
    var topLine: UIView!
    
    var topLineWidth: CGFloat = 40
    var topLineHeight: CGFloat = 2
    
    var contentViewLeftConstaint: Constraint!
   
    convenience init(titles: [String]) {
        self.init()
        
        self.titles = titles
        self.backgroundColor = UIColor.blackColor()
        
        prepareUI()
    }
    
    func prepareUI() {
        
        contentView = UIView()
        addSubview(contentView)
        contentView.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.width.equalTo(Device.width())
            contentViewLeftConstaint = make.left.equalTo(snp_left).offset(0).constraint
//            make.right.equalTo(snp_right)
            make.bottom.equalTo(snp_bottom)
        }
        
        label0 = UILabel()
        contentView.addSubview(label0)
        label0.font = UIFont.systemFontOfSize(10)
        label0.textColor = UIColor.whiteColor()
        label0.textAlignment = .Center
        label0.text = titles[0]
        label0.snp_makeConstraints { (make) in
            make.left.equalTo(contentView.snp_left).offset(2)
            make.centerY.equalTo(contentView.snp_centerY)
        }
        
        label1 = UILabel()
        contentView.addSubview(label1)
        label1.font = UIFont.systemFontOfSize(10)
        label1.textColor = UIColor.whiteColor()
        label1.textAlignment = .Center
        label1.text = titles[1]
        label1.snp_makeConstraints { (make) in
            make.center.equalTo(contentView.snp_center)
        }
        
        label2 = UILabel()
        contentView.addSubview(label2)
        label2.font = UIFont.systemFontOfSize(10)
        label2.textColor = UIColor.whiteColor()
        label2.textAlignment = .Center
        label2.text = titles[2]
        label2.snp_makeConstraints { (make) in
            make.right.equalTo(contentView.snp_right).offset(-2)
            make.centerY.equalTo(contentView.snp_centerY)
        }
        
        topLine = UIView()
        addSubview(topLine)
        topLine.backgroundColor = UIColor.redColor()
        topLine.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 2))
            make.centerX.equalTo(snp_centerX)
            make.top.equalTo(snp_top)
        }
        
    }
    
    func updateTopLineFrame() {
        topLineHeight = frame.size.height-20+2
        topLineWidth = 40*2 / topLineHeight
        if topLineWidth < 2 {
            topLineWidth = 2
        }
        topLine.frame = CGRectMake((frame.size.width-40)/2, 0, topLineWidth, topLineHeight)
    }
    
    func updateContentViewConstraint(offsetX: CGFloat) {
        contentViewLeftConstaint.updateOffset(offsetX)
    }
}
