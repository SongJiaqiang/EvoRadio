//
//  ChannelCollectionViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/26.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    let picImageView = UIImageView()
    let channelNameLabel = UILabel()
    let tipLabel = UILabel()
    let playButton = UIButton()

    var channel: Channel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func prepareUI() {
        addSubview(picImageView)
        picImageView.contentMode = .scaleAspectFill
        picImageView.clipsToBounds = true
        picImageView.snp.makeConstraints { (make) in
            make.height.equalTo(channelCollectionCellWidth)
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
        }
        
        addSubview(channelNameLabel)
        channelNameLabel.font = UIFont.systemFont(ofSize: 12)
        channelNameLabel.textColor = UIColor.grayColor7()
        channelNameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(18)
            make.top.equalTo(picImageView.snp.bottom)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
        }
        
        addSubview(tipLabel)
        tipLabel.font = UIFont.systemFont(ofSize: 10)
        tipLabel.textColor = UIColor.grayColor6()
        tipLabel.snp.makeConstraints { (make) in
            make.height.equalTo(12)
            make.top.equalTo(channelNameLabel.snp.bottom)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
        }

    }
    
    //MARK: event
    func updateContent(_ channel: Channel, isNow: Bool) {
        self.channel = channel
        
        if let picURL = channel.picURL {
            picImageView.kf.setImage(with: URL(string: picURL)!, placeholder: UIImage.placeholder_cover())
        }
        
        if let channelName = channel.channelName {
            channelNameLabel.text = channelName
        }
        
        if isNow {
            if let radioID = channel.radioID {
                let allChannels = CoreDB.getAllChannels()
                for c in allChannels! {
                    if c["radio_id"] as? Int == Int(radioID) {
                        tipLabel.text = c["radio_name"] as? String
                    }
                }
            }
        }else {
            if let programNum = channel.programNum {
                tipLabel.text = "节目(\(programNum))"
            }
        }
    }
}
