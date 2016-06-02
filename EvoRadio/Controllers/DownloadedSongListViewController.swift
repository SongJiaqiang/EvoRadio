//
//  DownloadedSongListViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 6/1/16.
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let song = dataSource[indexPath.row]
        MusicManager.sharedManager.appendSongToPlaylist(song, autoPlay: true)
        
        NotificationManager.instance.postUpdatePlayerControllerNotification()
        presentViewController(playerControler, animated: true, completion: nil)
    }

}

extension DownloadedSongListViewController: SongListTableViewCellDelegate {
    func openToolPanelOfSong(song: Song) {
        
        let alertController = UIAlertController()
        let action1 = UIAlertAction(title: "加入播放列表", style: .Default, handler: { (action) in
            print("add to playlist")
            MusicManager.sharedManager.appendSongToPlaylist(song, autoPlay: false)
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
