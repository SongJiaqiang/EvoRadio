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
    
    // singleton
    public static let mainController = DownloadingSongListViewController()
    
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
    var toolBar: UIView!
    var leftButton: UIButton!
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareToolBar()
        
        prepareTableView()
        
        loadDataSource()
        
        NotificationManager.shared.addDownloadingListChangedObserver(self, action: #selector(DownloadingSongListViewController.downloadingListChanged(_:)))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationManager.shared.removeObserver(self)
    }
    
    //MARK: prepare ui
    func prepareToolBar() {
        
        toolBar = UIView()
        view.addSubview(toolBar)
        toolBar.backgroundColor = UIColor.grayColor1C()
        toolBar.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
        }

        leftButton = UIButton()
        toolBar.addSubview(leftButton)
        leftButton.titleLabel?.font = UIFont.size12()
        leftButton.backgroundColor = UIColor.grayColor1C()
        leftButton.setTitle("Pause All", for: UIControl.State())
        leftButton.addTarget(self, action: #selector(DownloadingSongListViewController.leftButtonPressed), for: .touchUpInside)
        
        let rightButton = UIButton()
        toolBar.addSubview(rightButton)
        rightButton.titleLabel?.font = UIFont.size12()
        rightButton.backgroundColor = UIColor.grayColor1C()
        rightButton.setTitle("Clear All", for: .normal)
        rightButton.addTarget(self, action: #selector(DownloadingSongListViewController.rightButtonPressed), for: .touchUpInside)
        
        leftButton.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.centerY.equalTo(toolBar.snp.centerY)
            make.left.equalTo(toolBar.snp.left).offset(12)
            make.right.equalTo(rightButton.snp.left)
            
            make.width.equalTo(rightButton.snp.width)
        }
        
        rightButton.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.centerY.equalTo(toolBar.snp.centerY)
            make.right.equalTo(toolBar.snp.right).offset(-12)
            make.left.equalTo(leftButton.snp.right)
        }
        
        let separatorView = UIView()
        toolBar.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor41()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(toolBar.snp.left)
            make.right.equalTo(toolBar.snp.right)
            make.bottom.equalTo(toolBar.snp.bottom)
        }
        
    }
    
    func prepareTableView() {
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: playerBarHeight, right: 0)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints({(make) in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(toolBar.snp.bottom)
            make.bottom.equalTo(view.snp.bottom)
        })
        
        tableView.register(DownloadingTableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    
    func loadDataSource() {
        if let songs = CoreDB.getDownloadingSongs() {
//            Downloader.downloadingSongs.removeAll()
            for s in songs {
                Downloader.downloadingSongs.append(s)
            }
            tableView.reloadData()
            let _ = checkAllTaskIsPaused()
            autoStartNextTask()
        }
    }
    
    //MARK: events
    @objc func downloadingListChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo {

            let songs = userInfo["songs"] as! [Song]
            for song in songs {
                let donwloadSong = DownloadSongInfo(song: song)
                Downloader.downloadingSongs.append(donwloadSong)
            }
            tableView.reloadData()
            autoStartNextTask()
            
            NotificationCenter.default.post(name: .updateDownloadCount, object: nil)
        }
    }
    
    @objc func leftButtonPressed() {
        
        if Downloader.downloadingSongs.count == 0 {
            return
        }
        
        if checkAllTaskIsPaused() {
            print(">>> Start all download task")
            leftButton.setTitle("Pause All", for: UIControl.State())
            
            for i in 0..<Downloader.downloadingSongs.count {
                let songInfo = Downloader.downloadingSongs[i]
                
                songInfo.status = TaskStatus.gettingInfo.rawValue
                updateCell(songInfo, atIndex: IndexPath(row: i, section: 0))
            }
            
            autoStartNextTask()
        }else {
            print(">>> Pause all download task")
            leftButton.setTitle("Start All", for: UIControl.State())
            
            for i in 0..<Downloader.downloadingSongs.count {
                let songInfo = Downloader.downloadingSongs[i]
                if songInfo.status == TaskStatus.paused.rawValue {
                    continue
                }
                let modelInfo = findDownloadingModel(taskId: (songInfo.song?.audioURL?.lastPathComponent())!)
                if let index = modelInfo.index {
                    downloadManager.pauseDownloadTaskAtIndex(index)
                }
                songInfo.status = TaskStatus.paused.rawValue
                updateCell(songInfo, atIndex: IndexPath(row: i, section: 0))
            }
        }
    }
    
    @objc func rightButtonPressed() {
        self.showDestructiveAlert(title: "⚠️危险操作", message: "确定删除所有正在下载的歌曲吗？", DestructiveTitle: "确定") { (action) in
            
            self.downloadManager.cancelAllTasks()
            self.downloadManager.downloadingArray.removeAll()
            
            Downloader.downloadingSongs.removeAll()
            CoreDB.removeAllDownloadingSongs()
            
            self.tableView.reloadData()
        }
    }
    
    
    
    func checkAllTaskIsPaused() -> Bool {
        
        var isAllTaskPaused = true
        for songInfo in Downloader.downloadingSongs {
            if songInfo.status != TaskStatus.paused.rawValue {
                isAllTaskPaused = false
                break
            }
        }
        
        if isAllTaskPaused {
            leftButton.setTitle("Start All", for: .normal)
        }else {
            leftButton.setTitle("Pause All", for: .normal)
        }
        
        return isAllTaskPaused
    }

    func saveDownloadingList() {
        CoreDB.removeAllDownloadingSongs()
        
        if Downloader.downloadingSongs.count > 0 {
            for songInfo in Downloader.downloadingSongs {
                CoreDB.addSongToDownloadingList(songInfo.song!)
            }
        }
    }
}

//MARK:  UITableViewDelegate, UITableViewDataSource
extension DownloadingSongListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Downloader.downloadingSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! DownloadingTableViewCell
        
        let songInfo = Downloader.downloadingSongs[(indexPath as NSIndexPath).row]
        cell.setupSongInfo(songInfo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedSong = Downloader.downloadingSongs[(indexPath as NSIndexPath).row]
        
        let downloadModelInfo = findDownloadingModel(taskId: (selectedSong.song?.audioURL?.lastPathComponent())!)
        if let index = downloadModelInfo.index {
            let downloadModel = downloadManager.downloadingArray[index]
            if selectedSong.status == TaskStatus.downloading.rawValue || selectedSong.status == TaskStatus.gettingInfo.rawValue {
                // pause task
                downloadManager.pauseDownloadTaskAtIndex(index)
                selectedSong.status = TaskStatus.paused.rawValue
                
            }else if selectedSong.status == TaskStatus.paused.rawValue {
                // resume task
//                downloadManager.resumeDownloadTaskAtIndex(index)
                selectedSong.status = TaskStatus.gettingInfo.rawValue
                downloadModel.status = TaskStatus.gettingInfo.description()
                autoStartNextTask()
                
                updateCell(selectedSong, atIndex: indexPath)
            }else if selectedSong.status == TaskStatus.failed.rawValue {
                // retry task
//                downloadManager.retryDownloadTaskAtIndex(index)
                selectedSong.status = TaskStatus.gettingInfo.rawValue
                downloadModel.status = TaskStatus.gettingInfo.description()
                autoStartNextTask()
                
                updateCell(selectedSong, atIndex: indexPath)
            }
        }else {
            if selectedSong.status == TaskStatus.gettingInfo.rawValue {
                selectedSong.status = TaskStatus.paused.rawValue
                
                updateCell(selectedSong, atIndex: indexPath)
            }else {
                selectedSong.status = TaskStatus.gettingInfo.rawValue
                if Downloader.downloadingTaskCount() < 3 {
                    addTask(s: selectedSong.song!)
                }else {
                    updateCell(selectedSong, atIndex: indexPath)
                }
            }
        }
    }
    
    func updateCell(_ cellModel: DownloadSongInfo, atIndex indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            (cell as! DownloadingTableViewCell).setupSongInfo(cellModel)
        }
    }
    
    func autoStartNextTask() {
        // 只要任务数小于3，添加新的任务。
        // warning: 这里容易出现线程安全问题，可能同时多处调用这个方法，导致重复添加任务
        if Downloader.downloadingTaskCount() < 3 {
            // 下载列表中第一个状态为gettingInfo的任务
            for songInfo in Downloader.downloadingSongs {
                if songInfo.status == TaskStatus.gettingInfo.rawValue {
                    addTask(s: songInfo.song!)
                    break
                }
            }
        }
    }
    
    func addTask(s: Song) {
        let fileName = s.audioURL!.lastPathComponent()
        let downloadPath = MZUtility.baseFilePath.appendPathComponents(["downloads", s.programId!])
        
        self.downloadManager.addDownloadTask(fileName, fileURL: s.audioURL!, destinationPath: downloadPath as String)
        
        print(">>> Add a download task: \(fileName)")
    }
    
    func isDownloading(_ song: Song) -> Bool{
        for item in downloadManager.downloadingArray {
            if item.fileURL == song.audioURL {
                return true
            }
        }
        
        return false
    }
    
}

//MARK: MZDownloadManagerDelegate
extension DownloadingSongListViewController: MZDownloadManagerDelegate {

    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        
        let downloadingSongInfo = findDownloadingSong(downloadModel: downloadModel)
        
        if let row = downloadingSongInfo.row {
            
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) {
                (cell as! DownloadingTableViewCell).updateProgress(downloadModel: downloadModel)
            }
        }
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint(">> Music download finished: \(downloadModel.destinationPath)")
        
        let downloadingSongInfo = findDownloadingSong(downloadModel: downloadModel)
        
        if let row = downloadingSongInfo.row {
            let downloadingSong = Downloader.downloadingSongs[row]
            
            // 添加到已下载列表，并从下载中列表移除
            CoreDB.addSongToDownloadedList(downloadingSong.song!)
            CoreDB.removeSongFromDownloadingList(downloadingSong)

            Downloader.downloadingSongs.remove(at: row)

            tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .bottom)
            
            NotificationManager.shared.postDownloadASongFinishedNotification(["song":downloadingSong])
            
            autoStartNextTask()
        }
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        debugPrint("download task interrupted: \(index)")
        tableView.reloadData()
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int){
        debugPrint("download task error: \(index)")
        updateDownloadStatus(status: .failed, downloadModel: downloadModel)
    }
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download task start: \(index)")
        updateDownloadStatus(status: .downloading, downloadModel: downloadModel)
        autoStartNextTask()
    }
    
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download task paused: \(index)")
        updateDownloadStatus(status: .paused, downloadModel: downloadModel)
        autoStartNextTask()
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download task resumed: \(index)")
        updateDownloadStatus(status: .downloading, downloadModel: downloadModel)
    }
    
    func downloadRequestDidRetry(_ downloadModel: MZDownloadModel, index: Int){
        debugPrint("download task retry: \(index)")
        updateDownloadStatus(status: .downloading, downloadModel: downloadModel)
    }

    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint("download task cancel: \(index)")

    }

    func updateDownloadStatus(status: TaskStatus, downloadModel: MZDownloadModel) {
        
        let downloadingSongInfo = findDownloadingSong(downloadModel: downloadModel)
        
        if let row = downloadingSongInfo.row {
            let downloadingSong = Downloader.downloadingSongs[row]
            downloadingSong.status = status.rawValue
            updateCell(downloadingSong, atIndex: IndexPath(row: row, section: 0))
        }
    }
    
    /**
        @desc 根据下载任务获取下载信息
     
          通过fileName判断model并不可取，应当给MZDownloadModel添加唯一属性。
          由于fileName是唯一的，这里暂时使用这个属性来判断
          warning: // 遍历寻找效率太低
     */
    func findDownloadingSong(downloadModel: MZDownloadModel) -> (downloadingSong: DownloadSongInfo?, row: Int?) {
        var downloadingSong: DownloadSongInfo?
        var row: Int?
        
        for i in 0..<Downloader.downloadingSongs.count {
            downloadingSong = Downloader.downloadingSongs[i]
            if downloadingSong?.song?.audioURL?.lastPathComponent() == downloadModel.fileName {
                row = i
                break;
            }
        }
        return (downloadingSong, row)
    }
    
    /**
         @desc 根据任务标识获取下载任务
     */
    func findDownloadingModel(taskId: String) -> (downloadModel: MZDownloadModel?, index: Int?) {
        var downloadModel: MZDownloadModel?
        var index: Int?
        
        for i in 0..<self.downloadManager.downloadingArray.count {
            downloadModel = downloadManager.downloadingArray[i]
            
            if taskId == downloadModel?.fileName {
                index = i
                break;
            }
        }
        return (downloadModel, index)
    }
    
    
}
