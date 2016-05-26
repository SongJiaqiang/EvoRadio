//
//  PlayerViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import Alamofire
import AFSoundManager
import SnapKit

let playerControler = PlayerViewController.instance

class PlayerViewController: ViewController {
    let cellID = "audioCellID"
    
    var program: Program!
    var autoPlaying: Bool = false
    var refreshPlaylist: Bool = false
    var dataSource = [Song]()
    private var backgroundView = UIImageView()
    private var controlView = UIView()
    private var playerBar: PlayerBar!
    let coverImageView = UIImageView()

    var listTableView = UITableView()
    var listTableViewConstraint: Constraint? = nil
    
    var delegate: PlayerViewControllerDelegate?
    
    //MARK: instance
    class var instance: PlayerViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        prepareBackgroundView()
        prepareListTableView()
        prepareNavigationBar()
        preparePlayerControlView()
        prepareToolsView()
     
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        if refreshPlaylist {
            listProgramSongs()
            refreshPlaylist = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        
        playerView.show()
    }

    func prepareBackgroundView() {
        
        view.addSubview(backgroundView)
        backgroundView.contentMode = .ScaleAspectFill
        backgroundView.alpha = 0.1
        backgroundView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        if let _ = program {
            backgroundView.kf_setImageWithURL(NSURL(string: program.picURL!)!, placeholderImage: UIImage.placeholder_cover())
        }else {
            backgroundView.image = UIImage.placeholder_cover()
        }
    }
    
    func prepareCoverView() {
        
        let coverWidth: CGFloat = 200
        let coverView = UIImageView()
        view.addSubview(coverView)
        coverView.clipsToBounds = true
        coverView.layer.cornerRadius = coverWidth*0.5
        
        if let _ = program {
            coverView.kf_setImageWithURL(NSURL(string: program.cover!.pics!.first!)!, placeholderImage: UIImage.placeholder_cover())
        }else {
            coverView.image = UIImage.placeholder_cover()
        }
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
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(netHex: 0x1C1C1C, alpha: 1.0).CGColor,
            UIColor(netHex: 0x1C1C1C, alpha: 0.8).CGColor,
            UIColor(netHex: 0x1C1C1C, alpha: 0.0).CGColor
        ]
        gradientLayer.locations = [0.0, 0.2, 1.0]
        gradientLayer.startPoint = CGPointMake(0.5, 0)
        gradientLayer.endPoint = CGPointMake(0.5, 1)
        gradientLayer.frame = CGRectMake(0, 0, Device.width(), navBarHeight)
        navBar.layer.insertSublayer(gradientLayer, atIndex: 0)
        
        let titleLabel = UILabel()
        navBar.addSubview(titleLabel)
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.sizeOf14()
        titleLabel.textColor = UIColor.whiteColor()
        if let _ = program {
            titleLabel.text = program.programName
        }else {
            titleLabel.text = ""
        }
        titleLabel.snp_makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.equalTo(navBar.snp_left)
            make.right.equalTo(navBar.snp_right)
            make.bottom.equalTo(navBar.snp_bottom)
        }
        
        
        let closeButton = UIButton()
        navBar.addSubview(closeButton)
        closeButton.setImage(UIImage(named: "arrow_down"), forState: .Normal)
        closeButton.addTarget(self, action: #selector(PlayerViewController.closeButtonPressed), forControlEvents: .TouchUpInside)
        closeButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.leftMargin.equalTo(10)
            make.bottom.equalTo(navBar.snp_bottom)
        }
        
        let timerButton = UIButton()
        navBar.addSubview(timerButton)
        timerButton.setImage(UIImage(named: "timer"), forState: .Normal)
        timerButton.addTarget(self, action: #selector(PlayerViewController.timerButtonPressed), forControlEvents: .TouchUpInside)
        timerButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.rightMargin.equalTo(-10)
            make.bottom.equalTo(navBar.snp_bottom)
        }
        
        
//        playerBar = PlayerBar()
//        navBar.addSubview(playerBar)
//        playerBar.snp_makeConstraints { (make) in
//            make.height.equalTo(50)
//            make.topMargin.equalTo(0)
//            make.leftMargin.equalTo(0)
//            make.rightMargin.equalTo(0)
//        }
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PlayerViewController.onPlayerBarTap))
//        playerBar.addGestureRecognizer(tapGesture)
//        playerBar.userInteractionEnabled = true
//        
    }

    func prepareToolsView() {
        
        let toolsView = UIView()
        view.addSubview(toolsView)
//        toolsView.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
        toolsView.snp_makeConstraints { (make) in
            make.height.equalTo(50)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(view.snp_bottom)
        }
        
        let infoButton = UIButton()
        toolsView.addSubview(infoButton)
        infoButton.setImage(UIImage(named: "icon_info"), forState: .Normal)
        infoButton.addTarget(self, action: #selector(PlayerViewController.infoButtonPressed(_:)), forControlEvents: .TouchUpInside)
        infoButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.center.equalTo(toolsView.center)
        }
        
        let downloadButton = UIButton()
        toolsView.addSubview(downloadButton)
        downloadButton.setImage(UIImage(named: "icon_download"), forState: .Normal)
        downloadButton.setImage(UIImage(named: "icon_downloaded"), forState: .Selected)
        downloadButton.addTarget(self, action: #selector(PlayerViewController.downloadButtonPressed(_:)), forControlEvents: .TouchUpInside)
        downloadButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.right.equalTo(infoButton.snp_left).inset(-30)
        }
        
        let shareButton = UIButton()
        toolsView.addSubview(shareButton)
        shareButton.setImage(UIImage(named: "icon_share"), forState: .Normal)
        shareButton.addTarget(self, action: #selector(PlayerViewController.shareButtonPressed(_:)), forControlEvents: .TouchUpInside)
        shareButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.left.equalTo(infoButton.snp_right).inset(-30)
        }
        
        
        let repeatButton = UIButton()
        controlView.addSubview(repeatButton)
        repeatButton.setImage(UIImage(named: "icon_repeat"), forState: .Normal)
        repeatButton.addTarget(self, action: #selector(PlayerViewController.repeatButtonPressed(_:)), forControlEvents: .TouchUpInside)
        repeatButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.right.equalTo(downloadButton.snp_left).inset(-30)
        }
        
        let listButton = UIButton()
        controlView.addSubview(listButton)
        listButton.setImage(UIImage(named: "icon_list"), forState: .Normal)
        listButton.addTarget(self, action: #selector(PlayerViewController.listButtonPressed(_:)), forControlEvents: .TouchUpInside)
        listButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.left.equalTo(shareButton.snp_right).inset(-30)
        }

        
    }
    
    func preparePlayerControlView() {
        view.addSubview(controlView)
        controlView.backgroundColor = UIColor(white: 0.2, alpha: 1)
        controlView.snp_makeConstraints { (make) in
            make.height.equalTo(Device.height()-Device.width())
            make.bottom.equalTo(view.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        let playButton = UIButton()
        controlView.addSubview(playButton)
        playButton.clipsToBounds = true
        playButton.layer.cornerRadius = 25
        playButton.layer.borderColor = UIColor.whiteColor().CGColor
        playButton.layer.borderWidth = 1
        playButton.setImage(UIImage(named: "player_play"), forState: .Normal)
        playButton.setImage(UIImage(named: "player_pause"), forState: .Selected)
        playButton.addTarget(self, action: #selector(PlayerViewController.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(50, 50))
            make.center.equalTo(controlView.center)
        }
        
        let nextButton = UIButton()
        controlView.addSubview(nextButton)
        nextButton.setImage(UIImage(named: "player_next"), forState: .Normal)
        nextButton.addTarget(self, action: #selector(PlayerViewController.nextButtonPressed(_:)), forControlEvents: .TouchUpInside)
        nextButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.centerY.equalTo(controlView.snp_centerY)
            make.left.equalTo(playButton.snp_right).inset(-20)
        }
        
        let prevButton = UIButton()
        controlView.addSubview(prevButton)
        prevButton.setImage(UIImage(named: "player_prev"), forState: .Normal)
        prevButton.addTarget(self, action: #selector(PlayerViewController.prevButtonPressed(_:)), forControlEvents: .TouchUpInside)
        prevButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.centerY.equalTo(controlView.snp_centerY)
            make.right.equalTo(playButton.snp_left).inset(-20)
        }
        
        let slider = UISlider()
        controlView.addSubview(slider)
        let thumbImage = UIImage.circleImage(UIColor.whiteColor(), radius: 6)
        slider.setThumbImage(thumbImage, forState: .Normal)
        controlView.tintColor = UIColor.goldColor()
        slider.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalTo(controlView.snp_left).inset(50)
            make.right.equalTo(controlView.snp_right).inset(50)
            make.top.equalTo(controlView.snp_top)
        }
        
        let currentTimeLabel = UILabel()
        controlView.addSubview(currentTimeLabel)
        currentTimeLabel.textAlignment = .Center
        currentTimeLabel.font = UIFont.sizeOf10()
        currentTimeLabel.textColor = UIColor.whiteColor()
        currentTimeLabel.text = "01:43"
        currentTimeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(slider.snp_left)
            make.centerY.equalTo(slider.snp_centerY)
        }
        
        let totalTimeLabel = UILabel()
        controlView.addSubview(totalTimeLabel)
        totalTimeLabel.textAlignment = .Center
        totalTimeLabel.font = UIFont.sizeOf10()
        totalTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.text = "04:21"
        totalTimeLabel.snp_makeConstraints { (make) in
            make.right.equalTo(view.snp_right)
            make.left.equalTo(slider.snp_right)
            make.centerY.equalTo(slider.snp_centerY)
        }
        
    }
    
    func prepareListTableView() {
        view.addSubview(listTableView)
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.backgroundColor = UIColor.clearColor()
        listTableView.bounces = false
        listTableView.snp_makeConstraints(closure: {(make) in
            make.height.equalTo(Device.width())
            make.top.equalTo(view.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        })
        
        listTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        let headerView = UIView()
        headerView.frame = CGRectMake(0, 0, Device.width(), Device.width())
        
        
        headerView.addSubview(coverImageView)
        coverImageView.contentMode = .ScaleAspectFill
        coverImageView.clipsToBounds = true
        if let _ = program {
            coverImageView.kf_setImageWithURL(NSURL(string: program.cover!.pics!.first!)!, placeholderImage: UIImage.placeholder_cover())
        }else {
            coverImageView.image = UIImage.placeholder_cover()
        }
        coverImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        listTableView.tableHeaderView = headerView
    }
    
    func listProgramSongs() {
        
        if let _ = program {
            let programID = program.programID!
            
            api.fetch_songs(programID, onSuccess: {[weak self] (items) in
                
                if items.count > 0 {
                    // download first audio file
                    
                    let newData = items as! [Song]
                    self?.dataSource.appendContentsOf(newData)
                    
                    self?.updateCover()
                    self?.listTableView.reloadData()
                    if self?.autoPlaying == true {
                        let song = newData.first
                        Downloader.downloader.downloadFile(song!.audioURL!)
                    }
                }else {
                    print("This program has no one song")
                }
                
                }, onFailed: nil)
        }
        
    }
    
    //MARK: event
    func playButtonPressed(button: UIButton) {
        if program == nil{
            return
        }
        
        button.selected = !button.selected
        
        if button.selected {
            MusicManager.sharedManager.playItem()
        }else {
            MusicManager.sharedManager.pauseItem()
        }
        
    }
    func nextButtonPressed(button: UIButton) {
        MusicManager.sharedManager.playNext()
    }
    func prevButtonPressed(button: UIButton) {
        MusicManager.sharedManager.playPrev()
    }
    func repeatButtonPressed(button: UIButton) {
        
    }
    func listButtonPressed(button: UIButton) {

    }
    func heartButtonPressed(button: UIButton) {
        button.selected = !button.selected
    }
    func downloadButtonPressed(button: UIButton) {
        button.selected = !button.selected
    }
    func shareButtonPressed(button: UIButton) {
        
    }
    func infoButtonPressed(button: UIButton) {
        
    }
    
    func closeButtonPressed() {
        delegate?.playerViewWillClose()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func timerButtonPressed() {
        
    }
    
    func onPlayerBarTap(gesture: UITapGestureRecognizer) {
        delegate?.playerViewWillOpen()
    }
    
    func updateCover() {
        if let _ = program {
            coverImageView.kf_setImageWithURL(NSURL(string: program.cover!.pics!.first!)!, placeholderImage: UIImage.placeholder_cover())
        }else {
            coverImageView.image = UIImage.placeholder_cover()
        }
    }

}

extension PlayerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        
        let song = dataSource[indexPath.row]
        
        cell?.textLabel?.text = song.songName
        cell?.detailTextLabel?.text = song.artistsName
        cell?.imageView?.kf_setImageWithURL(NSURL(string: song.picURL!)!, placeholderImage: UIImage.placeholder_cover())
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 1. download file
        let song = dataSource[indexPath.row]
        
//        self.downloadFile(song.audioURL!)

        Downloader.downloader.downloadFile(song.audioURL!)
        // 2. play audio
        
        self.listTableViewConstraint?.updateOffset(Device.width())
    }
}

protocol PlayerViewControllerDelegate {
    func playerViewWillOpen()
    func playerViewWillClose()
}
