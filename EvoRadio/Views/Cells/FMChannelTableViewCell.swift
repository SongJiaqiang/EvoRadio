//
//  FMChannelTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 2020/3/29.
//  Copyright © 2020 JQTech. All rights reserved.
//

import UIKit

class FMChannelTableViewCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColors.textColorDark
        label.font = UIFont.size14()
        return label
    }()
    
    lazy var dotView: UIView = {
        let dot = UIView()
        dot.backgroundColor = ThemeColors.textColorDark
        dot.isHidden = true
        return dot
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        prepareUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        self.backgroundColor = ThemeColors.bgColorDark
        self.selectionStyle = .none
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(dotView)
        
        dotView.layer.cornerRadius = 4
        
        dotView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        dotView.autoAlignAxis(toSuperviewAxis: .horizontal)
        dotView.autoSetDimensions(to: CGSize(width: 8, height: 8))
        
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        titleLabel.autoPinEdge(.left, to: .right, of: dotView, withOffset: 4)
    }

    
    func setupTitle(_ title: String, isSelected: Bool = false) {
        titleLabel.text = title
        dotView.isHidden = !isSelected
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
//        print("cell did selected ")
    }
}
