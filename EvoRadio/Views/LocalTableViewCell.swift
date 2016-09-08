//
//  LocalTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 9/7/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class LocalTableViewCell: UITableViewCell {

    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var detailLabel: UILabel!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clearColor()
        selectedBackgroundView = UIView(color: UIColor(netHex: 0x222222), andSize: CGSizeMake(1, 1))
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        iconImageView = UIImageView()
        contentView.addSubview(iconImageView)
        iconImageView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.left.equalTo(contentView.snp_left).offset(10)
            make.centerY.equalTo(contentView.snp_centerY)
        }
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFontOfSize(16)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(contentView.snp_centerY).offset(-10)
            make.left.equalTo(iconImageView.snp_right).offset(10)
        }
        
        detailLabel = UILabel()
        contentView.addSubview(detailLabel)
        detailLabel.font = UIFont.systemFontOfSize(12)
        detailLabel.textColor = UIColor.grayColor()
        detailLabel.snp_makeConstraints { (make) in
            make.centerY.equalTo(contentView.snp_centerY).offset(10)
            make.left.equalTo(iconImageView.snp_right).offset(10)
        }
        
        let lineView = UIView()
        contentView.addSubview(lineView)
        lineView.backgroundColor = UIColor(netHex: 0x222222)
        lineView.snp_makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalTo(contentView.snp_bottom)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
        }
        
        let arrowImageView = UIImageView()
        contentView.addSubview(arrowImageView)
        arrowImageView.image = UIImage(named: "cell_assistive")
        arrowImageView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(14, 20))
            make.right.equalTo(contentView.snp_right).offset(-10)
            make.centerY.equalTo(contentView.snp_centerY)
        }
        
    }
    
    func setupData(dataInfo: [String: String]) {
        if let image = dataInfo["icon"] {
            iconImageView.image = UIImage(named: image)
        }
        
        if let title = dataInfo["title"] {
            titleLabel.text = title
        }
        
        if let count = dataInfo["count"] {
            detailLabel.text = count
        }
    }

    
}
