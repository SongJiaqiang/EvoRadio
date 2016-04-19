//
//  TabBar.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/15.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class TabBar: UIView {
    
    var titles: [String]?
    var currentIndex: Int = 0
    private var sortView = UIView()
    
    convenience init(titles: [String]) {
        self.init()
        
        self.titles = titles
        
        prepareUI()
        
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
            let sortButton = UIButton()
            sortButton.setTitleColor(UIColor.goldColor(), forState: .Normal)
            sortButton.titleLabel?.font = UIFont.sizeOf14()
            sortButton.setTitle(titles![i], forState: .Normal)
            sortButton.tag = i
            sortButton.addTarget(self, action: #selector(TabBar.sortButtonPressed(_:)), forControlEvents: .TouchUpInside)
            sortView.addSubview(sortButton)
            let labelWidth:CGFloat = Device.width()*0.2
            sortButton.snp_makeConstraints { (make) in
                make.width.equalTo(labelWidth)
                make.leftMargin.equalTo(labelWidth * CGFloat(i))
                make.height.equalTo(34)
                make.bottom.equalTo(sortView.snp_bottom)
            }
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
        maskLine.snp_makeConstraints { (make) in
            make.width.equalTo(Device.width()*0.2)
            make.height.equalTo(2)
            make.bottom.equalTo(line.snp_bottom)
            make.left.equalTo(line.snp_left)
        }
        
        
    }
    
    func sortButtonPressed(button: UIButton) {
        print("selected item \(titles![button.tag])")
    }
    
    func setCurrentIndex(index: Int, animated: Bool) {
        currentIndex = index
        
        if animated {
            // do animation
            
        }
        
    }
    
}
