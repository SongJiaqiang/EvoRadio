//
//  DownloadedSongListViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadedSongListViewController: ViewController {

    let cellID = "downloadedSongsCell"
    
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    var dataSource = [Song]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.yellowColor()
        
        prepareTableView()
        
        loadDataSource()
        
        NotificationManager.instance.addDownloadASongFinishedObserver(self, action: #selector(DownloadedSongListViewController.downloadASongFinished(_:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: prepare ui
    func prepareTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clearColor()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
        tableView.separatorStyle = .None
        tableView.snp_makeConstraints(closure: {(make) in
            make.edges.equalTo(UIEdgeInsetsZero)
        })
        
        tableView.registerClass(SongListTableViewCell.self, forCellReuseIdentifier: cellID)

    }
    
    func loadDataSource() {
        if let songs = CoreDB.getDownloadedSongs() {
            dataSource.removeAll()
            dataSource.appendContentsOf(songs)
            tableView.reloadData()
        }
    }

    //MARK: events 
    func downloadASongFinished(noti: NSNotification) {
        loadDataSource()
    }

}
extension DownloadedSongListViewController: UITableViewDelegate, UITableViewDataSource {
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
        playButton.addTarget(self, action: #selector(DownloadedSongListViewController.playButtonPressed(_:)), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(80, 30))
            make.centerY.equalTo(headerView.snp_centerY)
            make.leftMargin.equalTo(10)
        }
        
        let clearButton = UIButton()
        headerView.addSubview(clearButton)
        clearButton.titleLabel?.font = UIFont.sizeOf12()
        clearButton.backgroundColor = UIColor.grayColor3()
        clearButton.clipsToBounds = true
        clearButton.layer.cornerRadius = 15
        clearButton.setTitle("Clear", forState: .Normal)
        clearButton.addTarget(self, action: #selector(DownloadedSongListViewController.clearButtonPressed(_:)), forControlEvents: .TouchUpInside)
        clearButton.snp_makeConstraints { (make) in
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
        TrackManager.playMusicTypeEvent(.DownloadedSongListCell)
        
        let song = dataSource[indexPath.row]
        MusicManager.sharedManager.appendSongToPlaylist(song, autoPlay: true)
        
        NotificationManager.instance.postUpdatePlayerControllerNotification()
        presentViewController(PlayerViewController.playerController, animated: true, completion: nil)
    }
    
    func playButtonPressed(button: UIButton) {
        if let songs = CoreDB.getDownloadedSongs() {
            MusicManager.sharedManager.clearList()
            MusicManager.sharedManager.appendSongsToPlaylist(songs, autoPlay: true)
            Device.keyWindow().topMostController()!.presentViewController(PlayerViewController.playerController, animated: true, completion: nil)
            
            TrackManager.playMusicTypeEvent(.DownloadedSongList)
        }
    }
    
    func clearButtonPressed(button: UIButton) {
        CoreDB.clearHistory()
        dataSource.removeAll()
        tableView.reloadData()
    }

}

extension DownloadedSongListViewController: SongListTableViewCellDelegate {
    func openToolPanelOfSong(song: Song) {
        
        let alertController = UIAlertController()
        let action1 = UIAlertAction(title: "加入播放列表", style: .Default, handler: { (action) in
            MusicManager.sharedManager.appendSongToPlaylist(song, autoPlay: false)
        })
        let action2 = UIAlertAction(title: "收藏歌曲", style: .Default, handler: { (action) in
            debugPrint("add to collecte")
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(cancelAction)
        
        navigationController!.presentViewController(alertController, animated: true, completion: nil)
    }
}
