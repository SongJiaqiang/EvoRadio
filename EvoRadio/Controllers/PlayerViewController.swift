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
import GPUImage
import StreamingKit

class PlayerViewController: ViewController {
    let cellID = "playerControllerPlaylistCellID"
    let toolButtonWidth: CGFloat = 50
    
    private var coverImageView = CDCoverImageView(frame: CGRectZero)
    var backgroundGPUImageView = GPUImageView()
    var filterImage: GPUImagePicture?
    let blurFilter = GPUImageiOSBlurFilter()
    
    private var controlView = UIView()
    let progressSlider = UISlider()
    let currentTimeLabel = UILabel()
    let totalTimeLabel = UILabel()
    let playButton = UIButton()
    let nextButton = UIButton()
    let prevButton = UIButton()
    let loopButton = UIButton()
    let timerButton = UIButton()
    let titleLabel = UILabel()
    let playlistTableView = UITableView(frame: CGRectZero, style: .Grouped)
    let playlistContentView = UIView()
    var playlistTableViewBottomConstraint: Constraint?
    
    var progressTimer: NSTimer?
    var autoStopTimer: NSTimer?
    var leftTime: NSTimeInterval = 3600
    
    var coverRotateAnimation: CABasicAnimation?;
    
    //MARK: instance
    class var playerController: PlayerViewController {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlayerViewController! = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = PlayerViewController()
        }
        return Static.instance
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: life cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("player viewDidLoad")
        
        MusicManager.sharedManager.audioPlayer.delegate = self
        progressTimer = NSTimer(timeInterval: 1, target: self, selector: #selector(progressHandle), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(progressTimer!, forMode: NSRunLoopCommonModes)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PlayerView.instance.hide()
        
        if MusicManager.sharedManager.isPlaying() {
            coverImageView.layer.removeAllAnimations()
            coverRotateAnimation = nil
            prepareAnimation()
        } else if MusicManager.sharedManager.isPaused() {
            coverRotateAnimation = nil
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        PlayerView.instance.show()
    }

    //MARK: prepare ui
    func prepare() {
        
        prepareBackgroundView()
        preparePlayerControlView()
        prepareToolsView()
        prepareNavigationBar()
        prepareTableView()

        NotificationManager.instance.addUpdatePlayerControllerObserver(self, action: #selector(PlayerViewController.updatePlayerController(_:)))
        
    }
    
    func prepareBackgroundView() {
        view.addSubview(coverImageView)
        coverImageView.image = UIImage.placeholder_cover()
        coverImageView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(240, 240))
            make.centerX.equalTo(view.snp_centerX)
            let topMargin = (Device.height()-200-64)*0.5-100+64
            make.topMargin.equalTo(topMargin)
        }
        
        backgroundGPUImageView.backgroundColor = UIColor.grayColor5()
        view.insertSubview(backgroundGPUImageView, belowSubview: coverImageView)
        backgroundGPUImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        backgroundGPUImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
    }
    
    func prepareCoverView() {
        
        let coverWidth: CGFloat = 200
        let coverView = UIImageView()
        view.addSubview(coverView)
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = coverWidth*0.5
        
        coverView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(coverWidth, coverWidth))
            make.center.equalTo(view.snp_center)
        }
    }
    
    func prepareNavigationBar() {
        let navBarHeight: CGFloat = 64
        
        let navBar = UIView()
        view.addSubview(navBar)
        navBar.snp_makeConstraints { (make) in
            make.height.equalTo(navBarHeight)
            make.top.equalTo(view.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        navBar.addSubview(titleLabel)
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.sizeOf14()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.snp_makeConstraints { (make) in
            make.height.equalTo(44)
            make.leftMargin.equalTo(60)
            make.rightMargin.equalTo(-60)
            make.bottom.equalTo(navBar.snp_bottom)
        }
        
        let closeButton = UIButton()
        navBar.addSubview(closeButton)
        closeButton.setImage(UIImage(named: "nav_dismiss"), forState: .Normal)
        closeButton.addTarget(self, action: #selector(PlayerViewController.closeButtonPressed), forControlEvents: .TouchUpInside)
        closeButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.leftMargin.equalTo(10)
            make.bottom.equalTo(navBar.snp_bottom)
        }
  
    }

    func prepareToolsView() {
        let itemWidth: CGFloat = min(Device.width() / 5, 60)
        
        let toolsView = UIView()
        view.addSubview(toolsView)
//        toolsView.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
        toolsView.snp_makeConstraints { (make) in
            make.height.equalTo(itemWidth)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(view.snp_bottom)
        }
        
//        let infoButton = UIButton()
//        toolsView.addSubview(infoButton)
//        infoButton.setImage(UIImage(named: "player_info"), forState: .Normal)
//        infoButton.addTarget(self, action: #selector(PlayerViewController.infoButtonPressed(_:)), forControlEvents: .TouchUpInside)
//        infoButton.snp_makeConstraints { (make) in
//            make.size.equalTo(CGSizeMake(itemWidth, itemWidth))
//            make.center.equalTo(toolsView.center)
//        }
        
        toolsView.addSubview(timerButton)
        timerButton.setImage(UIImage(named: "player_timer"), forState: .Normal)
        timerButton.setImage(UIImage(named: "player_timer_selected"), forState: .Selected)
        timerButton.addTarget(self, action: #selector(PlayerViewController.timerButtonPressed(_:)), forControlEvents: .TouchUpInside)
        timerButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(itemWidth, itemWidth))
            make.center.equalTo(toolsView.center)
        }
        
        let downloadButton = UIButton()
        toolsView.addSubview(downloadButton)
        downloadButton.setImage(UIImage(named: "player_download"), forState: .Normal)
        downloadButton.setImage(UIImage(named: "player_download_selected"), forState: .Selected)
        downloadButton.addTarget(self, action: #selector(PlayerViewController.downloadButtonPressed(_:)), forControlEvents: .TouchUpInside)
        downloadButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(itemWidth, itemWidth))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.right.equalTo(timerButton.snp_left)
        }
        
        let shareButton = UIButton()
        toolsView.addSubview(shareButton)
        shareButton.setImage(UIImage(named: "player_share"), forState: .Normal)
        shareButton.addTarget(self, action: #selector(PlayerViewController.shareButtonPressed(_:)), forControlEvents: .TouchUpInside)
        shareButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(itemWidth, itemWidth))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.left.equalTo(timerButton.snp_right)
        }
        
        toolsView.addSubview(loopButton)
        loopButton.setImage(UIImage(named: "player_cycle_list"), forState: .Normal)
        loopButton.addTarget(self, action: #selector(PlayerViewController.loopButtonPressed(_:)), forControlEvents: .TouchUpInside)
        loopButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(itemWidth, itemWidth))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.right.equalTo(downloadButton.snp_left)
        }
        
        let listButton = UIButton()
        toolsView.addSubview(listButton)
        listButton.setImage(UIImage(named: "player_list"), forState: .Normal)
        listButton.addTarget(self, action: #selector(PlayerViewController.listButtonPressed(_:)), forControlEvents: .TouchUpInside)
        listButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(itemWidth, itemWidth))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.left.equalTo(shareButton.snp_right)
        }

        loadDefaultData()
        
    }
    
    func preparePlayerControlView() {
        view.addSubview(controlView)
//        controlView.backgroundColor = UIColor(white: 0.2, alpha: 1)
        controlView.snp_makeConstraints { (make) in
            make.height.equalTo(200)
            make.bottom.equalTo(view.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        controlView.addSubview(playButton)
        playButton.setImage(UIImage(named: "player_play"), forState: .Normal)
        playButton.setImage(UIImage(named: "player_play_pressed"), forState: .Highlighted)
        playButton.addTarget(self, action: #selector(PlayerViewController.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(60, 60))
            make.center.equalTo(controlView.center)
        }
        
        controlView.addSubview(nextButton)
        nextButton.setImage(UIImage(named: "player_next"), forState: .Normal)
        nextButton.addTarget(self, action: #selector(PlayerViewController.nextButtonPressed(_:)), forControlEvents: .TouchUpInside)
        nextButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(toolButtonWidth, toolButtonWidth))
            make.centerY.equalTo(controlView.snp_centerY)
            make.left.equalTo(playButton.snp_right).inset(-20)
        }
        
        
        controlView.addSubview(prevButton)
        prevButton.setImage(UIImage(named: "player_prev"), forState: .Normal)
        prevButton.addTarget(self, action: #selector(PlayerViewController.prevButtonPressed(_:)), forControlEvents: .TouchUpInside)
        prevButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(toolButtonWidth, toolButtonWidth))
            make.centerY.equalTo(controlView.snp_centerY)
            make.right.equalTo(playButton.snp_left).inset(-20)
        }
        
        controlView.addSubview(progressSlider)
        progressSlider.setThumbImage(UIImage(named: "dot_white")!, forState: .Normal)
        progressSlider.tintColor = UIColor.goldColor()
        progressSlider.addTarget(self, action: #selector(PlayerViewController.progressSliderChanged(_:)), forControlEvents: .ValueChanged)
        progressSlider.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalTo(controlView.snp_left).inset(50)
            make.right.equalTo(controlView.snp_right).inset(50)
            make.top.equalTo(controlView.snp_top)
        }
        
        controlView.addSubview(currentTimeLabel)
        currentTimeLabel.textAlignment = .Center
        currentTimeLabel.font = UIFont.sizeOf10()
        currentTimeLabel.textColor = UIColor.whiteColor()
        currentTimeLabel.text = "0:00"
        currentTimeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(progressSlider.snp_left)
            make.centerY.equalTo(progressSlider.snp_centerY)
        }
        
        controlView.addSubview(totalTimeLabel)
        totalTimeLabel.textAlignment = .Center
        totalTimeLabel.font = UIFont.sizeOf10()
        totalTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.text = "0:00"
        totalTimeLabel.snp_makeConstraints { (make) in
            make.right.equalTo(view.snp_right)
            make.left.equalTo(progressSlider.snp_right)
            make.centerY.equalTo(progressSlider.snp_centerY)
        }
        
    }
    
    func prepareTableView() {

        view.addSubview(playlistContentView)
        playlistContentView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        playlistContentView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        }
        
        let emptyButton = UIButton()
        playlistContentView.addSubview(emptyButton)
        emptyButton.addTarget(self, action: #selector(PlayerViewController.emptyButtonPressed(_:)), forControlEvents: .TouchUpInside)
        emptyButton.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        }
        
        playlistContentView.addSubview(playlistTableView)
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
        playlistTableView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        playlistTableView.separatorStyle = .None
        playlistTableView.snp_makeConstraints(closure: {(make) in
            make.height.equalTo(Device.height()*0.6)
            make.left.equalTo(playlistContentView.snp_left)
            make.right.equalTo(playlistContentView.snp_right)
            playlistTableViewBottomConstraint = make.top.equalTo(playlistContentView.snp_bottom).offset(0).constraint
        })
        
        playlistTableView.registerClass(SongListTableViewCell.self, forCellReuseIdentifier: cellID)
        
        playlistContentView.hidden = true
    }
    
    func prepareAnimation() {
        if coverRotateAnimation == nil {
            coverRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            coverRotateAnimation!.duration = 30
            coverRotateAnimation!.fromValue = NSNumber(double: 0)
            coverRotateAnimation!.toValue = NSNumber(double: M_PI * 2)
            coverRotateAnimation!.repeatCount = MAXFLOAT
            coverRotateAnimation!.autoreverses = false
            coverRotateAnimation!.cumulative = true
            coverImageView.layer.speed = 1
            coverImageView.layer.addAnimation(coverRotateAnimation!, forKey: "coverRotateAnimation")
        }
    }
    
    //MARK: events
    func playButtonPressed(button: UIButton) {
        
        if MusicManager.sharedManager.isStoped() {
            return
        }
        
        if MusicManager.sharedManager.isPaused() {
            MusicManager.sharedManager.resume()
            
            let stopTime = coverImageView.layer.timeOffset
            coverImageView.layer.beginTime = 0
            coverImageView.layer.timeOffset = 0
            coverImageView.layer.speed = 1
            let tempTime = coverImageView.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - stopTime
            coverImageView.layer.beginTime = tempTime
            
            
        } else if MusicManager.sharedManager.isPlaying() {
            MusicManager.sharedManager.pause()
            NotificationManager.instance.postPlayMusicProgressPausedNotification()
            
            let stopTime = coverImageView.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
            coverImageView.layer.speed = 0
            coverImageView.layer.timeOffset = stopTime
        }else {
            debugPrint("鬼知道发生了什么！")
        }
        
    }
    func nextButtonPressed(button: UIButton) {
        MusicManager.sharedManager.playNext()
        
        coverImageView.layer.removeAllAnimations()
        coverRotateAnimation = nil
    }
    
    func prevButtonPressed(button: UIButton) {
        MusicManager.sharedManager.playPrev()
        
        coverImageView.layer.removeAllAnimations()
        coverRotateAnimation = nil
    }
    
    func loopButtonPressed(button: UIButton) {
        var imageAssetName: String
        var showText: String
        let newMode = MusicManager.sharedManager.changePlayMode()
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
        
        loopButton.setImage(UIImage(named: imageAssetName), forState: .Normal)
        HudManager.showText(showText, inView: view)
    }
    
    func listButtonPressed(button: UIButton) {
        showPlaylistTableView(true)
    }
    
    func heartButtonPressed(button: UIButton) {
        button.selected = !button.selected
    }
    
    func downloadButtonPressed(button: UIButton) {
        if let cSong = MusicManager.sharedManager.currentSong() {
            CoreDB.addSongToDownloadingList(cSong)
//            button.selected = true
            HudManager.showText("已经加入下载列表")
        }
    }
    func shareButtonPressed(button: UIButton) {
        if let currentSong = MusicManager.sharedManager.currentSong() {
            let social  = SocialController(music: currentSong, shareImage: coverImageView.image!, shareText: "")
            presentViewController(social, animated: true, completion: nil)
        }
    }
    func infoButtonPressed(button: UIButton) {
        debugPrint("infoButtonPressed")
    }
    
    func closeButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func timerButtonPressed(button: UIButton) {
        if button.selected {
            button.selected = false
            if let _ = autoStopTimer {
                autoStopTimer?.invalidate()
                autoStopTimer = nil
            }
            
        }else {
            let alertController = UIAlertController(title: "设置自动停止播放时间", message: nil, preferredStyle: .ActionSheet)
            let action1 = UIAlertAction(title: "10 minutes", style: .Default, handler: { (action) in
                button.selected = true
                self.leftTime = 600
                if self.autoStopTimer == nil {
                    self.autoStopTimer = NSTimer(timeInterval: 5, target: self, selector: #selector(PlayerViewController.autoStopHandle), userInfo: nil, repeats: true)
                    NSRunLoop.mainRunLoop().addTimer(self.autoStopTimer!, forMode: NSRunLoopCommonModes)
                }
                
            })
            let action2 = UIAlertAction(title: "15 minutes", style: .Default, handler: { (action) in
                button.selected = true
                self.leftTime = 900
            })
            let action3 = UIAlertAction(title: "30 minutes", style: .Default, handler: { (action) in
                button.selected = true
                self.leftTime = 1800
            })
            let action4 = UIAlertAction(title: "1 hour", style: .Default, handler: { (action) in
                button.selected = true
                self.leftTime = 3600
            })
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(action3)
            alertController.addAction(action4)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        
        
    }
    
    func progressSliderChanged(slider: UISlider) {
        let timePlayed = slider.value
        MusicManager.sharedManager.playAtSecond(Int(timePlayed))
    }
    
    func updatePlayerController(noti: NSNotification) {
        if let song = MusicManager.sharedManager.currentSong() {
            updateCoverImage(song)
            
        }
    }
    
    func autoStopHandle() {
        debugPrint("Timer: \(leftTime)")
        leftTime -= 5
        if leftTime <= 0 {
            debugPrint("Time out, will stop music")
            
            autoStopTimer?.invalidate()
            autoStopTimer = nil
            
            MusicManager.sharedManager.pause()
            timerButton.selected = false
        }
    }
    
    func progressHandle() {
        let duration:Float = Float(MusicManager.sharedManager.audioPlayer.duration)
        let timePlayed: Float = Float(MusicManager.sharedManager.audioPlayer.progress)
        
        progressSlider.maximumValue = duration
        progressSlider.value = timePlayed
        
        totalTimeLabel.text = NSDate.secondsToMinuteString(Int(duration))
        currentTimeLabel.text = NSDate.secondsToMinuteString(Int(timePlayed))
        
        MusicManager.sharedManager.updatePlaybackTime(Double(timePlayed))
    }
    
    
    //MARK: other
    func configureFilterImage(coverImage: UIImage) {
        if Device.shareApplication().applicationState == .Background {
            return
        }
        
        filterImage = GPUImagePicture(image: coverImage, smoothlyScaleOutput: true)
        filterImage!.addTarget(blurFilter as GPUImageInput)
        blurFilter.useNextFrameForImageCapture()
        blurFilter.addTarget(backgroundGPUImageView)
        filterImage!.processImage()
        
        blurFilter.blurRadiusInPixels = 10
        filterImage?.processImageWithCompletionHandler({[weak self] Void in
            
            self?.backgroundGPUImageView.alpha = 0.2
            UIView.animateWithDuration(2, animations: { Void in
                self?.backgroundGPUImageView.alpha = 1
            })

        })
        
    }
    
    
    func updateCoverImage(song: Song) {
        debugPrint("update cover image")
        titleLabel.text = song.songName
        
        if let picUrl = song.picURL {
            coverImageView.kf_setImageWithURL(NSURL(string: picUrl)!, placeholderImage: UIImage.placeholder_cover(), completionHandler: {[weak self] (image, error, cacheType, imageURL) in
                if let _ = image{
                    self?.configureFilterImage(image!)
                }
                })
        }
    }
    
    func showPlaylistTableView(show: Bool) {
        let offset: CGFloat = show ? -Device.height()*0.6 : 0
        playlistTableViewBottomConstraint?.updateOffset(offset)
        playlistTableView.setNeedsLayout()
        
        if show {
            playlistContentView.hidden = false
            playlistTableView.reloadData()
            UIView.animateWithDuration(0.25, animations: {[weak self] Void in
                self?.playlistTableView.layoutIfNeeded()
                })
        }else {
            UIView.animateWithDuration(0.25, animations: {[weak self] Void in
                self?.playlistTableView.layoutIfNeeded()
                }, completion: {Void in
                    self.playlistContentView.hidden = true
            })
        }
    }
    
    func loadDefaultData() {
        var imageAssetName: String
        let currentMode = MusicManager.sharedManager.currentPlayMode()
        switch currentMode {
        case .ListLoop:
            imageAssetName = "player_cycle_list"
        case .SingleLoop:
            imageAssetName = "player_cycle_single"
        case .Random:
            imageAssetName = "player_cycle_random"
        }
        loopButton.setImage(UIImage(named: imageAssetName), forState: .Normal)
        
        
    }

}

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  MusicManager.sharedManager.playlist.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! SongListTableViewCell
        cell.delegate = self
        
        let song =  MusicManager.sharedManager.playlist[indexPath.row]
        cell.updateSongInfo(song)
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0,0,tableView.bounds.width,40))
        
        let downloadButton = UIButton()
        headerView.addSubview(downloadButton)
        downloadButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        downloadButton.backgroundColor = UIColor.grayColor3()
        downloadButton.clipsToBounds = true
        downloadButton.layer.cornerRadius = 15
        downloadButton.setTitle("Download All", forState: .Normal)
        downloadButton.addTarget(self, action: #selector(PlayerViewController.downloadAllButtonPressed(_:)), forControlEvents: .TouchUpInside)
        downloadButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(100, 30))
            make.centerY.equalTo(headerView.snp_centerY)
            make.leftMargin.equalTo(10)
        }
        
        let separatorView = UIView()
        headerView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor6()
        separatorView.snp_makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(headerView.snp_left)
            make.right.equalTo(headerView.snp_right)
            make.bottom.equalTo(headerView.snp_bottom)
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        MusicManager.sharedManager.currentIndex = indexPath.row
        MusicManager.sharedManager.play()
        
        showPlaylistTableView(false)
    }
    
    func downloadAllButtonPressed(button: UIButton) {
        if MusicManager.sharedManager.playlist.count > 0 {
            CoreDB.addSongsToDownloadingList(MusicManager.sharedManager.playlist)
            showPlaylistTableView(false)
        }
    }
    
    func emptyButtonPressed(button: UIButton) {
        showPlaylistTableView(false)
    }
    
}

extension PlayerViewController: SongListTableViewCellDelegate {
    func openToolPanelOfSong(song: Song) {
        let row =  MusicManager.sharedManager.playlist.indexOf(song)
        
        let alertController = UIAlertController()

        let action1 = UIAlertAction(title: "收藏歌曲", style: .Default, handler: { (action) in
            debugPrint("add to collecte")
        })
        let action2 = UIAlertAction(title: "下载歌曲", style: .Default, handler: { (action) in
            CoreDB.addSongToDownloadingList(song)
            HudManager.showText("已经加入下载列表")
        })
        let action3 = UIAlertAction(title: "从列表中移除", style: .Default, handler: { (action) in
            MusicManager.sharedManager.removeSongFromPlaylist(song)
            self.playlistTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: row!, inSection: 0)], withRowAnimation: .Bottom)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

extension PlayerViewController: STKAudioPlayerDelegate {
    func audioPlayer(audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        debugPrint("didStartPlayingQueueItemId: \(queueItemId)")
        
        coverImageView.layer.removeAllAnimations()
        coverRotateAnimation = nil
        prepareAnimation()
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        debugPrint("didFinishBufferingSourceWithQueueItemId")
        
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        debugPrint("didFinishPlayingQueueItemId")
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        debugPrint("stateChanged: \(state)")
        
        if state == .Playing {
            playButton.setImage(UIImage(named: "player_paused"), forState: .Normal)
            playButton.setImage(UIImage(named: "player_paused_pressed"), forState: .Highlighted)
            
            NotificationManager.instance.postPlayMusicProgressStartedNotification()
            
            prepareAnimation()
        }
        else if state == .Paused {
            playButton.setImage(UIImage(named: "player_play"), forState: .Normal)
            playButton.setImage(UIImage(named: "player_play_pressed"), forState: .Highlighted)
            
            NotificationManager.instance.postPlayMusicProgressPausedNotification()
        }
        else if state == .Stopped {
            MusicManager.sharedManager.playNextWhenFinished()
        }
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        debugPrint("unexpectedError")
    }
}
