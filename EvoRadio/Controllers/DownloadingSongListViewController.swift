//
//  DownloadingSongListViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

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
    var downloadingSongs = [DownloadSongInfo]()
    
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
            DownloadSongInfo.downloadSongs.removeAll()
            
            for s in songs {
                let downloadMusic = DownloadSongInfo(s)
                DownloadSongInfo.downloadSongs.append(downloadMusic)
            }
            tableView.reloadData()
        }
    }
    
    //MARK: events
    func downloadingListChanged(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            DownloadSongInfo.downloadSongs.removeAll()
            let songs = userInfo["song"] as! [Song]
            for s in songs {
                let donwloadSong = DownloadSongInfo(s)
                DownloadSongInfo.downloadSongs.append(donwloadSong)
            }
            tableView.reloadData()
        }
    }
    
    func refreshCellForIndex(_ downloadModel: MZDownloadModel, index: Int) {
        
    }

}


extension DownloadingSongListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DownloadSongInfo.downloadSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! DownloadingTableViewCell
        
        let song = DownloadSongInfo.downloadSongs[(indexPath as NSIndexPath).row]
        cell.setupSongInfo(song)
        
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
        let downloadSong = DownloadSongInfo.downloadSongs[(indexPath as NSIndexPath).row]
        
        let cell = tableView.cellForRow(at: indexPath) as! DownloadingTableViewCell
        cell.paused = !cell.paused!
        
        if cell.paused! {
            // pause task
            self.downloadManager.pauseDownloadTaskAtIndex((indexPath as NSIndexPath).row)
        }else {
            if isDownloading(downloadSong.song) {
                // resume task
                self.downloadManager.resumeDownloadTaskAtIndex(self.downloadingSongs.index(of: downloadSong)!)
            }else {
                // new task
                let fileName = downloadSong.song.audioURL!.lastPathComponent()
                let downloadPath = MZUtility.baseFilePath.appendPathComponents(["downloads",downloadSong.song.programID!])
                
                self.downloadManager.addDownloadTask(fileName, fileURL: downloadSong.song.audioURL!, destinationPath: downloadPath as String)
                
                self.downloadingSongs.append(downloadSong)
            }
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
        CoreDB.removeAllFromDownloadingList()
    }

    
}


extension DownloadingSongListViewController: MZDownloadManagerDelegate {

    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
//        debugPrint("downloading \(downloadModel.progress) - \(downloadModel.downloadedFile?.size)\(downloadModel.downloadedFile?.unit)")
        
        let song = downloadingSongs[index]
        
        let indexOfDatasource = DownloadSongInfo.downloadSongs.index(of: song)!
        let cell = tableView.cellForRow(at: IndexPath(row: indexOfDatasource, section: 0)) as! DownloadingTableViewCell
//        cell.updateProgressBar(downloadModel.progress, speed: (received: (downloadModel.downloadedFile?.size)!, total: (downloadModel.file?.size)!))
        
        cell.updateProgress(downloadModel: downloadModel)
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        debugPrint("download interrupted")
        tableView.reloadData()
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint(">> Music download finished: \(downloadModel.destinationPath)")
        
        let downloadSong = downloadingSongs[index]
        
        let indexOfDatasource = DownloadSongInfo.downloadSongs.index(of: downloadSong)!
        DownloadSongInfo.downloadSongs.remove(at: indexOfDatasource)
        tableView.deleteRows(at: [IndexPath(row: indexOfDatasource, section: 0)], with: .bottom)
        
        downloadingSongs.remove(at: index)
        CoreDB.addSongToDownloadedList(downloadSong.song)
        CoreDB.removeSongFromDownloadingList(downloadSong.song)
        
//        NotificationManager.shared.postDownloadASongFinishedNotification(["song":downloadSong.song])
        
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int){
        debugPrint("download error")
    }
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download start")
    }
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download paused")
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download resumed")
    }
    func downloadRequestDidRetry(_ downloadModel: MZDownloadModel, index: Int){
        debugPrint("download retry")
    }

    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download cancel")
    }

    
    
}
