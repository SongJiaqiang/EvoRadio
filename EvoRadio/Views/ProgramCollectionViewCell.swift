//
//  ProgramCollectionViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/26.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        picImageView.contentMode = .scaleAspectFill
        picImageView.clipsToBounds = true
//        picImageView.layer.cornerRadius = 2
        picImageView.snp.makeConstraints { (make) in
            make.height.equalTo(programCollectionCellWidth)
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
        
        addSubview(radioNameLabel)
        radioNameLabel.font = UIFont.systemFont(ofSize: 10)
        radioNameLabel.textColor = UIColor.grayColor6()
        radioNameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(12)
            make.top.equalTo(channelNameLabel.snp.bottom)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
        }
        
        addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play_border"), for: UIControlState())
        playButton.setImage(UIImage(named: "player_play_border_prs"), for: .highlighted)
        playButton.addTarget(self, action: #selector(ProgramCollectionViewCell.playButtonPressed(_:)), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.leftMargin.equalTo(5)
            make.bottom.equalTo(picImageView.snp.bottom).offset(-5)
        }

        addSubview(vipView)
        vipView.backgroundColor = UIColor.goldColor()
        vipView.clipsToBounds = true
//        vipView.layer.cornerRadius = 2
        vipView.isHidden = true
        vipView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 4, height: 4))
            make.rightMargin.equalTo(-2)
            make.bottomMargin.equalTo(-2)
        }
        
    }
    
    //MARK: event
    func playButtonPressed(_ button: UIButton) {
        if let p = program {
            delegate?.playMusicOfProgram(p.programID!)
        }
    }
    
    func updateContent(_ program: Program) {
        self.program = program

        if let programName = program.programName {
            channelNameLabel.text = programName
        }
        
        if let picURL = URL(string: program.picURL!) {
            picImageView.kf.setImage(with: picURL, placeholder: UIImage.placeholder_cover())
        }
        
        if let channels = program.channels {
            let c = channels.first
            
            if let channelName = c!.channelName {
                radioNameLabel.text = channelName
            }
        }
        
//        if let vip = program.vipLevel {
//            if Int(vip) > 0 {
//                vipView.isHidden = false
//            }else {
//                vipView.isHidden = true
//            }
//        }
    }
}

protocol ProgramCollectionViewCellDelegate {
    func playMusicOfProgram(_ programID: String)
}
