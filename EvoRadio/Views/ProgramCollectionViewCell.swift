//
//  ProgramCollectionViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/26.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class ProgramCollectionViewCell: UICollectionViewCell {
    
    let picImageView = UIImageView()
    let channelNameLabel = UILabel()
    let radioNameLabel = UILabel()
    let playButton = UIButton()
    let vipView = UIView()
    
    var program: Program?
    var delegate: ProgramCollectionViewCellDelegate?
    
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
//        picImageView.layer.cornerRadius = 2
        picImageView.snp_makeConstraints { (make) in
            make.height.equalTo(programCollectionCellWidth)
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
        
        addSubview(radioNameLabel)
        radioNameLabel.font = UIFont.systemFontOfSize(10)
        radioNameLabel.textColor = UIColor.grayColor6()
        radioNameLabel.snp_makeConstraints { (make) in
            make.height.equalTo(12)
            make.top.equalTo(channelNameLabel.snp_bottom)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
        }
        
        addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play_border"), forState: .Normal)
        playButton.setImage(UIImage(named: "player_play_border_prs"), forState: .Highlighted)
        playButton.addTarget(self, action: #selector(ProgramCollectionViewCell.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.leftMargin.equalTo(5)
            make.bottom.equalTo(picImageView.snp_bottom).offset(-5)
        }

        addSubview(vipView)
        vipView.backgroundColor = UIColor.goldColor()
        vipView.clipsToBounds = true
//        vipView.layer.cornerRadius = 2
        vipView.hidden = true
        vipView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(4, 4))
            make.rightMargin.equalTo(-2)
            make.bottomMargin.equalTo(-2)
        }
        
    }
    
    //MARK: event
    func playButtonPressed(button: UIButton) {
        if let p = program {
            delegate?.playMusicOfProgram(p.programID!)
        }
    }
    
    func updateContent(program: Program) {
        self.program = program

        if let programName = program.programName {
            channelNameLabel.text = programName
        }
        
        if let picURL = program.picURL {
            picImageView.kf_setImageWithURL(NSURL(string: picURL)!, placeholderImage: UIImage.placeholder_cover())
        }
        
        if let channels = program.channels {
            let c = channels.first
            
            if let channelName = c!.channelName {
                radioNameLabel.text = channelName
            }
        }
        
        if let vip = program.vipLevel {
            if Int(vip) > 0 {
                vipView.hidden = false
            }else {
                vipView.hidden = true
            }
        }
    }
}

protocol ProgramCollectionViewCellDelegate {
    func playMusicOfProgram(programID: String)
}
