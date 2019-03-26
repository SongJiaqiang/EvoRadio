//
//  ScannerViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 2019/3/23.
//  Copyright © 2019 JQTech. All rights reserved.
//

import UIKit
// 指定硬盘
//let baseURL = URL(fileURLWithPath: "/Volumes/JQHD/", isDirectory: true)
let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let rootURL = baseURL.appendingPathComponent("evo")

class ScannerViewController: ViewController {
    
    let cellID = "scanning_cell"
    
    var tableView: UITableView!
    let consoleView = UIView()
    
    var dataSource = [ScanItem]()
    
    var currentRadios: [Radio]?
    var currentChannels: [Channel]?
    var currentPrograms: [Program]?
    var currentSongs: [Song]?
    var currentItem: ScanItem?
    
    var radioIndex: Int = 0
    var channelIndex: Int = 0
    var programIndex: Int = 0
    var songIndex: Int = 0
    var itemIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareConsoleView()
        prepareTableView()
        
        loadDataSource()
        
        NotificationManager.shared.addDownloadASongFinishedObserver(self, action: #selector(DownloadedSongListViewController.downloadASongFinished(_:)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AssistiveTouch.shared.removeTarget(nil, action: nil, for: .allTouchEvents)
        AssistiveTouch.shared.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        AssistiveTouch.shared.updateImage(UIImage(named: "touch_back")!)
    }
    
    override func goBack() {
        if let item = currentItem, let type = item.type {
            let newType = (type.rawValue - 1) < 0 ? 0 : (type.rawValue - 1)
            switch ScanType(rawValue: newType) {
            case .radio?:
                if let radios = currentRadios {
                    self.dataSource.removeAll()
                    let items = radios.map{ (radio) -> ScanItem in
                        return ScanItem(type: .radio, id: "\(radio.radioId!)", name: radio.radioName!, desc: nil)
                    }
                    self.dataSource.append(contentsOf: items)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    itemIndex = radioIndex
                    let radio = radios[radioIndex]
                    currentItem = ScanItem(type: .radio, id: "\(radio.radioId!)", name: radio.radioName!, desc: nil)
                }
            case .channel?:
                if let channels = currentChannels {
                    self.dataSource.removeAll()
                    let items = channels.map{ (channel) -> ScanItem in
                        return ScanItem(type: .channel, id: "\(channel.channelId!)", name: channel.channelName!, desc: nil)
                    }
                    self.dataSource.append(contentsOf: items)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    itemIndex = channelIndex
                    let channel = channels[channelIndex]
                    currentItem = ScanItem(type: .channel, id: channel.channelId!, name: channel.channelName!, desc: nil)
                }
            case .program?:
                if let programs = currentPrograms {
                    self.dataSource.removeAll()
                    let items = programs.map{ (program) -> ScanItem in
                        return ScanItem(type: .program, id: "\(program.programId!)", name: program.programName!, desc: nil)
                    }
                    self.dataSource.append(contentsOf: items)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    itemIndex = programIndex
                    let program = programs[programIndex]
                    currentItem = ScanItem(type: .program, id: program.programId!, name: program.programName!, desc: nil)
                }
            default:
                break
                
                
            }
            
            
        }
    }
    
    func prepareConsoleView() {
        view.addSubview(consoleView)
        consoleView.snp.makeConstraints { (make) in
            make.height.equalTo(120)
            make.top.equalTo(view.snp.top).offset(20)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        func logLabel() -> UILabel {
            let label = UILabel()
            label.textColor = UIColor.grayColorBF()
            label.font = UIFont.systemFont(ofSize: 10)
            return label
        }
        
        let radioLabel = logLabel()
        radioLabel.text = "电台："
        consoleView.addSubview(radioLabel)
        radioLabel.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.topMargin.equalTo(0)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
        
        let channelLabel = logLabel()
        channelLabel.text = "频道："
        consoleView.addSubview(channelLabel)
        channelLabel.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.top.equalTo(radioLabel.snp.bottom)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
        
        let programLabel = logLabel()
        programLabel.text = "歌单："
        consoleView.addSubview(programLabel)
        programLabel.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.top.equalTo(channelLabel.snp.bottom)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
        
        let songLabel = logLabel()
        songLabel.text = "歌曲："
        consoleView.addSubview(songLabel)
        songLabel.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.top.equalTo(programLabel.snp.bottom)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
        
        let progressView = UIProgressView()
        progressView.progress = 0
        consoleView.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.bottom.equalTo(consoleView.snp.bottom)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
        
    }
    
    //MARK: prepare ui
    func prepareTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: playerBarHeight, right: 0)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints({(make) in
            make.top.equalTo(consoleView.snp.bottom)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            make.bottomMargin.equalTo(0)
        })
        
        tableView.register(ScannerTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    
    //MARK: events
    @objc func downloadASongFinished(_ noti: Notification) {
        loadDataSource()
        
        NotificationCenter.default.post(name: .updateDownloadCount, object: nil)
    }
    
    //MARK: - fetch data
    func loadDataSource() {
        api.fetch_all_channels({[weak self] (radios) in
            self?.currentRadios = radios

            self?.dataSource.removeAll()
            let items = radios.map{ (radio) -> ScanItem in
                return ScanItem(type: .radio, id: "\(radio.radioId!)", name: radio.radioName!, desc: nil)
            }
            self?.dataSource.append(contentsOf: items)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }, onFailed: nil)
        
    }
    
    
}
extension ScannerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! ScannerTableViewCell
        cell.delegate = self
        
        let item = dataSource[indexPath.row]
        cell.updateItem(item, atIndex: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = dataSource[indexPath.row]
        
        switch item.type {
        case .radio?:
            if let radios = currentRadios {
                for radio in radios {
                    if let radioId = radio.radioId, "\(radioId)" == item.id {
                        currentChannels = radio.channels
                    }
                }
            }
            
            if let channels = currentChannels {
                self.dataSource.removeAll()
                let items = channels.map{ (channel) -> ScanItem in
                    return ScanItem(type: .channel, id: channel.channelId!, name: channel.channelName!, desc: nil)
                }
                self.dataSource.append(contentsOf: items)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            break
        case .channel?:
            api.fetch_programs(item.id!, page: Page(index: 0,size: 500), onSuccess: {[weak self] (programs) in
                self?.currentPrograms = programs
                
                self?.dataSource.removeAll()
                let items = programs.map{ (program) -> ScanItem in
                    return ScanItem(type: .program, id: program.programId!, name: program.programName!, desc: nil)
                }
                self?.dataSource.append(contentsOf: items)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            }, onFailed: nil)
            
            break
        case .program?:
            api.fetch_songs(item.id!, isVIP: true, onSuccess: {[weak self] (songs) in
                self?.currentSongs = songs
                
                self?.dataSource.removeAll()
                let items = songs.map{ (song) -> ScanItem in
                    return ScanItem(type: .song, id: song.songId!, name: song.songName!, desc: nil)
                }
                self?.dataSource.append(contentsOf: items)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            }, onFailed: nil)
            break
        case .song?:
            
            break
        default:
            break
        }
        
        currentItem = item
        itemIndex = indexPath.row
    }
    
    func playButtonPressed(_ button: UIButton) {
        if let songs = CoreDB.getDownloadedSongs() {
            MusicManager.shared.clearList()
            MusicManager.shared.appendSongsToPlaylist(songs, autoPlay: true)
            Device.keyWindow().topMostController()!.present(PlayerViewController.mainController, animated: true, completion: nil)
            
        }
    }
    
//    @objc func leftButtonPressed() {
//        print("Play all downloaded musics")
//
//        if dataSource.count > 0 {
//            MusicManager.shared.appendSongsToPlaylist(dataSource, autoPlay: true)
//            Device.keyWindow().topMostController()!.present(PlayerViewController.mainController, animated: true, completion: nil)
//
//        }
//    }
//
//    @objc func rightButtonPressed() {
//        self.showDestructiveAlert(title: "⚠️危险操作", message: "确定删除所有正在已下载的歌曲吗？", DestructiveTitle: "确定") { (action) in
//            self.dataSource.removeAll()
//            self.tableView.reloadDataOnMainQueue(after: {
//                CoreDB.removeAllDownloadedSongs()
//            })
//
//            NotificationCenter.default.post(name: .updateDownloadCount, object: nil)
//        }
//    }
    
}

extension ScannerViewController: SongListTableViewCellDelegate {
    func openToolPanelOfSong(_ song: Song) {
        
        let alertController = UIAlertController()
        let action1 = UIAlertAction(title: "加入播放列表", style: .default, handler: { (action) in
            MusicManager.shared.appendSongToPlaylist(song, autoPlay: false)
        })
        let action2 = UIAlertAction(title: "收藏歌曲", style: .default, handler: { (action) in
            debugPrint("add to collecte")
        })
        let action3 = UIAlertAction(title: "删除", style: .destructive, handler: { (action) in
            debugPrint("delete music file")
            
            CoreDB.removeSongFromDownloadedList(song)
            self.loadDataSource()
            self.tableView.reloadData()
            
            NotificationCenter.default.post(name: .updateDownloadCount, object: nil, userInfo: nil)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(cancelAction)
        
        navigationController!.present(alertController, animated: true, completion: nil)
    }
}


enum ScanType: Int {
    case radio = 0
    case channel = 1
    case program = 2
    case song = 3
}

class ScanItem {
    var type: ScanType?
    var id: String?
    var name: String?
    var desc: String?
    
    init(type:ScanType, id:String, name:String, desc:String?) {
        self.type = type
        self.id = id
        self.name = name
        self.desc = desc
    }
}
