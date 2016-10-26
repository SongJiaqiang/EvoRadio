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
    
    fileprivate var coverView = UIImageView()
    fileprivate var titleLabel = UILabel()
    fileprivate var subTitleLabel = UILabel()
    fileprivate var playButton = UIButton()
    
    var playerViewTopConstraint: Constraint?
    
    //MARK: instance
    open static let main = PlayerView()
    
    init() {
        super.init(frame: CGRect(x: 0, y: Device.width()-playerBarHeight, width: Device.width(), height: playerBarHeight))
        
        insertGradientLayer()
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare() {
        backgroundColor = UIColor.gray
        
        let window = Device.keyWindow()
        window.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: Device.width(), height: Device.height()))
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            playerViewTopConstraint = make.topMargin.equalTo(Device.height()-playerBarHeight).constraint
        }
        
        let contentView = UIView()
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
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
        coverView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.leftMargin.equalTo(10)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        contentView.addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play"), for: UIControlState())
        playButton.setImage(UIImage(named: "player_play_pressed"), for: .highlighted)
        playButton.addTarget(self, action: #selector(PlayerView.playButtonPressed(_:)), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.rightMargin.equalTo(-10)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.text = "还没有播放音乐"
        titleLabel.font = UIFont.sizeOf12()
        titleLabel.textColor = UIColor.white
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverView.snp.right).inset(-10)
            make.right.equalTo(playButton.snp.left).inset(-10)
            make.bottom.equalTo(contentView.snp.centerY)
        }
        
        contentView.addSubview(subTitleLabel)
        subTitleLabel.text = "Oops~"
        subTitleLabel.font = UIFont.sizeOf10()
        subTitleLabel.textColor = UIColor.grayColor7()
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverView.snp.right).inset(-10)
            make.right.equalTo(playButton.snp.left).inset(-10)
            make.top.equalTo(contentView.snp.centerY)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlayerView.handleTap(_:)))
        addGestureRecognizer(tap)
        
        NotificationManager.shared.addPlayMusicProgressStartedObserver(self, action: #selector(PlayerView.playMusicProgressStarted(_:)))
        NotificationManager.shared.addPlayMusicProgressPausedObserver(self, action: #selector(PlayerView.playMusicProgressPaused(_:)))
        NotificationManager.shared.addUpdatePlayerControllerObserver(self, action: #selector(PlayerView.updatePlayerBar))
    }
    
    
    func insertGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(netHex:0x52554A, alpha: 0.8).cgColor,UIColor(netHex: 0x414643, alpha: 1).cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //MARK: events
    func playButtonPressed(_ button: UIButton) {
        guard let _ = MusicManager.shared.currentSong() else{
            return
        }
        
        if MusicManager.shared.isPlaying() {
            MusicManager.shared.pause()
            NotificationManager.shared.postPlayMusicProgressPausedNotification()
        }else {
            MusicManager.shared.resume()
        }
    }
    
    func handleTap(_ gesture: UIGestureRecognizer) {
        debugPrint("press player bar")
        
        if let _ = MusicManager.shared.currentSong() {
            hide()
            Device.keyWindow().topMostController()?.present(PlayerViewController.mainController, animated: true, completion: nil)
        }else {
            HudManager.showText("还没有播放音乐")
        }
    }
    
    
    func playMusicProgressStarted(_ noti: Notification) {
        playButton.setImage(UIImage(named: "player_paused"), for: UIControlState())
        playButton.setImage(UIImage(named: "player_paused_pressed"), for: .highlighted)
    }
    
    func playMusicProgressPaused(_ noti: Notification) {
        
        playButton.setImage(UIImage(named: "player_play"), for: UIControlState())
        playButton.setImage(UIImage(named: "player_play_pressed"), for: .highlighted)
    }
    
    func updatePlayerBar() {
        if let song = MusicManager.shared.currentSong() {
            titleLabel.text = song.songName
            subTitleLabel.text = song.artistsName
            coverView.kf.setImage(with: URL(string: song.picURL!)!, placeholder: UIImage.placeholder_cover())
        }
    }
    
    func show() {
        self.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {[weak self] Void in self?.alpha = 1 })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.5, animations: {[weak self] Void in
            self?.alpha = 0
            
            }, completion: {[weak self] Void in
            self?.isHidden = true
        })
    }
    
}

