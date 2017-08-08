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
    var dataSources = [Song]()

    var tableView = UITableView(frame: CGRect.zero, style: .grouped)
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        PlayerView.main.hide()
        AssistiveTouch.shared.removeTarget(nil, action: nil, for: .allTouchEvents)
        AssistiveTouch.shared.addTarget(self, action: #selector(SongListViewController.goBack), for: .touchUpInside)
        AssistiveTouch.shared.updateImage(UIImage(named: "touch_back")!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        PlayerView.main.show()
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
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints({(make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        })
        
        tableView.register(SongListTableViewCell.self, forCellReuseIdentifier: cellID)
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: Device.width(), height: Device.width())
        
        
        headerView.addSubview(coverImageView)
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        if let _ = program {
            coverImageView.kf.setImage(with: URL(string: program.cover!.pics!.first!)!, placeholder: UIImage.placeholder_cover())
        }else {
            coverImageView.image = UIImage.placeholder_cover()
        }
        coverImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        tableView.tableHeaderView = headerView
    }
    
    //MARK: events
    func listProgramSongs() {
        
        if let _ = program {
            let programID = program.programID!
            api.fetch_songs(programID, isVIP: true, onSuccess: {[weak self] (songs) in
                
                if songs.count > 0 {
                    self?.dataSources = songs
//                    PlaylistManager.playlist.saveList(songs)
                    
                    self?.updateCover()
                    self?.tableView.reloadDataOnMainQueue(after: nil)
                }else {
                    debugPrint("This program has no songs")
                }
                
            }, onFailed: nil)
        }
        
    }
    
    func updateCover() {
        if let _ = program {
            coverImageView.kf.setImage(with: URL(string: program.cover!.pics!.first!)!, placeholder: UIImage.placeholder_cover())
        }else {
            coverImageView.image = UIImage.placeholder_cover()
        }
    }
}

extension SongListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! SongListTableViewCell
        cell.delegate = self
        
        let song = dataSources[(indexPath as NSIndexPath).row]
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
        playButton.setTitle("Play All", for: UIControlState())
        playButton.addTarget(self, action: #selector(playButtonPressed(_:)), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
//            make.size.equalTo(CGSize(width: 80, height: 30))
            make.height.equalTo(30)
            make.centerY.equalTo(headerView.snp.centerY)
            make.leftMargin.equalTo(10)
        }
        
        let downloadButton = UIButton()
        headerView.addSubview(downloadButton)
        downloadButton.titleLabel?.font = UIFont.sizeOf12()
        downloadButton.backgroundColor = UIColor.grayColor3()
        downloadButton.clipsToBounds = true
        downloadButton.layer.cornerRadius = 15
        downloadButton.setTitle("Download All", for: UIControlState())
        downloadButton.addTarget(self, action: #selector(downloadButtonPressed(_:)), for: .touchUpInside)
        downloadButton.snp.makeConstraints { (make) in
//            make.size.equalTo(CGSize(width: 60, height: 30))
            make.height.equalTo(30)
            make.centerY.equalTo(headerView.snp.centerY)
            make.right.equalTo(headerView.snp.right).offset(-12)
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
        
        let song = dataSources[(indexPath as NSIndexPath).row]
        MusicManager.shared.appendSongToPlaylist(song, autoPlay: true)
        
        present(PlayerViewController.mainController, animated: true, completion: nil)
    }
    
    func playButtonPressed(_ button: UIButton) {
        if dataSources.count > 0 {
            MusicManager.shared.appendSongsToPlaylist(dataSources, autoPlay: true)
            
            if let topVC = Device.keyWindow().topMostController() {
                topVC.present(PlayerViewController.mainController, animated: true, completion: nil)
            }
        }
    }

    func downloadButtonPressed(_ button: UIButton) {
        CoreDB.addSongsToDownloadingList(self.dataSources)
        
        NotificationManager.shared.postDownloadingListChangedNotification(["songs" : self.dataSources])
    }
}

extension SongListViewController: SongListTableViewCellDelegate {
    func openToolPanelOfSong(_ song: Song) {
        
        let alertController = UIAlertController()
        let action1 = UIAlertAction(title: "加入播放列表", style: .default, handler: { (action) in
            MusicManager.shared.appendSongToPlaylist(song, autoPlay: false)
        })
        let action2 = UIAlertAction(title: "收藏歌曲", style: .default, handler: { (action) in
            debugPrint("add to collecte")
        })
        let action3 = UIAlertAction(title: "下载歌曲", style: .default, handler: { (action) in
            CoreDB.addSongToDownloadingList(song)
            NotificationManager.shared.postDownloadingListChangedNotification(["songs" : [song]])
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(cancelAction)
        
        navigationController!.present(alertController, animated: true, completion: nil)
    }
}

