//
//  PlayerView.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/5/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import SnapKit

class PlayerView: UIView {
    
    private var coverView = UIImageView()
    private var titleLabel = UILabel()
    private var subTitleLabel = UILabel()
    private var playButton = UIButton()
    
    var playerViewTopConstraint: Constraint?
    
    //MARK: instance
    class var instance: PlayerView {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlayerView! = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = PlayerView()
        }
        return Static.instance
    }
    
    init() {
        super.init(frame: CGRectMake(0, Device.width()-playerBarHeight, Device.width(), playerBarHeight))
        
        insertGradientLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare() {
        backgroundColor = UIColor.grayColor()
        
        let window = Device.keyWindow()
        window.addSubview(self)
        self.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(Device.width(), Device.height()))
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            playerViewTopConstraint = make.topMargin.equalTo(Device.height()-playerBarHeight).constraint
        }
        
        let contentView = UIView()
        addSubview(contentView)
        contentView.snp_makeConstraints { (make) in
            make.height.equalTo(playerBarHeight)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            make.topMargin.equalTo(0)
        }
        
        // init coverImageView
        contentView.addSubview(coverView)
        coverView.image = UIImage(named: "placeholder_cover")
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 20
        coverView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.leftMargin.equalTo(10)
            make.centerY.equalTo(contentView.snp_centerY)
        }
        
        contentView.addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play"), forState: .Normal)
        playButton.setImage(UIImage(named: "player_pause"), forState: .Selected)
        playButton.addTarget(self, action: #selector(PlayerView.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.rightMargin.equalTo(-10)
            make.centerY.equalTo(contentView.snp_centerY)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.text = "灵魂中的歌声"
        titleLabel.font = UIFont.sizeOf12()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverView.snp_right).inset(-10)
            make.right.equalTo(playButton.snp_left).inset(-10)
            make.bottom.equalTo(contentView.snp_centerY)
        }
        
        contentView.addSubview(subTitleLabel)
        subTitleLabel.text = "活动电台 - 睡眠"
        subTitleLabel.font = UIFont.sizeOf10()
        subTitleLabel.textColor = UIColor.grayColor7()
        subTitleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverView.snp_right).inset(-10)
            make.right.equalTo(playButton.snp_left).inset(-10)
            make.top.equalTo(contentView.snp_centerY)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlayerView.handleTap(_:)))
        addGestureRecognizer(tap)
        
        NotificationManager.instance.addPlayMusicProgressChangedObserver(self, action: #selector(PlayerView.playMusicProgressChanged(_:)))
        NotificationManager.instance.addPlayMusicProgressEndedObserver(self, action: #selector(PlayerView.playMusicProgressEnded(_:)))
        NotificationManager.instance.addPlayMusicProgressPausedObserver(self, action: #selector(PlayerView.playMusicProgressPaused(_:)))
        NotificationManager.instance.addUpdatePlayerControllerObserver(self, action: #selector(PlayerView.updatePlayerBar))
    }
    
    
    func insertGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(netHex:0x52554A, alpha: 0.8).CGColor,UIColor(netHex: 0x414643, alpha: 1).CGColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0.5)
        gradientLayer.endPoint = CGPointMake(1, 0.5)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    //MARK: events
    func playButtonPressed(button: UIButton) {
        if MusicManager.sharedManager.isPlaying() {
            MusicManager.sharedManager.pauseItem()
            NotificationManager.instance.postPlayMusicProgressPausedNotification()
            button.selected = false
        }else {
            MusicManager.sharedManager.playItem()
            button.selected = true
        }
    }
    
    func handleTap(gesture: UIGestureRecognizer) {
        print("press player bar")
        
        hide()
        Device.keyWindow().topMostController()?.presentViewController(playerControler, animated: true, completion: nil)
    }
    
    func playMusicProgressChanged(noti: NSNotification) {
        if let _ = noti.userInfo {
            playButton.selected = true
        }
    }
    
    func playMusicProgressEnded(noti: NSNotification) {
        playButton.selected = false
    }
    
    func playMusicProgressPaused(noti: NSNotification) {
        playButton.selected = false
    }
    
    func updatePlayerBar() {
        if let song = MusicManager.sharedManager.currentSong() {
            titleLabel.text = song.songName
            subTitleLabel.text = song.artistsName
            coverView.kf_setImageWithURL(NSURL(string: song.picURL!)!)
        }
    }
    
    func show() {
        UIView.animateWithDuration(0.5, animations: {[weak self] Void in self?.alpha = 1 })
    }
    
    func hide() {
        UIView.animateWithDuration(0.5, animations: {[weak self] Void in self?.alpha = 0 })
    }
    
}

