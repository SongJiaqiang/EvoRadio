//
//  SimpleTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 24/09/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

import UIKit

class SimpleTableViewCell: UITableViewCell {
    
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    var separatorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        selectedBackgroundView = UIView(color: UIColor(netHex: 0x222222), andSize: CGSize(width: 1, height: 1))
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        
        titleLabel.font = UIFont.size18()
        titleLabel.textColor = UIColor.grayColorBF()
        titleLabel.text = "Title text"
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.top.equalTo(self.snp.top).offset(10)
        }
        
        subtitleLabel.font = UIFont.size14()
        subtitleLabel.textColor = UIColor.grayColor97()
        subtitleLabel.text = "Subtitle text"
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(15)
            make.right.equalTo(self.snp.right).offset(-15)
            make.bottom.equalTo(self.snp.bottom).offset(-10)
        }
        
        separatorView.backgroundColor = UIColor.grayColor66()
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
    }
    
    
    //MARK: events
    func update(title: String?, subTitle: String?) {
        if let t = title {
            titleLabel.isHidden = false
            titleLabel.text = t
        }else {
            titleLabel.isHidden = true
        }
        
        if let st = subTitle {
            subtitleLabel.isHidden = false
            subtitleLabel.text = st
        }else {
            subtitleLabel.isHidden = true
        }
        
    }

}
