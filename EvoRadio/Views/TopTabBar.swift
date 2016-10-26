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
        self.backgroundColor = UIColor.black
        
        prepareUI()
    }
    
    func prepareUI() {
        
        contentView = UIView()
        addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: 6, width: Device.width(), height: 14)
        
        let textAttrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 10)
        ]
        let maxSize = CGSize(width: Device.width(), height: Device.height())
        
        for i in 0..<titles.count {
            let text = titles[i]
            let label = UILabel()
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 10)
            label.text = text
            contentView.addSubview(label)
            let textRect = (text as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: textAttrs, context: nil)
            label.frame = CGRect(origin: CGPoint(x: Device.width() / 2 * CGFloat(i), y: 0), size: textRect.size)
            
            labels.append(label)
        }
        
        topLine = UIView()
        addSubview(topLine)
        topLine.backgroundColor = UIColor.red
        topLine.frame = CGRect(x: (Device.width() - 40) / 2, y: 0, width: 40, height: 2)
        
    }
    
    
    func updateFrames() {
        
        for i in 0..<labels.count{
            let label = labels[i]
            let labelSize = label.frame.size
            
            let t = i - currentIndex
            
            if t == 0 {
                label.frame = CGRect(origin: CGPoint(x: (Device.width() - label.frame.size.width) / 2, y: 0), size: labelSize)
            } else if t == -1 {
                label.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: labelSize)
            } else if t == 1 {
                label.frame = CGRect(origin: CGPoint(x: Device.width() - label.frame.size.width, y: 0), size: labelSize)
            } else {
                label.frame = CGRect(origin: CGPoint(x: (Device.width() / 2) * CGFloat(t), y: 0), size: labelSize)
            }
            
        }
    }
    
    func animationWithOffsetX(_ offsetX: CGFloat) {
        // 计算公式： x / distance = (offsetX - SCREEN_WIDTH * index) / SCREEN_WIDTH
        
        for i in 0..<labels.count{
            let label = labels[i]
            let labelSize = label.frame.size
            
            let t = i - currentIndex
            
            let totleDistance = (Device.width() - label.frame.width) / 2
            let moveDistance = totleDistance * ((offsetX - Device.width() * CGFloat(currentIndex)) / Device.width())
            let x = totleDistance - moveDistance + (Device.width() - label.frame.width) / 2 * CGFloat(t)
            label.frame = CGRect(origin: CGPoint(x: x, y: 0), size: labelSize)
        }
    }
    
    func updateTopLineFrame() {
        topLineHeight = frame.size.height-20+2
        topLineWidth = 40*2 / topLineHeight
        if topLineWidth < 2 {
            topLineWidth = 2
        }
        topLine.frame = CGRect(x: (frame.size.width-40)/2, y: 0, width: topLineWidth, height: topLineHeight)
    }
    
}
