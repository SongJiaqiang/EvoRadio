//
//  TabBar.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/15.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import SnapKit

class TabBar: UIView {
    let itemWidth:CGFloat = Device.width()*0.2
    
    var titles: [String]?
    var currentIndex: Int = 0
    private var sortView = UIView()
    private var lineConstraint: Constraint?
    var itemButtons = [UIButton]()
    var delegate: TabBarDelegate?
    
    convenience init(titles: [String]) {
        self.init()
        
        self.titles = titles
        
        prepareUI()
        sortButtonPressed(itemButtons.first!)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(netHex: 0x1C1C1D)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func prepareUI() {
        
        addSubview(sortView)
        sortView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 2, 0))
        }
        
        let count = titles!.count
        for i in 0..<count {
            let button = UIButton()
            button.setTitleColor(UIColor.grayColor7(), forState: .Normal)
            button.setTitleColor(UIColor.goldColor(), forState: .Selected)
            button.titleLabel?.font = UIFont.sizeOf14()
            let title = titles![i].stringByReplacingOccurrencesOfString("电台", withString: "")
            button.setTitle(title, forState: .Normal)
            button.tag = i
            button.addTarget(self, action: #selector(TabBar.sortButtonPressed(_:)), forControlEvents: .TouchUpInside)
            sortView.addSubview(button)
            
            button.snp_makeConstraints { (make) in
                make.width.equalTo(itemWidth)
                make.leftMargin.equalTo(itemWidth * CGFloat(i))
                make.height.equalTo(34)
                make.bottom.equalTo(sortView.snp_bottom)
            }
            itemButtons.append(button)
        }
        
        let line = UIView()
        addSubview(line)
        line.backgroundColor = UIColor.whiteColor()
        line.snp_makeConstraints { (make) in
            make.height.equalTo(2)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.bottom.equalTo(snp_bottom)
        }
        
        let maskLine = UIView()
        line.addSubview(maskLine)
        maskLine.backgroundColor = UIColor.goldColor()
        maskLine.snp_makeConstraints {[weak self] (make) in
            make.width.equalTo(Device.width()*0.2)
            make.height.equalTo(2)
            make.bottom.equalTo(line.snp_bottom)
            self?.lineConstraint = make.left.equalTo(line.snp_left).constraint
        }
    }
    
    
    
    func sortButtonPressed(button: UIButton) {
        
        delegate?.tabBarSelectedItemAtIndex(button.tag)
        
        updateCurrentIndex(button.tag)
    }
    
    func updateTitles(titles: [String]){
        for i in 0..<itemButtons.count {
            let title = titles[i].stringByReplacingOccurrencesOfString("电台", withString: "")
            itemButtons[i].setTitle(title, forState: .Normal)
        }
    }
    
    func updateLineConstraint(offsetX: CGFloat) {
        lineConstraint?.updateOffset(offsetX)
    }
    
    func updateCurrentIndex(index: Int) {
        currentIndex = index
        
        for btn in itemButtons {
            btn.selected = false
        }
        itemButtons[index].selected = true
    }
    
}

protocol TabBarDelegate {
    func tabBarSelectedItemAtIndex(index: Int)
}
