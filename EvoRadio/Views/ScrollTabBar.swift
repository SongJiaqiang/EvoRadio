//
//  ScrollTabBar.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/15.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import SnapKit

class ScrollTabBar: UIView {
    let itemWidth:CGFloat = Device.width()*0.2
    
    var titles: [String]?
    var currentIndex: Int = 0
    fileprivate var sortView = UIView()
    fileprivate var lineConstraint: Constraint?
    var itemButtons = [UIButton]()
    var delegate: ScrollTabBarDelegate?
    
    convenience init(titles: [String]) {
        self.init()
        
        self.titles = titles
        
        prepareUI()
        sortButtonPressed(itemButtons.first!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.grayColor2()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func prepareUI() {
        
        addSubview(sortView)
        sortView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 2, 0))
        }
        
        let count = titles!.count
        for i in 0..<count {
            let button = UIButton()
            button.setTitleColor(UIColor.grayColor7(), for: UIControlState())
            button.setTitleColor(UIColor.goldColor(), for: .selected)
            button.titleLabel?.font = UIFont.sizeOf14()
            let title = titles![i].replacingOccurrences(of: "电台", with: "")
            button.setTitle(title, for: UIControlState())
            button.tag = i
            button.addTarget(self, action: #selector(ScrollTabBar.sortButtonPressed(_:)), for: .touchUpInside)
            sortView.addSubview(button)
            
            button.snp.makeConstraints { (make) in
                make.width.equalTo(itemWidth)
                make.leftMargin.equalTo(itemWidth * CGFloat(i))
                make.top.equalTo(sortView.snp.top)
                make.bottom.equalTo(sortView.snp.bottom)
            }
            itemButtons.append(button)
        }
        
        let line = UIView()
        addSubview(line)
        line.backgroundColor = UIColor.white
        line.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
            make.bottom.equalTo(snp.bottom)
        }
        
        let maskLine = UIView()
        line.addSubview(maskLine)
        maskLine.backgroundColor = UIColor.goldColor()
        maskLine.snp.makeConstraints {[weak self] (make) in
            make.width.equalTo(Device.width()*0.2)
            make.height.equalTo(2)
            make.bottom.equalTo(line.snp.bottom)
            self?.lineConstraint = make.left.equalTo(line.snp.left).constraint
        }
    }
    
    
    
    func sortButtonPressed(_ button: UIButton) {
        
        delegate?.scrollTabBar(self, didSelectedItemIndex: button.tag)
        
        updateCurrentIndex(button.tag)
    }
    
    func updateTitles(_ titles: [String]){
        for i in 0..<itemButtons.count {
            let title = titles[i].replacingOccurrences(of: "电台", with: "")
            itemButtons[i].setTitle(title, for: UIControlState())
        }
    }
    
    func updateLineConstraint(_ offsetX: CGFloat) {
        lineConstraint?.update(offset: offsetX)
    }
    
    func updateCurrentIndex(_ index: Int) {
        currentIndex = index
        
        for btn in itemButtons {
            btn.isSelected = false
        }
        itemButtons[index].isSelected = true
    }
    
}

protocol ScrollTabBarDelegate {
    func scrollTabBar(_ scrollTabBar: ScrollTabBar, didSelectedItemIndex index: Int)
}
