//
//  PlayerView.swift
//  EvoRadio
//
//  Created by Jarvis on 16/5/18.
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
        prepare()
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
        coverView.image = UIImage(named: "cd_cover")
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = 20
        coverView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.leftMargin.equalTo(10)
            make.centerY.equalTo(contentView.snp_centerY)
        }
        
        contentView.addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play"), forState: .Normal)
        playButton.setImage(UIImage(named: "player_play_pressed"), forState: .Highlighted)
        playButton.addTarget(self, action: #selector(PlayerView.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.rightMargin.equalTo(-10)
            make.centerY.equalTo(contentView.snp_centerY)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.text = "还没有播放音乐"
        titleLabel.font = UIFont.sizeOf12()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverView.snp_right).inset(-10)
            make.right.equalTo(playButton.snp_left).inset(-10)
            make.bottom.equalTo(contentView.snp_centerY)
        }
        
        contentView.addSubview(subTitleLabel)
        subTitleLabel.text = "Oops~"
        subTitleLabel.font = UIFont.sizeOf10()
        subTitleLabel.textColor = UIColor.grayColor7()
        subTitleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverView.snp_right).inset(-10)
            make.right.equalTo(playButton.snp_left).inset(-10)
            make.top.equalTo(contentView.snp_centerY)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlayerView.handleTap(_:)))
        addGestureRecognizer(tap)
        
        NotificationManager.instance.addPlayMusicProgressStartedObserver(self, action: #selector(PlayerView.playMusicProgressStarted(_:)))
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
        guard let _ = MusicManager.sharedManager.currentSong() else{
            return
        }
        
        if MusicManager.sharedManager.isPlaying() {
            MusicManager.sharedManager.pause()
            NotificationManager.instance.postPlayMusicProgressPausedNotification()
        }else {
            MusicManager.sharedManager.resume()
        }
    }
    
    func handleTap(gesture: UIGestureRecognizer) {
        debugPrint("press player bar")
        
        if let _ = MusicManager.sharedManager.currentSong() {
            hide()
            Device.keyWindow().topMostController()?.presentViewController(PlayerViewController.playerController, animated: true, completion: nil)
        }else {
            HudManager.showText("还没有播放音乐")
        }
    }
    
    
    func playMusicProgressStarted(noti: NSNotification) {
        playButton.setImage(UIImage(named: "player_paused"), forState: .Normal)
        playButton.setImage(UIImage(named: "player_paused_pressed"), forState: .Highlighted)
    }
    
    func playMusicProgressPaused(noti: NSNotification) {
        
        playButton.setImage(UIImage(named: "player_play"), forState: .Normal)
        playButton.setImage(UIImage(named: "player_play_pressed"), forState: .Highlighted)
    }
    
    func updatePlayerBar() {
        if let song = MusicManager.sharedManager.currentSong() {
            titleLabel.text = song.songName
            subTitleLabel.text = song.artistsName
            coverView.kf_setImageWithURL(NSURL(string: song.picURL!)!, placeholderImage: UIImage.placeholder_cover())
        }
    }
    
    func show() {
        self.hidden = false
        UIView.animateWithDuration(0.5, animations: {[weak self] Void in self?.alpha = 1 })
    }
    
    func hide() {
        UIView.animateWithDuration(0.5, animations: {[weak self] Void in
            self?.alpha = 0
            
            }, completion: {[weak self] Void in
            self?.hidden = true
        })
    }
    
}

