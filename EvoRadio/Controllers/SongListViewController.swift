//
//  SongListViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 5/29/16.
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
        
        prepareTableView()
        
        if let _ = program {
            title = program.programName
            listProgramSongs()
        }
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
        tableView.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
        tableView.separatorStyle = .None
//        tableView.bounces = false
        tableView.snp_makeConstraints(closure: {(make) in
            make.edges.equalTo(UIEdgeInsetsZero)
//            make.height.equalTo(Device.width())
//            make.top.equalTo(view.snp_top)
//            make.left.equalTo(view.snp_left)
//            make.right.equalTo(view.snp_right)
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
            
            api.fetch_songs(programID, onSuccess: {[weak self] (items) in
                
                if items.count > 0 {
                    let songs = items as! [Song]
                    self?.dataSource = songs
                    PlaylistManager.instance.saveList(songs)
                    
                    self?.updateCover()
                    self?.tableView.reloadData()
                }else {
                    print("This program has no songs")
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
        print("dataSource count: \(dataSource.count)")
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
        playButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        playButton.backgroundColor = UIColor(white: 0.2, alpha: 1)
        playButton.clipsToBounds = true
        playButton.layer.cornerRadius = 15
        playButton.setTitle("Play All", forState: .Normal)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(80, 30))
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 1. download file
        let song = dataSource[indexPath.row]
        playerControler.song = song
        NotificationManager.instance.postUpdatePlayerControllerNotification()
        presentViewController(playerControler, animated: true, completion: nil)
    }
}

extension SongListViewController: SongListTableViewCellDelegate {
    func openToolPanelOfSong(song: Song) {
        
        let alertController = UIAlertController()
        let action1 = UIAlertAction(title: "加入播放列表", style: .Default, handler: { (action) in
            print("add to playlist")
            MusicManager.sharedManager.appendSongToPlaylist(song)
        })
        let action2 = UIAlertAction(title: "加入收藏列表", style: .Default, handler: { (action) in
            print("add to collecte")
        })
        let action3 = UIAlertAction(title: "下载歌曲", style: .Default, handler: { (action) in
            print("download music")
        })
        let action4 = UIAlertAction(title: "和好友分享", style: .Default, handler: { (action) in
            print("sharing")
        })
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(action4)
        alertController.addAction(cancelAction)
        
        navigationController!.presentViewController(alertController, animated: true, completion: nil)
    }
}
