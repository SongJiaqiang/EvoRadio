//
//  PlayerViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class PlayerViewController: ViewController {
    let cellID = "audioCellID"
    
    var program: Program!
    var dataSource = [Song]()
    private var backgroundView = UIImageView()
    private var controlView = UIView()

    var listTableView: UITableView?
    
    convenience init(program: Program) {
        self.init()
        
        self.program = program
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        prepareBackgroundView()
        prepareCoverView()
        prepareNavigationBar()
        
        preparePlayerControlView()
        prepareToolsView()
        
        
    }

    func prepareBackgroundView() {
        
        view.addSubview(backgroundView)
        backgroundView.contentMode = .ScaleAspectFill
        backgroundView.alpha = 0.1
        backgroundView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        backgroundView.kf_setImageWithURL(NSURL(string: program.picURL!)!, placeholderImage: UIImage.placeholder_cover())
    }
    
    func prepareCoverView() {
        
        let coverView = UIImageView()
        view.addSubview(coverView)
        coverView.kf_setImageWithURL(NSURL(string: program.cover!.pics!.first!)!, placeholderImage: UIImage.placeholder_cover())
        coverView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(Device.width(), Device.width()))
            make.top.equalTo(view.snp_top)
            make.left.equalTo(view.snp_left)
        
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
        titleLabel.text = program.programName
        titleLabel.snp_makeConstraints { (make) in
            make.height.equalTo(44)
            make.left.equalTo(navBar.snp_left)
            make.right.equalTo(navBar.snp_right)
            make.bottom.equalTo(navBar.snp_bottom)
        }
        
        
        let closeButton = UIButton()
        navBar.addSubview(closeButton)
        closeButton.setImage(UIImage(named: "icon_down"), forState: .Normal)
        closeButton.addTarget(self, action: #selector(PlayerViewController.dismiss), forControlEvents: .TouchUpInside)
        closeButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.leftMargin.equalTo(10)
            make.bottom.equalTo(navBar.snp_bottom)
        }
        
        let timerButton = UIButton()
        navBar.addSubview(timerButton)
        timerButton.setImage(UIImage(named: "icon_timer"), forState: .Normal)
        timerButton.addTarget(self, action: #selector(PlayerViewController.dismiss), forControlEvents: .TouchUpInside)
        timerButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.rightMargin.equalTo(-10)
            make.bottom.equalTo(navBar.snp_bottom)
        }
        
    }

    func prepareToolsView() {
        
        let toolsView = UIView()
        view.addSubview(toolsView)
        toolsView.snp_makeConstraints { (make) in
            make.height.equalTo(80)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(controlView.snp_top)
        }
        
        let infoButton = UIButton()
        toolsView.addSubview(infoButton)
        infoButton.setImage(UIImage(named: "icon_info"), forState: .Normal)
        infoButton.addTarget(self, action: #selector(PlayerViewController.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        infoButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.center.equalTo(toolsView.center)
        }
        
        let downloadButton = UIButton()
        toolsView.addSubview(downloadButton)
        downloadButton.setImage(UIImage(named: "icon_download"), forState: .Normal)
        downloadButton.addTarget(self, action: #selector(PlayerViewController.nextButtonPressed(_:)), forControlEvents: .TouchUpInside)
        downloadButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.right.equalTo(infoButton.snp_left).inset(-30)
        }
        
        let shareButton = UIButton()
        toolsView.addSubview(shareButton)
        shareButton.setImage(UIImage(named: "icon_share"), forState: .Normal)
        shareButton.addTarget(self, action: #selector(PlayerViewController.prevButtonPressed(_:)), forControlEvents: .TouchUpInside)
        shareButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(toolsView.snp_centerY)
            make.left.equalTo(infoButton.snp_right).inset(-30)
        }
        
        
    }
    
    func preparePlayerControlView() {
        view.addSubview(controlView)
        controlView.snp_makeConstraints { (make) in
            make.height.equalTo(100)
            make.bottom.equalTo(view.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        let playButton = UIButton()
        controlView.addSubview(playButton)
        playButton.setImage(UIImage(named: "icon_player_start"), forState: .Normal)
        playButton.addTarget(self, action: #selector(PlayerViewController.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(50, 50))
            make.center.equalTo(controlView.center)
        }
        
        let nextButton = UIButton()
        controlView.addSubview(nextButton)
        nextButton.setImage(UIImage(named: "icon_player_next"), forState: .Normal)
        nextButton.addTarget(self, action: #selector(PlayerViewController.nextButtonPressed(_:)), forControlEvents: .TouchUpInside)
        nextButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.centerY.equalTo(controlView.snp_centerY)
            make.left.equalTo(playButton.snp_right).inset(-10)
        }
        
        let prevButton = UIButton()
        controlView.addSubview(prevButton)
        prevButton.setImage(UIImage(named: "icon_player_prev"), forState: .Normal)
        prevButton.addTarget(self, action: #selector(PlayerViewController.prevButtonPressed(_:)), forControlEvents: .TouchUpInside)
        prevButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.centerY.equalTo(controlView.snp_centerY)
            make.right.equalTo(playButton.snp_left).inset(-10)
        }
        
        let repeatButton = UIButton()
        controlView.addSubview(repeatButton)
        repeatButton.setImage(UIImage(named: "icon_repeat"), forState: .Normal)
        repeatButton.addTarget(self, action: #selector(PlayerViewController.repeatButtonPressed(_:)), forControlEvents: .TouchUpInside)
        repeatButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(controlView.snp_centerY)
            make.right.equalTo(prevButton.snp_left).inset(-20)
        }
        
        let listButton = UIButton()
        controlView.addSubview(listButton)
        listButton.setImage(UIImage(named: "icon_list"), forState: .Normal)
        listButton.addTarget(self, action: #selector(PlayerViewController.listButtonPressed(_:)), forControlEvents: .TouchUpInside)
        listButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(controlView.snp_centerY)
            make.left.equalTo(nextButton.snp_right).inset(-20)
        }
        
        let slider = UISlider()
        controlView.addSubview(slider)
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
        if let _ = listTableView {
            
        }else {
            listTableView = UITableView()
            view.addSubview(listTableView!)
            listTableView!.delegate = self
            listTableView!.dataSource = self
            listTableView!.frame = CGRectMake(0, 0, Device.width(), Device.width())
            listTableView?.snp_makeConstraints(closure: { (make) in
                make.size.equalTo(CGSizeMake(Device.width(), Device.width()))
                make.bottom.equalTo(view.snp_bottom)
                make.left.equalTo(view.snp_left)
                make.right.equalTo(view.snp_right)
            })
            
            listTableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        }
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func listProgramSongs() {
        
        let programID = program.programID!
        
        api.fetch_songs(programID, onSuccess: {[weak self] (responseData) in
            
            if responseData.count > 0 {
                
                let newData = Song.songsWithDict(responseData)
                
                self?.dataSource.appendContentsOf(newData)
                
                self?.listTableView!.reloadData()
            }else {
                print("This program has no one song")
            }
            
            }, onFailed: nil)
        
    }
    
    //MARK: event
    func playButtonPressed(button: UIButton) {
        
    }
    func nextButtonPressed(button: UIButton) {
        
    }
    func prevButtonPressed(button: UIButton) {
        
    }
    func repeatButtonPressed(button: UIButton) {
        
    }
    func listButtonPressed(button: UIButton) {
        prepareListTableView()
        listProgramSongs()

    }
    func heartButtonPressed(button: UIButton) {
        
    }
    func downloadButtonPressed(button: UIButton) {
        
    }
    func shareButtonPressed(button: UIButton) {
        
    }
    func infoButtonPressed(button: UIButton) {
        
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
}
