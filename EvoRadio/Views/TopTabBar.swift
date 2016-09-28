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
    var labels = [UILabel]()
    var contentView: UIView!
    var topLine: UIView!
    
    var topLineWidth: CGFloat = 40
    var topLineHeight: CGFloat = 2
    
    var currentIndex:Int = 0
   
    convenience init(titles: [String]) {
        self.init()
        
        self.titles = titles
        self.backgroundColor = UIColor.blackColor()
        
        prepareUI()
    }
    
    func prepareUI() {
        
        contentView = UIView()
        addSubview(contentView)
        contentView.frame = CGRectMake(0, 6, Device.width(), 14)
        
        let textAttrs = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(10)
        ]
        let maxSize = CGSizeMake(Device.width(), Device.height())
        
        for i in 0..<titles.count {
            let text = titles[i]
            let label = UILabel()
            label.textColor = UIColor.whiteColor()
            label.font = UIFont.systemFontOfSize(10)
            label.text = text
            contentView.addSubview(label)
            let textRect = (text as NSString).boundingRectWithSize(maxSize, options: .UsesLineFragmentOrigin, attributes: textAttrs, context: nil)
            label.frame = CGRect(origin: CGPointMake(Device.width() / 2 * CGFloat(i), 0), size: textRect.size)
            
            labels.append(label)
        }
        
        topLine = UIView()
        addSubview(topLine)
        topLine.backgroundColor = UIColor.redColor()
        topLine.frame = CGRectMake((Device.width() - 40) / 2, 0, 40, 2)
        
    }
    
    
    func updateFrames() {
        
        for i in 0..<labels.count{
            let label = labels[i]
            let labelSize = label.frame.size
            
            let t = i - currentIndex
            
            if t == 0 {
                label.frame = CGRect(origin: CGPointMake((Device.width() - label.frame.size.width) / 2, 0), size: labelSize)
            } else if t == -1 {
                label.frame = CGRect(origin: CGPointMake(0, 0), size: labelSize)
            } else if t == 1 {
                label.frame = CGRect(origin: CGPointMake(Device.width() - label.frame.size.width, 0), size: labelSize)
            } else {
                label.frame = CGRect(origin: CGPointMake((Device.width() / 2) * CGFloat(t), 0), size: labelSize)
            }
            
        }
    }
    
    func animationWithOffsetX(offsetX: CGFloat) {
        // 计算公式： x / distance = (offsetX - SCREEN_WIDTH * index) / SCREEN_WIDTH
        
        for i in 0..<labels.count{
            let label = labels[i]
            let labelSize = label.frame.size
            
            let t = i - currentIndex
            
            let totleDistance = (Device.width() - CGRectGetWidth(label.frame)) / 2
            let moveDistance = totleDistance * ((offsetX - Device.width() * CGFloat(currentIndex)) / Device.width())
            let x = totleDistance - moveDistance + (Device.width() - CGRectGetWidth(label.frame)) / 2 * CGFloat(t)
            label.frame = CGRect(origin: CGPointMake(x, 0), size: labelSize)
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
    
}
