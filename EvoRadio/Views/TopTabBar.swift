//
//  TopTabBar.swift
//  EvoRadio
//
//  Created by Jarvis on 9/2/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import SnapKit

protocol TopTabBarDelegate {
    func tabBarOnTap(tabBar: TopTabBar)
}

class TopTabBar: UIView {

    var titles: [String]!
    var labels = [UILabel]()
    var contentView: UIView!
    var topLine: UIView!
    
    var currentIndex:Int = 1
   
    open static let mainBar = TopTabBar(titles: ["电台","当下","本地"])
    open var delegate: TopTabBarDelegate?
    
    
    convenience init(titles: [String]) {
        self.init()
        
        self.titles = titles
        self.backgroundColor = UIColor.black
        
        prepareUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TopTabBar.onTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    
    func prepareUI() {
        
        contentView = UIView()
        addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: 4, width: Device.width(), height: 14)
        let fontSize = UIFont.systemFont(ofSize: 12)
        
        let textAttrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: fontSize
        ]
        let maxSize = CGSize(width: 100, height: 20)
        
        for i in 0..<titles.count {
            let text = titles[i]
            let label = UILabel()
            label.textColor = UIColor.white
            label.font = fontSize
            label.text = text
            contentView.addSubview(label)
            let textRect = (text as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: textAttrs, context: nil)
            label.frame = CGRect(origin: CGPoint(x: Device.width() / 2 * CGFloat(i), y: 0), size: textRect.size)
            label.textColor = UIColor.grayColor5()
            
            labels.append(label)
        }
        labels[currentIndex].textColor = UIColor.white
    }
    
    func onTap(_ gesture: UIGestureRecognizer) {
        if let _ = delegate {
            delegate?.tabBarOnTap(tabBar: TopTabBar.mainBar)
        }
    }
    
    
    open func updateFrames() {
        
        for i in 0..<labels.count{
            let label = labels[i]
            let labelSize = label.textSize()
            
            let t = i - currentIndex
            
            let totleDistance = (Device.width() - labelSize.width) / 2
            let x = totleDistance + (Device.width() - labelSize.width) / 2 * CGFloat(t)
            label.frame = CGRect(origin: CGPoint(x: x, y: 0), size: labelSize)
            
            label.textColor = UIColor.grayColor5()
        }
        labels[currentIndex].textColor = UIColor.white
    }
    
    open func animationWithOffsetX(_ offsetX: CGFloat) {
        // 计算公式： x / distance = (offsetX - SCREEN_WIDTH * index) / SCREEN_WIDTH
        
        for i in 0..<labels.count{
            let label = labels[i]
            let labelSize = label.textSize()
            
            let t = i - currentIndex
            
            let totleDistance = (Device.width() - labelSize.width) / 2
            let moveDistance = totleDistance * ((offsetX - Device.width() * CGFloat(currentIndex)) / Device.width())
            let x = totleDistance - moveDistance + (Device.width() - labelSize.width) / 2 * CGFloat(t)
            label.frame = CGRect(origin: CGPoint(x: x, y: 0), size: labelSize)
        }
    }
    
    
    open func updateTitle(title: String, atIndex: Int) {

        titles[atIndex] = title
        labels[atIndex].text = title
        
        updateFrames()
    }
}
