//
//  DownloadingSongListViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import MZDownloadManager

class DownloadingSongListViewController: ViewController {
    
    lazy var downloadManager: MZDownloadManager = {[unowned self] in
        let sessionIdentifer = "cn.songjiaqiang.evoradio"
        let completion = Device.appDelegate().backgroundSessionCompletionHandler
        
        return MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
    }()
    
    let cellID = "downloadingSongCellID"
    
    let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    var dataSource = [Song]()
    var downloadingSongs = [Song]()
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.redColor()
        
        prepareTableView()
        
        NotificationManager.instance.addDownloadingListChangedObserver(self, action: #selector(DownloadingSongListViewController.downloadingListChanged(_:)))
        
        loadDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationManager.instance.removeObserver(self)
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
            make.edges.equalTo(UIEdgeInsetsMake(64, 0, 0, 0))
        })
        
        tableView.registerClass(DownloadingSongListTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    func loadDataSource() {
        if let songs = CoreDB.getDownloadingSongs() {
            dataSource.removeAll()
            dataSource.appendContentsOf(songs)
            tableView.reloadData()
        }
    }
    
    //MARK: events 
    func downloadingListChanged(notification: NSNotification) {
        if let songs = notification.userInfo {
            dataSource.removeAll()
            dataSource.appendContentsOf(songs["songs"] as! [Song])
            
            tableView.reloadData()
        }
    }
    
    func refreshCellForIndex(downloadModel: MZDownloadModel, index: Int) {
        
    }

}


extension DownloadingSongListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! DownloadingSongListTableViewCell
        
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
        playButton.setTitle("Start All", forState: .Normal)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(80, 30))
            make.centerY.equalTo(headerView.snp_centerY)
            make.leftMargin.equalTo(12)
        }
        
        let deleteButton = UIButton()
        headerView.addSubview(deleteButton)
        deleteButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        deleteButton.backgroundColor = UIColor(white: 0.2, alpha: 1)
        deleteButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = 15
        deleteButton.setTitle("Delete All", forState: .Normal)
        deleteButton.addTarget(self, action: #selector(DownloadingSongListViewController.deleteButtonPressed), forControlEvents: .TouchUpInside)
        deleteButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(80, 30))
            make.centerY.equalTo(headerView.snp_centerY)
            make.rightMargin.equalTo(-12)
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
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DownloadingSongListTableViewCell
        cell.paused = !cell.paused!
        
        if cell.paused! {
            // pause task
            downloadManager.pauseDownloadTaskAtIndex(indexPath.row)
        }else {
            if isDownloading(song) {
                // resume task
                downloadManager.resumeDownloadTaskAtIndex(downloadingSongs.indexOf(song)!)
            }else {
                // new task
                let fileName = song.audioURL!.lastPathComponent()
                let downloadPath = MZUtility.getUniqueFileNameWithPath(MZUtility.baseFilePath.appendPathComponents(["download",song.programID!, fileName]))
                
                downloadManager.addDownloadTask(downloadPath as String, fileURL: song.audioURL!)
                downloadingSongs.append(song)
                
            }
        }
        
        
    }
    
    func isDownloading(song: Song) -> Bool{
        for item in downloadManager.downloadingArray {
            if item.fileURL == song.audioURL {
                return true
            }
        }
        
        return false
    }
    
    func deleteButtonPressed() {
        CoreDB.removeAllFromDownloadingList()
    }
    
}


extension DownloadingSongListViewController: MZDownloadManagerDelegate {
    
    func downloadRequestStarted(downloadModel: MZDownloadModel, index: Int) {
        print("download start")
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(downloadModels: [MZDownloadModel]) {
        print("download interrupted")
        tableView.reloadData()
    }
    
    func downloadRequestDidUpdateProgress(downloadModel: MZDownloadModel, index: Int) {
        print("downloading \(downloadModel.progress)")
        
        let song = downloadingSongs[index]
        
        let indexOfDatasource = dataSource.indexOf(song)!
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexOfDatasource, inSection: 0)) as! DownloadingSongListTableViewCell
        cell.updateProgressBar(downloadModel.progress, speed: (received: (downloadModel.downloadedFile?.size)!, total: (downloadModel.file?.size)!))
    }
    
    func downloadRequestFinished(downloadModel: MZDownloadModel, index: Int) {
        print("download finished")
        let song = downloadingSongs[index]
        
        let indexOfDatasource = dataSource.indexOf(song)!
        dataSource.removeAtIndex(indexOfDatasource)
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexOfDatasource, inSection: 0)], withRowAnimation: .Left)
        
        downloadingSongs.removeAtIndex(index)
        CoreDB.addSongToDownloadedList(song)
        CoreDB.removeSongFromDownloadingList(song)
        
        NotificationManager.instance.postDownloadASongFinishedNotification(["song":song])
    }
    
    func downloadRequestDidPaused(downloadModel: MZDownloadModel, index: Int) {
        print("download paused")
    }
    
    func downloadRequestDidResumed(downloadModel: MZDownloadModel, index: Int) {
        print("download resumed")
    }
    
    
    
}