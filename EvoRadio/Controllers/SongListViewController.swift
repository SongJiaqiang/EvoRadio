//
//  SongListViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 5/29/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class SongListViewController: ViewController {

    let cellID = "songCellID"
    
    var program: Program!
    var dataSource = [Song]()

    var tableView = UITableView(frame: CGRectZero, style: .Grouped)
    var coverImageView = UIImageView()
    
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupBackButton()
        prepareTableView()
        
        if let _ = program {
            title = program.programName
            listProgramSongs()
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PlayerView.instance.hide()
        AssistiveTouch.sharedTouch.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        AssistiveTouch.sharedTouch.addTarget(self, action: #selector(SongListViewController.goBack), forControlEvents: .TouchUpInside)
        AssistiveTouch.sharedTouch.setImage(UIImage(named: "arrow_left_white")!, forState: .Normal)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        PlayerView.instance.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: prepare UI
    func prepareTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.snp_makeConstraints(closure: {(make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        })
        
        tableView.registerClass(SongListTableViewCell.self, forCellReuseIdentifier: cellID)
        
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
        
        tableView.tableHeaderView = headerView
    }
    
    //MARK: events
    func listProgramSongs() {
        
        if let _ = program {
            let programID = program.programID!
            api.fetch_songs(programID, isVIP: true, onSuccess: {[weak self] (items) in
                
                if items.count > 0 {
                    let songs = items as! [Song]
                    self?.dataSource = songs
                    PlaylistManager.instance.saveList(songs)
                    
                    self?.updateCover()
                    self?.tableView.reloadData()
                }else {
                    debugPrint("This program has no songs")
                }
                
            }, onFailed: nil)
        }
        
    }
    
    func updateCover() {
        if let _ = program {
            coverImageView.kf_setImageWithURL(NSURL(string: program.cover!.pics!.first!)!, placeholderImage: UIImage.placeholder_cover())
        }else {
            coverImageView.image = UIImage.placeholder_cover()
        }
    }
}

extension SongListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! SongListTableViewCell
        cell.delegate = self
        
        let song = dataSource[indexPath.row]
        cell.updateSongInfo(song)
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0,0,tableView.bounds.width,40))
        
        let playButton = UIButton()
        headerView.addSubview(playButton)
        playButton.titleLabel?.font = UIFont.sizeOf12()
        playButton.backgroundColor = UIColor.grayColor3()
        playButton.clipsToBounds = true
        playButton.layer.cornerRadius = 15
        playButton.setTitle("Play All", forState: .Normal)
        playButton.addTarget(self, action: #selector(SongListViewController.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(80, 30))
            make.centerY.equalTo(headerView.snp_centerY)
            make.leftMargin.equalTo(10)
        }
        
        let moreButton = UIButton()
        headerView.addSubview(moreButton)
        moreButton.titleLabel?.font = UIFont.sizeOf12()
        moreButton.backgroundColor = UIColor.grayColor3()
        moreButton.clipsToBounds = true
        moreButton.layer.cornerRadius = 15
        moreButton.setTitle("More", forState: .Normal)
        moreButton.addTarget(self, action: #selector(SongListViewController.moreButtonPressed(_:)), forControlEvents: .TouchUpInside)
        moreButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(60, 30))
            make.centerY.equalTo(headerView.snp_centerY)
            make.right.equalTo(headerView.snp_right).offset(-12)
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
        return 54
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        TrackManager.playMusicTypeEvent(.SongListCell)
        
        let song = dataSource[indexPath.row]
        MusicManager.sharedManager.appendSongToPlaylist(song, autoPlay: true)
        
        presentViewController(PlayerViewController.playerController, animated: true, completion: nil)
    }
    
    func playButtonPressed(button: UIButton) {
        if dataSource.count > 0 {
            MusicManager.sharedManager.appendSongsToPlaylist(dataSource, autoPlay: true)
            Device.keyWindow().topMostController()!.presentViewController(PlayerViewController.playerController, animated: true, completion: nil)
            
            TrackManager.playMusicTypeEvent(.SongList)
        }
    }
    
    func moreButtonPressed(button: UIButton) {
        let alertController = UIAlertController()
        let action1 = UIAlertAction(title: "全部加入播放列表", style: .Default, handler: { (action) in
            debugPrint("add to playlist")
            MusicManager.sharedManager.appendSongsToPlaylist(self.dataSource, autoPlay: false)
        })
        let action2 = UIAlertAction(title: "收藏全部歌曲", style: .Default, handler: { (action) in
            debugPrint("add to collecte")
        })
        let action3 = UIAlertAction(title: "下载全部歌曲", style: .Default, handler: { (action) in
            debugPrint("download music")
            CoreDB.addSongsToDownloadingList(self.dataSource)
        })
//        let action4 = UIAlertAction(title: "和好友分享", style: .Default, handler: {[weak self] (action) in
//            debugPrint("sharing")
//            let social  = SocialController(shareTitle: (self?.program.programName)!, shareText: (self?.program.programDesc)!, shareImage: (self?.coverImageView.image)!, shareUrl: DOMAIN)
//            social.shareAudio = false
//            self?.navigationController!.presentViewController(social, animated: true, completion: nil)
//        })
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
//        alertController.addAction(action4)
        alertController.addAction(cancelAction)
        
        navigationController!.presentViewController(alertController, animated: true, completion: nil)
    }
}

extension SongListViewController: SongListTableViewCellDelegate {
    func openToolPanelOfSong(song: Song) {
        
        let alertController = UIAlertController()
        let action1 = UIAlertAction(title: "加入播放列表", style: .Default, handler: { (action) in
            MusicManager.sharedManager.appendSongToPlaylist(song, autoPlay: false)
        })
        let action2 = UIAlertAction(title: "收藏歌曲", style: .Default, handler: { (action) in
            debugPrint("add to collecte")
        })
        let action3 = UIAlertAction(title: "下载歌曲", style: .Default, handler: { (action) in
            CoreDB.addSongToDownloadingList(song)
        })
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(cancelAction)
        
        navigationController!.presentViewController(alertController, animated: true, completion: nil)
    }
}

