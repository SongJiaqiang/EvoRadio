//
//  DownloadingSongListViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import MBProgressHUD

class DownloadingSongListViewController: ViewController {
    
    // 初始化下载管理器
    lazy var downloadManager: MZDownloadManager = {[unowned self] in
        let sessionIdentifer = "cn.songjiaqiang.evoradio.downloader"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let manager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        
        return manager
    }()
    
    let cellID = "downloadingSongCellID"
    var tableView: UITableView!
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        
//        NotificationManager.shared.addDownloadingListChangedObserver(self, action: #selector(DownloadingSongListViewController.downloadingListChanged(_:)))
        
        loadDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationManager.shared.removeObserver(self)
    }
    
    //MARK: prepare ui
    func prepareTableView() {
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints({(make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        })
        
        tableView.register(DownloadingTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    func loadDataSource() {
        if let songs = CoreDB.getDownloadingSongs() {
            Downloader.downloadSongs.removeAll()
            
            for s in songs {
                Downloader.downloadSongs.append(s)
            }
            tableView.reloadData()
        }
    }
    
    //MARK: events
    func downloadingListChanged(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            Downloader.downloadSongs.removeAll()
            let songs = userInfo["song"] as! [Song]
            for s in songs {
                let donwloadSong = DownloadSongInfo(s)
                Downloader.downloadSongs.append(donwloadSong)
            }
            tableView.reloadData()
        }
    }
    
    func refreshCellForIndex(_ downloadModel: MZDownloadModel, index: Int) {
        
    }

}


extension DownloadingSongListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Downloader.downloadSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! DownloadingTableViewCell
        
        let songInfo = Downloader.downloadSongs[(indexPath as NSIndexPath).row]
        cell.setupSongInfo(songInfo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.bounds.width,height: 40))
        headerView.backgroundColor = UIColor.grayColor3()
        
        let leftButton = UIButton()
        headerView.addSubview(leftButton)
        leftButton.titleLabel?.font = UIFont.sizeOf12()
        leftButton.backgroundColor = UIColor.grayColor3()
        leftButton.setTitle("Start/Pause All", for: UIControlState())
        leftButton.addTarget(self, action: #selector(DownloadingSongListViewController.leftButtonPressed), for: .touchUpInside)
        
        let rightButton = UIButton()
        headerView.addSubview(rightButton)
        rightButton.titleLabel?.font = UIFont.sizeOf12()
        rightButton.backgroundColor = UIColor.grayColor3()
        rightButton.setTitle("Clear All", for: UIControlState())
        rightButton.addTarget(self, action: #selector(DownloadingSongListViewController.rightButtonPressed), for: .touchUpInside)
        
        leftButton.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.centerY.equalTo(headerView.snp.centerY)
            make.left.equalTo(headerView.snp.left).offset(12)
            make.right.equalTo(rightButton.snp.left)
            
            make.width.equalTo(rightButton.snp.width)
        }
        
        rightButton.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.centerY.equalTo(headerView.snp.centerY)
            make.right.equalTo(headerView.snp.right).offset(-12)
            make.left.equalTo(leftButton.snp.right)
        }
        
        let separatorView = UIView()
        headerView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor5()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(headerView.snp.left)
            make.right.equalTo(headerView.snp.right)
            make.bottom.equalTo(headerView.snp.bottom)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedSong = Downloader.downloadSongs[(indexPath as NSIndexPath).row]
        
        if let index = Downloader.downloadingSongs.index(of: selectedSong) {
            if selectedSong.status?.intValue == TaskStatus.downloading.rawValue {
                // pause task
                downloadManager.pauseDownloadTaskAtIndex(index)
            }else if selectedSong.status?.intValue == TaskStatus.paused.rawValue {
                // resume task
                downloadManager.resumeDownloadTaskAtIndex(index)
            }else if selectedSong.status?.intValue == TaskStatus.failed.rawValue {
                // retry task
                downloadManager.retryDownloadTaskAtIndex(index)
            }
        }else {
            // 先添加到下载中列表，再添加下载任务
            Downloader.downloadingSongs.append(selectedSong)
            
            let fileName = selectedSong.song?.audioURL!.lastPathComponent()
            let downloadPath = MZUtility.baseFilePath.appendPathComponents(["downloads", (selectedSong.song?.programID!)!])
            
            self.downloadManager.addDownloadTask(fileName!, fileURL: (selectedSong.song?.audioURL!)!, destinationPath: downloadPath as String)
            
            print(">>> Add a download task: \(fileName)")
        }

        
    }
    
    func isDownloading(_ song: Song) -> Bool{
        for item in downloadManager.downloadingArray {
            if item.fileURL == song.audioURL {
                return true
            }
        }
        
        return false
    }
    
    func leftButtonPressed() {
        print("Start or pause downloading")
        
    }
    
    func rightButtonPressed() {

        self.showDestructiveAlert(title: "⚠️危险操作", message: "确定删除所有正在下载的歌曲吗？", DestructiveTitle: "确定") {[weak self] (action) in
            
            self?.downloadManager.cancelAllTasks()
            self?.downloadManager.downloadingArray.removeAll()
            
            Downloader.downloadSongs.removeAll()
            self?.tableView.reloadData()
            
            CoreDB.removeAllDownloadingSongs()
        }
        
    }

    
}


extension DownloadingSongListViewController: MZDownloadManagerDelegate {

    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        
        let downloadingSong = Downloader.downloadingSongs[index]
        
        if let row = Downloader.downloadSongs.index(of: downloadingSong) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) {
                
                (cell as! DownloadingTableViewCell).updateProgress(downloadModel: downloadModel)
            }
        }
        
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint(">> Music download finished: \(downloadModel.destinationPath)")
        
        let downloadingSong = Downloader.downloadingSongs[index]
        
        if let row = Downloader.downloadSongs.index(of: downloadingSong) {
            
            // 添加到已下载列表，并从下载中列表移除
            CoreDB.addSongToDownloadedList(downloadingSong.song!)
            CoreDB.removeSongFromDownloadingList(downloadingSong)

            Downloader.downloadSongs.remove(at: row)
            
            Downloader.downloadingSongs.remove(at: index)

            tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .bottom)
            
            
            // NotificationManager.shared.postDownloadASongFinishedNotification(["song":downloadSong.song])
        }
        
        
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        debugPrint("download interrupted")
//        updateDownloadStatus(status: .failed, index: index)
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int){
        debugPrint("download error")
        updateDownloadStatus(status: .failed, index: index)
    }
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download start")
        updateDownloadStatus(status: .downloading, index: index)
    }
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download paused")
        updateDownloadStatus(status: .paused, index: index)
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download resumed")
        updateDownloadStatus(status: .downloading, index: index)
    }
    
    func downloadRequestDidRetry(_ downloadModel: MZDownloadModel, index: Int){
        debugPrint("download retry")
        updateDownloadStatus(status: .downloading, index: index)
    }

    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download cancel")
        Downloader.downloadSongs.remove(at: index)
    }

    func updateDownloadStatus(status: TaskStatus, index: Int) {
        
        let downloadingSong = Downloader.downloadingSongs[index]
        
        downloadingSong.status = status.rawValue as NSNumber?
        
        if let row = Downloader.downloadSongs.index(of: downloadingSong) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) {
                (cell as! DownloadingTableViewCell).setupSongInfo(downloadingSong)
            }
        }
        
    }
    
}
