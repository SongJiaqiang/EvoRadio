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
    
    fileprivate var coverView: UIImageView!
    fileprivate var backgroundView: UIImageView!
    fileprivate var titleLabel = UILabel()
    fileprivate var subTitleLabel = UILabel()
    fileprivate var playButton = UIButton()
    fileprivate var nextButton = UIButton()
    
    var playerViewTopConstraint: Constraint?
    var progressViewWidthConstraint: Constraint!
    
    var progressTimer: Timer!
    
    //MARK: instance
    public static let main = PlayerView()
    
    init() {
        super.init(frame: CGRect(x: 0, y: Device.width()-playerBarHeight, width: Device.width(), height: playerBarHeight))
        
        insertGradientLayer()
        prepareUI()
        
        progressTimer = Timer(timeInterval: 1, target: self, selector: #selector(PlayerView.progressHandle), userInfo: nil, repeats: true)
        RunLoop.current.add(progressTimer, forMode: .common)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        backgroundColor = UIColor.gray
        
        let window = Device.keyWindow()
        window.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.height.equalTo(playerBarHeight)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            make.bottomMargin.equalTo(IS_IPHONE_X ? -28 : 0)            
        }
        
        backgroundView = UIImageView()
        addSubview(backgroundView)
        backgroundView.contentMode = .scaleToFill
        backgroundView.transform = CGAffineTransform(scaleX: -1, y: 1)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
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
        coverView = UIImageView()
        contentView.addSubview(coverView)
        coverView.image = UIImage(named: "cd_cover")
        coverView.clipsToBounds = true
        coverView.contentMode = .scaleAspectFill
        coverView.snp.makeConstraints { (make) in
            make.width.equalTo(playerBarHeight-2)
            make.height.equalTo(playerBarHeight-2)
            make.left.equalTo(contentView.snp.left);
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        contentView.addSubview(nextButton)
        nextButton.setImage(UIImage(named: "player_next"), for: .normal)
        nextButton.setImage(UIImage(named: "player_next_pressed"), for: .highlighted)
        nextButton.addTarget(self, action: #selector(PlayerView.nextButtonPressed(_:)), for: .touchUpInside)
        nextButton.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        contentView.addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play"), for: .normal)
        playButton.setImage(UIImage(named: "player_play_pressed"), for: .highlighted)
        playButton.addTarget(self, action: #selector(PlayerView.playButtonPressed(_:)), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.right.equalTo(nextButton.snp.left).offset(-10)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.text = "还没有播放音乐"
        titleLabel.font = UIFont.size16()
        titleLabel.textColor = UIColor.white
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverView.snp.right).inset(-10)
            make.right.equalTo(playButton.snp.left).inset(-10)
            make.bottom.equalTo(contentView.snp.centerY).offset(-2)
        }
        
        contentView.addSubview(subTitleLabel)
        subTitleLabel.text = "Oops~"
        subTitleLabel.font = UIFont.size12()
        subTitleLabel.textColor = UIColor.grayColorBF()
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverView.snp.right).inset(-10)
            make.right.equalTo(playButton.snp.left).inset(-10)
            make.top.equalTo(contentView.snp.centerY).offset(2)
        }
        
        
        let progressView0 = UIView()
        contentView.addSubview(progressView0)
        progressView0.backgroundColor = UIColor.white
        progressView0.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            make.topMargin.equalTo(0)
        }
        
        let progressView1 = UIView()
        contentView.addSubview(progressView1)
        progressView1.backgroundColor = UIColor.goldColor()
        progressView1.snp.makeConstraints { (make) in
            progressViewWidthConstraint = make.width.equalTo(0).constraint
            make.height.equalTo(2)
            make.leftMargin.equalTo(0)
            make.topMargin.equalTo(0)
        }
        
        // add blur effect
        let blur = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blur)
        backgroundView.addSubview(effectView)
        effectView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPress)
        
        NotificationManager.shared.addPlayMusicProgressStartedObserver(self, action: #selector(playMusicProgressStarted(_:)))
        NotificationManager.shared.addPlayMusicProgressPausedObserver(self, action: #selector(playMusicProgressPaused(_:)))
        NotificationManager.shared.addUpdatePlayerObserver(self, action: #selector(updatePlayer))
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
    @objc func playButtonPressed(_ button: UIButton) {
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
    
    @objc func nextButtonPressed(_ button: UIButton) {
        MusicManager.shared.playNext()
    }
    
    
    @objc func handleTap(_ gesture: UIGestureRecognizer) {
        debugPrint("press player bar")
        
        if let _ = MusicManager.shared.currentSong() {
            hide()
            Device.keyWindow().topMostController()?.present(PlayerViewController.mainController, animated: true, completion: nil)
        }else {
            HudManager.showText("还没有播放音乐")
        }
    }
    
    @objc func handleLongPress(_ gesture: UIGestureRecognizer) {
        let touchPoint = gesture.location(in: self)
        
        let progess = touchPoint.x / Device.width()
        
        let progressViewWidth = progess * Device.width()
        
        progressViewWidthConstraint.update(offset: progressViewWidth)
        updateConstraintsIfNeeded()
        
        if gesture.state == .ended {
            // seek to selected second
            let duration:Float = Float(MusicManager.shared.audioPlayer.duration)
            let timePlayed = progess * CGFloat(duration)
            
            MusicManager.shared.playAtSecond(Int(timePlayed))
        }
        
    }
    
    
    @objc func playMusicProgressStarted(_ noti: Notification) {
        playButton.setImage(UIImage(named: "player_paused"), for: .normal)
        playButton.setImage(UIImage(named: "player_paused_pressed"), for: .highlighted)
    }
    
    @objc func playMusicProgressPaused(_ noti: Notification) {
        
        playButton.setImage(UIImage(named: "player_play"), for: .normal)
        playButton.setImage(UIImage(named: "player_play_pressed"), for: .highlighted)
    }
    
    @objc func updatePlayer() {
        if let song = MusicManager.shared.currentSong() {
            titleLabel.text = song.songName
            subTitleLabel.text = song.artistsName
            
            if let picURLString = song.picURL {
                if let picURL = URL(string: picURLString) {
                    coverView.kf.setImage(with: picURL, placeholder: UIImage.placeholder_cover(), completionHandler: {[weak self] (image, error, cacheType, imageURL) in
                        if let _ = image{
                            UIView.animate(withDuration: 0.5, animations: {
                                self?.backgroundView.alpha = 0.2
                            }, completion: { (complete) in
                                self?.backgroundView.image = image!
                                UIView.animate(withDuration: 1, animations: {
                                    self?.backgroundView.alpha = 1
                                })
                            })
                        }
                    })
                }
            }
        }
    }
    
    @objc func progressHandle() {
        let duration:Float = Float(MusicManager.shared.audioPlayer.duration)
        let timePlayed: Float = Float(MusicManager.shared.audioPlayer.progress)
        
        if duration == 0 {
            return
        }
        
        let progess = timePlayed / duration
        let progressViewWidth = CGFloat(progess) * Device.width()
        
        progressViewWidthConstraint.update(offset: progressViewWidth)
        updateConstraintsIfNeeded()
        
        MusicManager.shared.updatePlaybackTime(Double(timePlayed))
    }
    
    func show() {
        self.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { (result) in
            self.isHidden = true
        }
    }
    
}

