//
//  DownloadingSongListViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadingSongListViewController: ViewController {
    
    lazy var downloadManager: MZDownloadManager = {[unowned self] in
        let sessionIdentifer = "cn.songjiaqiang.evoradio.downloader"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let manager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        
        return manager
    }()
    
    
    
    
    
    let cellID = "downloadingSongCellID"
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var dataSource = [Song]()
    var downloadingSongs = [Song]()
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        
        NotificationManager.shared.addDownloadingListChangedObserver(self, action: #selector(DownloadingSongListViewController.downloadingListChanged(_:)))
        
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
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints({(make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        })
        
        tableView.register(DownloadingSongListTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    func loadDataSource() {
        if let songs = CoreDB.getDownloadingSongs() {
            dataSource.removeAll()
            dataSource.append(contentsOf: songs)
            tableView.reloadData()
        }
    }
    
    //MARK: events 
    func downloadingListChanged(_ notification: Notification) {
        if let songs = (notification as NSNotification).userInfo {
            dataSource.removeAll()
            dataSource.append(contentsOf: songs["songs"] as! [Song])
            
            tableView.reloadData()
        }
    }
    
    func refreshCellForIndex(_ downloadModel: MZDownloadModel, index: Int) {
        
    }

}


extension DownloadingSongListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! DownloadingSongListTableViewCell
        
        let song = dataSource[(indexPath as NSIndexPath).row]
        cell.updateSongInfo(song)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.bounds.width,height: 40))
        
        let playButton = UIButton()
        headerView.addSubview(playButton)
        playButton.titleLabel?.font = UIFont.sizeOf12()
        playButton.backgroundColor = UIColor.grayColor3()
        playButton.clipsToBounds = true
        playButton.layer.cornerRadius = 15
        playButton.setTitle("Start All", for: UIControlState())
        playButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 30))
            make.centerY.equalTo(headerView.snp.centerY)
            make.leftMargin.equalTo(12)
        }
        
        let deleteButton = UIButton()
        headerView.addSubview(deleteButton)
        deleteButton.titleLabel?.font = UIFont.sizeOf12()
        deleteButton.backgroundColor = UIColor.grayColor3()
        deleteButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = 15
        deleteButton.setTitle("Delete All", for: UIControlState())
        deleteButton.addTarget(self, action: #selector(DownloadingSongListViewController.deleteButtonPressed), for: .touchUpInside)
        deleteButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 30))
            make.centerY.equalTo(headerView.snp.centerY)
            make.rightMargin.equalTo(-12)
        }
        
        let separatorView = UIView()
        headerView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor6()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(headerView.snp.left)
            make.right.equalTo(headerView.snp.right)
            make.bottom.equalTo(headerView.snp.bottom)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let song = dataSource[(indexPath as NSIndexPath).row]
        
        let cell = tableView.cellForRow(at: indexPath) as! DownloadingSongListTableViewCell
        cell.paused = !cell.paused!
        
        if cell.paused! {
            // pause task
            self.downloadManager.pauseDownloadTaskAtIndex((indexPath as NSIndexPath).row)
        }else {
            if isDownloading(song) {
                // resume task
                self.downloadManager.resumeDownloadTaskAtIndex(self.downloadingSongs.index(of: song)!)
            }else {
                // new task
                let fileName = song.audioURL!.lastPathComponent()
                let downloadPath = MZUtility.baseFilePath.appendPathComponents(["download",song.programID!])
                
                self.downloadManager.addDownloadTask(fileName, fileURL: song.audioURL!, destinationPath: downloadPath as String)
                
                self.downloadingSongs.append(song)
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
    
    func deleteButtonPressed() {
        CoreDB.removeAllFromDownloadingList()
    }
    
}


extension DownloadingSongListViewController: MZDownloadManagerDelegate {

    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("downloading \(downloadModel.progress) - \(downloadModel.downloadedFile?.size)\(downloadModel.downloadedFile?.unit)")
        
        let song = downloadingSongs[index]
        
        let indexOfDatasource = dataSource.index(of: song)!
        let cell = tableView.cellForRow(at: IndexPath(row: indexOfDatasource, section: 0)) as! DownloadingSongListTableViewCell
        cell.updateProgressBar(downloadModel.progress, speed: (received: (downloadModel.downloadedFile?.size)!, total: (downloadModel.file?.size)!))
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        debugPrint("download interrupted")
        tableView.reloadData()
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download finished")
        let song = downloadingSongs[index]
        
        let indexOfDatasource = dataSource.index(of: song)!
        dataSource.remove(at: indexOfDatasource)
        tableView.deleteRows(at: [IndexPath(row: indexOfDatasource, section: 0)], with: .bottom)
        
        downloadingSongs.remove(at: index)
        CoreDB.addSongToDownloadedList(song)
        CoreDB.removeSongFromDownloadingList(song)
        
        NotificationManager.shared.postDownloadASongFinishedNotification(["song":song])
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
