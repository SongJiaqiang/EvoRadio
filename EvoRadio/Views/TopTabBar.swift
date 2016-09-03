//
//  TopTabBar.swift
//  EvoRadio
//
//  Created by Jarvis on 9/2/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class TopTabBar: UIView {

    var titles: [String]!
   
    convenience init(titles: [String]) {
        self.init()
        
        self.titles = titles
        
        prepareUI()
    }

    
    func prepareUI() {
        
        
        let label0 = UILabel()
        addSubview(label0)
        label0.textColor = UIColor.whiteColor()
        label0.font = UIFont.systemFontOfSize(10)
        label0.text = titles[0]
        label0.snp_makeConstraints { (make) in
            make.left.equalTo(snp_left).offset(2)
            make.bottom.equalTo(snp_bottom).offset(-2)
        }
        
        let label1 = UILabel()
        addSubview(label1)
        label1.textColor = UIColor.whiteColor()
        label1.font = UIFont.systemFontOfSize(10)
        label1.text = titles[1]
        label1.snp_makeConstraints { (make) in
            make.centerX.equalTo(snp_centerX)
            make.bottom.equalTo(snp_bottom).offset(-2)
        }
        
        let label2 = UILabel()
        addSubview(label2)
        label2.textColor = UIColor.whiteColor()
        label2.font = UIFont.systemFontOfSize(10)
        label2.text = titles[2]
        label2.snp_makeConstraints { (make) in
            make.right.equalTo(snp_right).offset(-2)
            make.bottom.equalTo(snp_bottom).offset(-2)
        }
        
        let topLine = UIView()
        addSubview(topLine)
        topLine.backgroundColor = UIColor.redColor()
        topLine.snp_makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(2)
            make.centerX.equalTo(snp_centerX)
            make.top.equalTo(snp_top)
//            make.bottom.equalTo(label1.snp_top)
        }
    }
}
