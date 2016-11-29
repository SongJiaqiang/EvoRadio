//
//  RadioTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 9/3/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

let itemMargin: CGFloat = 10

protocol RadioTableViewCellDelegate: NSObjectProtocol {
    func radioTableViewCell(_ cell: RadioTableViewCell, didSelectedItem channel: Channel)
    func radioTableViewCell(_ cell: RadioTableViewCell, showMoreChannelWithRadio radioId: Int)
}

class RadioTableViewCell: UITableViewCell {

    var itemWidth: CGFloat = 0
    var scrollView: UIScrollView!
    var containerView: UIView!
    
    var radio: Radio?
    
    var delegate: RadioTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: prepare
    func prepareUI() {
        
        // 显示2.5个单位
        // | ** ** *|
        itemWidth = (Device.width() - itemMargin * 3) / 2.5
        
        
        
//        scrollView = UIScrollView()
//        contentView.addSubview(scrollView)
//        scrollView.frame = CGRectMake(0, 0, Device.width(), itemWidth+itemMargin*2)
        
        containerView = UIView()
        contentView.addSubview(containerView)
        containerView.frame = CGRect(x: 0, y: 0, width: Device.width(), height: itemWidth+itemMargin*2)
        
        let moreButton = UIButton()
        contentView.addSubview(moreButton)
        moreButton.setTitleColor(UIColor.white, for: UIControlState())
        moreButton.setTitle("More", for: UIControlState())
        moreButton.titleLabel?.font = UIFont.sizeOf10()
        moreButton.frame = CGRect(x: Device.width()-itemWidth/2, y: 10, width: itemWidth/2, height: itemWidth)
        moreButton.setBackgroundImage(UIImage(named: "gradient_white"), for: UIControlState())
        moreButton.addTarget(self, action: #selector(RadioTableViewCell.moreButtonPressed(_:)), for: .touchUpInside)
        
    }
    
    func setupChannels(_ radio: Radio) {
        self.radio = radio
        
        if let channels = radio.channels {
            let count: Int = channels.count < 3 ? channels.count : 3
            for i in 0..<count {
                
                let imageView = UIButton()
                containerView.addSubview(imageView)
                imageView.frame = CGRect(x: itemMargin+(itemWidth+itemMargin) * CGFloat(i), y: itemMargin, width: itemWidth, height: itemWidth)
                imageView.clipsToBounds = true
                imageView.contentMode = .scaleAspectFill
                imageView.addTarget(self, action: #selector(RadioTableViewCell.selectItem(_:)), for: .touchUpInside)
                imageView.tag = i
                
                let nameLabel = UILabel()
                imageView.addSubview(nameLabel)
                nameLabel.frame = CGRect(x: 10, y: itemWidth-30, width: itemWidth-20, height: 30)
                nameLabel.font = UIFont.systemFont(ofSize: 12)
                nameLabel.textColor = UIColor.white
                
                let channel = channels[i]
                if let picURL = URL(string: channel.picURL!) {
                    imageView.kf.setImage(with: picURL, for: .normal, placeholder: UIImage.placeholder_cover())
                }
                
                nameLabel.text = channel.channelName
                
            }
        }
    }
    
    //MARK: events
    func moreButtonPressed(_ button: UIButton) {
        if let _ = delegate {
            if let radioId = radio!.radioID {
                delegate?.radioTableViewCell(self, showMoreChannelWithRadio: radioId.intValue)
            }
        }
    }
    
    func selectItem(_ button: UIButton) {
        if let _ = delegate {
            if let channels = radio!.channels {
                delegate?.radioTableViewCell(self, didSelectedItem: channels[button.tag])
            }
        }
    }

}
