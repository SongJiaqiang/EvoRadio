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
    var delegate: ChannelCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func prepareUI() {
        addSubview(picImageView)
        picImageView.contentMode = .ScaleAspectFill
        picImageView.clipsToBounds = true
        picImageView.snp_makeConstraints { (make) in
            make.height.equalTo(channelCollectionCellWidth)
            make.top.equalTo(snp_top)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
        }
        
        addSubview(channelNameLabel)
        channelNameLabel.font = UIFont.systemFontOfSize(12)
        channelNameLabel.textColor = UIColor.grayColor7()
        channelNameLabel.snp_makeConstraints { (make) in
            make.height.equalTo(18)
            make.top.equalTo(picImageView.snp_bottom)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
        }
        
        addSubview(tipLabel)
        tipLabel.font = UIFont.systemFontOfSize(10)
        tipLabel.textColor = UIColor.grayColor6()
        tipLabel.snp_makeConstraints { (make) in
            make.height.equalTo(12)
            make.top.equalTo(channelNameLabel.snp_bottom)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
        }
        
        addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play_border"), forState: .Normal)
        playButton.setImage(UIImage(named: "player_play_border_prs"), forState: .Highlighted)
        playButton.addTarget(self, action: #selector(ChannelCollectionViewCell.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.leftMargin.equalTo(5)
            make.bottom.equalTo(picImageView.snp_bottom).offset(-5)
        }
        
    }
    
    //MARK: event
    func playButtonPressed(button: UIButton) {
        if let c = channel {
            delegate?.playMusicOfChannel(c.channelID!)
        }
    }
    
    func updateContent(channel: Channel, isNow: Bool) {
        self.channel = channel
        
        if let picURL = channel.picURL {
            picImageView.kf_setImageWithURL(NSURL(string: picURL)!, placeholderImage: UIImage.placeholder_cover())
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

protocol ChannelCollectionViewCellDelegate {
    func playMusicOfChannel(channelID: String)
}
