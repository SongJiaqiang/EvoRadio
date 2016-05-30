//
//  PlayerBar.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/17.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class PlayerBar: UIView {
    private var coverView = UIImageView()
    private var titleLabel = UILabel()
    private var subTitleLabel = UILabel()
    private var playButton = UIButton()
    
    var delegate: PlayerBarDelegate?
    
    init() {
        super.init(frame: CGRectMake(0, Device.width()-50, Device.width(), 50))
        
        insertGradientLayer()
        prepareUI()
        
        NotificationManager.instance.addPlayMusicProgressChangedObserver(self, action: #selector(PlayerBar.playMusicProgressChanged(_:)))
        NotificationManager.instance.addPlayMusicProgressEndedObserver(self, action: #selector(PlayerBar.playMusicProgressEnded(_:)))
    }
    
    deinit {
        NotificationManager.instance.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertGradientLayer() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(netHex:0x52554A, alpha: 0.75).CGColor,UIColor(netHex: 0x414643, alpha: 1).CGColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0.5)
        gradientLayer.endPoint = CGPointMake(1, 0.5)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func prepareUI() {
        addSubview(coverView)
        coverView.image = UIImage(named: "placeholder_cover")
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 20
        coverView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.leftMargin.equalTo(10)
            make.centerY.equalTo(snp_centerY)
        }
        
        addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play_border"), forState: .Normal)
        playButton.setImage(UIImage(named: "player_play_border_prs"), forState: .Highlighted)
        playButton.addTarget(self, action: #selector(PlayerBar.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.rightMargin.equalTo(-10)
            make.centerY.equalTo(snp_centerY)
        }
        
        addSubview(titleLabel)
        titleLabel.text = "灵魂中的歌声"
        titleLabel.font = UIFont.sizeOf12()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverView.snp_right).inset(-10)
            make.right.equalTo(playButton.snp_left).inset(10)
            make.bottom.equalTo(snp_centerY)
        }
        
        addSubview(subTitleLabel)
        subTitleLabel.text = "活动电台 - 睡眠"
        subTitleLabel.font = UIFont.sizeOf10()
        subTitleLabel.textColor = UIColor.grayColor7()
        subTitleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverView.snp_right).inset(-10)
            make.right.equalTo(playButton.snp_left).inset(10)
            make.top.equalTo(snp_centerY)
        }
        
        let tap = UIGestureRecognizer(target: self, action: #selector(PlayerBar.onTap(_:)))
        addGestureRecognizer(tap)
        userInteractionEnabled = true
    }
    
    //MARK: event
    func onTap(gesture: UITapGestureRecognizer) {
        delegate?.playerBarPressed()
    }
    
    func playButtonPressed(button: UIButton) {
        
        if MusicManager.sharedManager.isPlaying() {
            MusicManager.sharedManager.pauseItem()
            button.selected = false
        }else {
            MusicManager.sharedManager.playItem()
            button.selected = true
        }
        
    }
    
    
    func playMusicProgressChanged(noti: NSNotification) {
        if let _ = noti.userInfo {
            playButton.selected = true
        }
        
        
    }
    
    func playMusicProgressEnded(noti: NSNotification) {
        playButton.selected = false
    }
}

enum SlideDirection {
    case Horizontal
    case Vertical
}

protocol PlayerBarDelegate {
    
    func playerBarPressed()
    func playerBarPressedOnStart()
    func playerBarPressedOnCover()
    func playerBarSlided(direction: SlideDirection, offset: CGPoint)
    
}
