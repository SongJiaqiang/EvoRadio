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
        
        backgroundColor = UIColor.clear
        selectedBackgroundView = UIView(color: UIColor(netHex: 0x222222), andSize: CGSize(width: 1, height: 1))
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        iconImageView = UIImageView()
        contentView.addSubview(iconImageView)
        iconImageView.contentMode = .center
        iconImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.left.equalTo(contentView.snp.left).offset(10)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.white
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView.snp.centerY).offset(-10)
            make.left.equalTo(iconImageView.snp.right).offset(10)
        }
        
        detailLabel = UILabel()
        contentView.addSubview(detailLabel)
        detailLabel.font = UIFont.systemFont(ofSize: 12)
        detailLabel.textColor = UIColor.gray
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView.snp.centerY).offset(10)
            make.left.equalTo(iconImageView.snp.right).offset(10)
        }
        
        let lineView = UIView()
        contentView.addSubview(lineView)
        lineView.backgroundColor = UIColor(netHex: 0x222222)
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.equalTo(contentView.snp.bottom)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
        }
        
        let arrowImageView = UIImageView()
        contentView.addSubview(arrowImageView)
        arrowImageView.image = UIImage(named: "cell_assistive")
        arrowImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 14, height: 20))
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
    }
    
    func setupData(_ dataInfo: [String: String]) {
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
