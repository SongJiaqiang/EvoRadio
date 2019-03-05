//
//  PlayerViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import StreamingKit

class PlayerViewController: ViewController {
    
    let cellID = "playerControllerPlaylistCellID"
    let toolButtonWidth: CGFloat = 50
    
    fileprivate var coverImageView = CDCoverImageView(frame: CGRect.zero)
    var backgroundView: UIImageView!
    
    fileprivate var controlView = UIView()
    let progressSlider = UISlider()
    let currentTimeLabel = UILabel()
    let totalTimeLabel = UILabel()
    let playButton = UIButton()
    let nextButton = UIButton()
    let prevButton = UIButton()
    let loopButton = UIButton()
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    let playlistTableView = UITableView(frame: CGRect.zero, style: .grouped)
    let playlistContentView = UIView()
    var playlistTableViewBottomConstraint: Constraint?
    
    var progressTimer: Timer?
    var autoStopTimer: Timer?
    var leftTime: TimeInterval = 3600
    var isTimeDown: Bool = false
    
    var coverRotateAnimation: CABasicAnimation?;
    
    //MARK: instance
    static let mainController = PlayerViewController()
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: life cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("player viewDidLoad")
        
        MusicManager.shared.audioPlayer.delegate = self
        progressTimer = Timer(timeInterval: 1, target: self, selector: #selector(progressHandle), userInfo: nil, repeats: true)
        RunLoop.current.add(progressTimer!, forMode: .common)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PlayerView.main.hide()
        
        if MusicManager.shared.isPlaying() {
            coverImageView.layer.removeAllAnimations()
            coverRotateAnimation = nil
            prepareAnimation()
        } else if MusicManager.shared.isPaused() {
            coverRotateAnimation = nil
        }
        
        AssistiveTouch.shared.hide()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PlayerView.main.show()
        
        AssistiveTouch.shared.show()
    }

    //MARK: prepare ui
    func prepare() {
        
        prepareBackgroundView()
        preparePlayerControlView()
        prepareToolsView()
        prepareNavigationBar()
        prepareTableView()

        NotificationManager.shared.addUpdatePlayerObserver(self, action: #selector(updatePlayer(_:)))
        
    }
    
    func prepareBackgroundView() {
        view.addSubview(coverImageView)
        coverImageView.image = UIImage.placeholder_cover()
        coverImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 240, height: 240))
            make.centerX.equalTo(view.snp.centerX)
            let topMargin = (Device.height()-200-64)*0.5-100+64
            make.topMargin.equalTo(topMargin)
        }
        
        backgroundView = UIImageView()
        view.insertSubview(backgroundView, belowSubview: coverImageView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        let blackMaskView = UIImageView()
        blackMaskView.backgroundColor = UIColor.black.alpha(0.3)
        view.insertSubview(blackMaskView, aboveSubview: backgroundView)
        blackMaskView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        // add blur effect
        let blur = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blur)
        backgroundView.addSubview(effectView)
        effectView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
    }
    
    func prepareCoverView() {
        
        let coverWidth: CGFloat = 200
        let coverView = UIImageView()
        view.addSubview(coverView)
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = coverWidth*0.5
        
        coverView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: coverWidth, height: coverWidth))
            make.center.equalTo(view.snp.center)
        }
    }
    
    func prepareNavigationBar() {
        let navBarHeight: CGFloat = IS_IPHONE_X ? 88 : 64
        
        let navBar = UIView()
        view.addSubview(navBar)
        navBar.snp.makeConstraints { (make) in
            make.height.equalTo(navBarHeight)
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        navBar.addSubview(subTitleLabel)
        subTitleLabel.textAlignment = .center
        subTitleLabel.font = UIFont.size12()
        subTitleLabel.textColor = UIColor.grayColorBF()
        subTitleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.leftMargin.equalTo(60)
            make.rightMargin.equalTo(-60)
            make.bottom.equalTo(navBar.snp.bottom)
        }
        
        navBar.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.size14()
        titleLabel.textColor = UIColor.white
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.leftMargin.equalTo(60)
            make.rightMargin.equalTo(-60)
            make.bottom.equalTo(subTitleLabel.snp.top)
        }
        
        let closeButton = UIButton()
        navBar.addSubview(closeButton)
        closeButton.setImage(UIImage(named: "nav_dismiss"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        closeButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.leftMargin.equalTo(10)
            make.bottomMargin.equalTo(-2)
        }
        
        let menuButton = UIButton()
        navBar.addSubview(menuButton)
        menuButton.setImage(UIImage(named: "topbar_menu"), for: UIControl.State())
        menuButton.addTarget(self, action: #selector(menuButtonPressed), for: .touchUpInside)
        menuButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.rightMargin.equalTo(-10)
            make.bottomMargin.equalTo(-2)
        }
  
    }

    func prepareToolsView() {
        let itemWidth: CGFloat = min(Device.width() / 5, 60)
        
        let toolsView = UIView()
        view.addSubview(toolsView)
//        toolsView.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
        toolsView.snp.makeConstraints { (make) in
            make.height.equalTo(itemWidth)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        let downloadButton = UIButton()
        toolsView.addSubview(downloadButton)
        downloadButton.setImage(UIImage(named: "player_download"), for: .normal)
        downloadButton.setImage(UIImage(named: "player_download_selected"), for: .selected)
        downloadButton.addTarget(self, action: #selector(downloadButtonPressed(_:)), for: .touchUpInside)
        downloadButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: itemWidth, height: itemWidth))
            make.centerY.equalTo(toolsView.snp.centerY)
            make.right.equalTo(toolsView.snp.centerX)
        }
        
        let loveButton = UIButton()
        toolsView.addSubview(loveButton)
        loveButton.setImage(UIImage(named: "collect_music"), for: .normal)
        loveButton.addTarget(self, action: #selector(loveButtonPressed(_:)), for: .touchUpInside)
        loveButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: itemWidth, height: itemWidth))
            make.centerY.equalTo(toolsView.snp.centerY)
            make.left.equalTo(toolsView.snp.centerX)
        }
        
        toolsView.addSubview(loopButton)
        loopButton.setImage(UIImage(named: "player_cycle_list"), for: .normal)
        loopButton.addTarget(self, action: #selector(loopButtonPressed(_:)), for: .touchUpInside)
        loopButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: itemWidth, height: itemWidth))
            make.centerY.equalTo(toolsView.snp.centerY)
            make.right.equalTo(downloadButton.snp.left)
        }
        
        let listButton = UIButton()
        toolsView.addSubview(listButton)
        listButton.setImage(UIImage(named: "player_list"), for: .normal)
        listButton.addTarget(self, action: #selector(listButtonPressed(_:)), for: .touchUpInside)
        listButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: itemWidth, height: itemWidth))
            make.centerY.equalTo(toolsView.snp.centerY)
            make.left.equalTo(loveButton.snp.right)
        }

        loadDefaultData()
        
    }
    
    func preparePlayerControlView() {
        view.addSubview(controlView)
        controlView.snp.makeConstraints { (make) in
            make.height.equalTo(180)
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        controlView.addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play"), for: .normal)
        playButton.setImage(UIImage(named: "player_play_pressed"), for: .highlighted)
        playButton.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.center.equalTo(controlView.snp.center)
        }
        
        controlView.addSubview(nextButton)
        nextButton.setImage(UIImage(named: "player_next"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonPressed(_:)), for: .touchUpInside)
        nextButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: toolButtonWidth, height: toolButtonWidth))
            make.centerY.equalTo(controlView.snp.centerY)
            make.left.equalTo(playButton.snp.right).inset(-20)
        }
        
        
        controlView.addSubview(prevButton)
        prevButton.setImage(UIImage(named: "player_prev"), for: .normal)
        prevButton.addTarget(self, action: #selector(prevButtonPressed(_:)), for: .touchUpInside)
        prevButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: toolButtonWidth, height: toolButtonWidth))
            make.centerY.equalTo(controlView.snp.centerY)
            make.right.equalTo(playButton.snp.left).inset(-20)
        }
        
        controlView.addSubview(progressSlider)
        progressSlider.setThumbImage(UIImage(named: "dot_white")!, for: .normal)
        progressSlider.tintColor = UIColor.goldColor()
        progressSlider.addTarget(self, action: #selector(progressSliderChanged(_:)), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(progressSliderTouchEnd(_:)), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(progressSliderTouchEnd(_:)), for: .touchUpOutside)
        progressSlider.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalTo(controlView.snp.left).inset(50)
            make.right.equalTo(controlView.snp.right).inset(50)
            make.top.equalTo(controlView.snp.top).offset(10)
        }
        
        controlView.addSubview(currentTimeLabel)
        currentTimeLabel.textAlignment = .center
        currentTimeLabel.font = UIFont.size10()
        currentTimeLabel.textColor = UIColor.white
        currentTimeLabel.text = "0:00"
        currentTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(progressSlider.snp.left)
            make.centerY.equalTo(progressSlider.snp.centerY)
        }
        
        controlView.addSubview(totalTimeLabel)
        totalTimeLabel.textAlignment = .center
        totalTimeLabel.font = UIFont.size10()
        totalTimeLabel.textColor = UIColor.white
        totalTimeLabel.text = "0:00"
        totalTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right)
            make.left.equalTo(progressSlider.snp.right)
            make.centerY.equalTo(progressSlider.snp.centerY)
        }
        
    }
    
    func prepareTableView() {

        view.addSubview(playlistContentView)
        playlistContentView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        playlistContentView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        let emptyButton = UIButton()
        playlistContentView.addSubview(emptyButton)
        emptyButton.addTarget(self, action: #selector(emptyButtonPressed(_:)), for: .touchUpInside)
        emptyButton.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        }
        
        playlistContentView.addSubview(playlistTableView)
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
        playlistTableView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        playlistTableView.separatorStyle = .none
        playlistTableView.snp.makeConstraints({(make) in
            make.height.equalTo(Device.height()*0.6)
            make.left.equalTo(playlistContentView.snp.left)
            make.right.equalTo(playlistContentView.snp.right)
            playlistTableViewBottomConstraint = make.top.equalTo(playlistContentView.snp.bottom).offset(0).constraint
        })
        
        playlistTableView.register(SongListTableViewCell.self, forCellReuseIdentifier: cellID)
        
        playlistContentView.isHidden = true
    }
    
    func prepareAnimation() {
        if coverRotateAnimation == nil {
            coverRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            coverRotateAnimation!.duration = 30
            coverRotateAnimation!.fromValue = NSNumber(value: 0 as Double)
            coverRotateAnimation!.toValue = NSNumber(value: M_PI * 2 as Double)
            coverRotateAnimation!.repeatCount = MAXFLOAT
            coverRotateAnimation!.autoreverses = false
            coverRotateAnimation!.isCumulative = true
            coverImageView.layer.speed = 1
            coverImageView.layer.add(coverRotateAnimation!, forKey: "coverRotateAnimation")
        }
    }
    
    //MARK: events
    @objc func playButtonPressed(_ button: UIButton) {
        
        if MusicManager.shared.isStoped() {
            return
        }
        
        if MusicManager.shared.isPaused() {
            MusicManager.shared.resume()
            
            let stopTime = coverImageView.layer.timeOffset
            coverImageView.layer.beginTime = 0
            coverImageView.layer.timeOffset = 0
            coverImageView.layer.speed = 1
            let tempTime = coverImageView.layer.convertTime(CACurrentMediaTime(), from: nil) - stopTime
            coverImageView.layer.beginTime = tempTime
            
            
        } else if MusicManager.shared.isPlaying() {
            MusicManager.shared.pause()
            NotificationManager.shared.postPlayMusicProgressPausedNotification()
            
            let stopTime = coverImageView.layer.convertTime(CACurrentMediaTime(), from: nil)
            coverImageView.layer.speed = 0
            coverImageView.layer.timeOffset = stopTime
        }else {
            debugPrint("鬼知道发生了什么！")
        }
        
    }
    @objc func nextButtonPressed(_ button: UIButton) {
        MusicManager.shared.playNext()
        
        coverImageView.layer.removeAllAnimations()
        coverRotateAnimation = nil
    }
    
    @objc func prevButtonPressed(_ button: UIButton) {
        MusicManager.shared.playPrev()
        
        coverImageView.layer.removeAllAnimations()
        coverRotateAnimation = nil
    }

    @objc func loveButtonPressed(_ button: UIButton) {
        guard let cSong = MusicManager.shared.currentSong() else {
            print("Current music is empty")
            return
        }
        
        CoreDB.addMusicToCollectList(cSong)
        HudManager.showText("收藏成功", inView: self.view)
    }

    @objc func loopButtonPressed(_ button: UIButton) {
        var imageAssetName: String
        var showText: String
        let newMode = MusicManager.shared.changePlayMode()
        switch newMode {
        case .ListLoop:
            imageAssetName = "player_cycle_list"
            showText = "列表循环"
        case .SingleLoop:
            imageAssetName = "player_cycle_single"
            showText = "单曲循环"
        case .Random:
            imageAssetName = "player_cycle_random"
            showText = "随机播放"
        }
        
        loopButton.setImage(UIImage(named: imageAssetName), for: .normal)
        HudManager.showText(showText, inView: view)
    }
    
    @objc func listButtonPressed(_ button: UIButton) {
        showPlaylistTableView(true)
    }
    
    @objc func heartButtonPressed(_ button: UIButton) {
        button.isSelected = !button.isSelected
    }
    
    @objc func downloadButtonPressed(_ button: UIButton) {
        if let cSong = MusicManager.shared.currentSong() {
            CoreDB.addSongToDownloadingList(cSong)
            button.isSelected = true
            DispatchQueue.main.async {
                HudManager.showText("已经加入下载列表")
            }
        }
    }

    @objc func shareButtonPressed() {
        if let currentSong = MusicManager.shared.currentSong() {
            let link = URL(string: currentSong.audioURL!)
            let message = String(format: "EvoRadio请您欣赏：%@", currentSong.songName)
            
            let shareItems: [Any] = [message, link as Any]
            let activityController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    func infoButtonPressed(_ button: UIButton) {
        debugPrint("infoButtonPressed")
    }
    
    @objc func closeButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func menuButtonPressed() {
        let alertController = UIAlertController(title: "更多功能", message: nil, preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "分享音乐", style: .default) { (action) in
            self.shareButtonPressed()
        }
        let timerAction = UIAlertAction(title: "定时停止", style: .default) { (action) in
            self.timerButtonPressed()
        }
        let cancelAction = UIAlertAction(title: "关闭", style: .cancel, handler: nil)
        alertController.addAction(shareAction)
        alertController.addAction(timerAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func timerButtonPressed() {
        if isTimeDown {
            isTimeDown = false
            if let _ = autoStopTimer {
                autoStopTimer?.invalidate()
                autoStopTimer = nil
            }
            
        }else {
            let alertController = UIAlertController(title: "设置自动停止播放时间", message: nil, preferredStyle: .actionSheet)
            let action1 = UIAlertAction(title: "10 minutes", style: .default, handler: { (action) in
                self.isTimeDown = true
                self.leftTime = 600
                if self.autoStopTimer == nil {
                    self.autoStopTimer = Timer(timeInterval: 5, target: self, selector: #selector(self.autoStopHandle), userInfo: nil, repeats: true)
                    RunLoop.main.add(self.autoStopTimer!, forMode: .common)
                }
                
            })
            let action2 = UIAlertAction(title: "15 minutes", style: .default, handler: { (action) in
                self.isTimeDown = true
                self.leftTime = 900
            })
            let action3 = UIAlertAction(title: "30 minutes", style: .default, handler: { (action) in
                self.isTimeDown = true
                self.leftTime = 1800
            })
            let action4 = UIAlertAction(title: "1 hour", style: .default, handler: { (action) in
                self.isTimeDown = true
                self.leftTime = 3600
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(action3)
            alertController.addAction(action4)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @objc func progressSliderChanged(_ slider: UISlider) {
        print(">> selected value: \(slider.value)")
//        let timePlayed = slider.value
//        MusicManager.shared.playAtSecond(Int(timePlayed))
    }
    
    @objc func progressSliderTouchEnd(_ slider: UISlider) {
        let timePlayed = slider.value
        MusicManager.shared.playAtSecond(Int(timePlayed))
    }
    
    @objc func updatePlayer(_ noti: Notification) {
        if let song = MusicManager.shared.currentSong() {
            updateCoverImage(song)
        }
    }
    
    @objc func autoStopHandle() {
        debugPrint("Timer: \(leftTime)")
        leftTime -= 5
        if leftTime <= 0 {
            debugPrint("Time out, will stop music")
            
            autoStopTimer?.invalidate()
            autoStopTimer = nil
            
            MusicManager.shared.pause()
//            timerButton.isSelected = false
        }
    }
    
    @objc func progressHandle() {
        let duration:Float = Float(MusicManager.shared.audioPlayer.duration)
        let timePlayed: Float = Float(MusicManager.shared.audioPlayer.progress)
        
        progressSlider.maximumValue = duration
        progressSlider.value = timePlayed
        
        totalTimeLabel.text = Date.secondsToMinuteString(Int(duration))
        currentTimeLabel.text = Date.secondsToMinuteString(Int(timePlayed))
        
        MusicManager.shared.updatePlaybackTime(Double(timePlayed))
    }
    
    
    //MARK: other
    
    func updateCoverImage(_ song: Song) {
        debugPrint("update cover image")
        titleLabel.text = song.songName
        if let album = song.salbumsName {
            subTitleLabel.text = song.artistsName?.appending(" - ").appending(album)
        }
        
        if let picURLString = song.picURL {
            if let picURL = URL(string: picURLString) {
                coverImageView.kf.setImage(with: picURL, placeholder: UIImage.placeholder_cover(), completionHandler: {[weak self] (image, error, cacheType, imageURL) in
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
    
    func showPlaylistTableView(_ show: Bool) {
        let offset: CGFloat = show ? -Device.height()*0.6 : 0
        playlistTableViewBottomConstraint?.update(offset: offset)
        
        playlistTableView.setNeedsLayout()
        
        if show {
            playlistContentView.isHidden = false
            playlistTableView.reloadData()
            UIView.animate(withDuration: 0.25, animations: {
                self.playlistTableView.layoutIfNeeded()
                })
        }else {
            UIView.animate(withDuration: 0.25, animations: {
                self.playlistTableView.layoutIfNeeded()
                }, completion: {Void in
                    self.playlistContentView.isHidden = true
            })
        }
    }
    
    func loadDefaultData() {
        var imageAssetName: String
        let currentMode = MusicManager.shared.currentPlayMode()
        switch currentMode {
        case .ListLoop:
            imageAssetName = "player_cycle_list"
        case .SingleLoop:
            imageAssetName = "player_cycle_single"
        case .Random:
            imageAssetName = "player_cycle_random"
        }
        loopButton.setImage(UIImage(named: imageAssetName), for: .normal)
        
        
    }

}

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  MusicManager.shared.playlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! SongListTableViewCell
        cell.delegate = self
        
        let song =  MusicManager.shared.playlist[(indexPath as NSIndexPath).row]
        cell.updateSongInfo(song)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.bounds.width,height: 40))
        
        let downloadButton = UIButton()
        headerView.addSubview(downloadButton)
        downloadButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        downloadButton.backgroundColor = UIColor.grayColor1C()
        downloadButton.clipsToBounds = true
        downloadButton.layer.cornerRadius = 15
        downloadButton.setTitle("Download All", for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadAllButtonPressed(_:)), for: .touchUpInside)
        downloadButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 100, height: 30))
            make.centerY.equalTo(headerView.snp.centerY)
            make.leftMargin.equalTo(10)
        }
        
        let clearButton = UIButton()
        headerView.addSubview(clearButton)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        clearButton.backgroundColor = UIColor.grayColor1C()
        clearButton.clipsToBounds = true
        clearButton.layer.cornerRadius = 15
        clearButton.setTitle("Clear All", for: .normal)
        clearButton.addTarget(self, action: #selector(clearAllButtonPressed(_:)), for: .touchUpInside)
        clearButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 100, height: 30))
            make.centerY.equalTo(headerView.snp.centerY)
            make.rightMargin.equalTo(-10)
        }
        
        let separatorView = UIView()
        headerView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor97()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(headerView.snp.left)
            make.right.equalTo(headerView.snp.right)
            make.bottom.equalTo(headerView.snp.bottom)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        MusicManager.shared.currentIndex = (indexPath as NSIndexPath).row
        MusicManager.shared.play()
        
        showPlaylistTableView(false)
    }
    
    @objc func downloadAllButtonPressed(_ button: UIButton) {
        if MusicManager.shared.playlist.count > 0 {
//            CoreDB.addSongsToDownloadingList(MusicManager.shared.playlist)
            HudManager.showText("已经加入下载列表")
            showPlaylistTableView(false)
        }
    }
    @objc func clearAllButtonPressed(_ button: UIButton) {
        if MusicManager.shared.playlist.count > 0 {
            MusicManager.shared.clearList()
            playlistTableView.reloadData()
            showPlaylistTableView(false)
        }
    }
    
    @objc func emptyButtonPressed(_ button: UIButton) {
        showPlaylistTableView(false)
    }
    
}

extension PlayerViewController: SongListTableViewCellDelegate {
    func openToolPanelOfSong(_ song: Song) {

        let row = MusicManager.shared.indexOfPlaylist(song: song)
        
        let alertController = UIAlertController()

        let action1 = UIAlertAction(title: "收藏歌曲", style: .default, handler: { (action) in
            debugPrint("add to collecte")
        })
        let action2 = UIAlertAction(title: "下载歌曲", style: .default, handler: { (action) in
            CoreDB.addSongToDownloadingList(song)
            HudManager.showText("已经加入下载列表")
        })
        let action3 = UIAlertAction(title: "从列表中移除", style: .default, handler: { (action) in
            MusicManager.shared.removeSongFromPlaylist(song)
            self.playlistTableView.deleteRows(at: [IndexPath(row: row!, section: 0)], with: .bottom)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension PlayerViewController: STKAudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        debugPrint("didStartPlayingQueueItemId: \(queueItemId)")
        
        coverImageView.layer.removeAllAnimations()
        coverRotateAnimation = nil
        prepareAnimation()
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        debugPrint("didFinishBufferingSourceWithQueueItemId")
        
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        debugPrint("didFinishPlayingQueueItemId")
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        
        if state == .playing {
            playButton.setImage(UIImage(named: "player_paused"), for: .normal)
            playButton.setImage(UIImage(named: "player_paused_pressed"), for: .highlighted)
            
            NotificationManager.shared.postPlayMusicProgressStartedNotification()
            
            prepareAnimation()
        }
        else if state == .paused {
            playButton.setImage(UIImage(named: "player_play"), for: .normal)
            playButton.setImage(UIImage(named: "player_play_pressed"), for: .highlighted)
            
            NotificationManager.shared.postPlayMusicProgressPausedNotification()
        }
        else if state == .stopped {
            MusicManager.shared.playNextWhenFinished()
        }
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        debugPrint("unexpectedError")
    }
}
