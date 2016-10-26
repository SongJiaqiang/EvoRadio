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
    var dataSource = [Song]()

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
        PlayerView.main.hide()
        AssistiveTouch.shared.removeTarget(nil, action: nil, for: .allTouchEvents)
        AssistiveTouch.shared.addTarget(self, action: #selector(SongListViewController.goBack), for: .touchUpInside)
        AssistiveTouch.shared.updateImage(UIImage(named: "touch_back")!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PlayerView.main.show()
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
            api.fetch_songs(programID, isVIP: true, onSuccess: {[weak self] (items) in
                
                if items.count > 0 {
                    let songs = items as! [Song]
                    self?.dataSource = songs
                    PlaylistManager.playlist.saveList(songs)
                    
                    self?.updateCover()
                    self?.tableView.reloadData()
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
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! SongListTableViewCell
        cell.delegate = self
        
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
        playButton.setTitle("Play All", for: UIControlState())
        playButton.addTarget(self, action: #selector(SongListViewController.playButtonPressed(_:)), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 30))
            make.centerY.equalTo(headerView.snp.centerY)
            make.leftMargin.equalTo(10)
        }
        
        let moreButton = UIButton()
        headerView.addSubview(moreButton)
        moreButton.titleLabel?.font = UIFont.sizeOf12()
        moreButton.backgroundColor = UIColor.grayColor3()
        moreButton.clipsToBounds = true
        moreButton.layer.cornerRadius = 15
        moreButton.setTitle("More", for: UIControlState())
        moreButton.addTarget(self, action: #selector(SongListViewController.moreButtonPressed(_:)), for: .touchUpInside)
        moreButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 60, height: 30))
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
        TrackManager.playMusicTypeEvent(.SongListCell)
        
        let song = dataSource[(indexPath as NSIndexPath).row]
        MusicManager.shared.appendSongToPlaylist(song, autoPlay: true)
        
        present(PlayerViewController.mainController, animated: true, completion: nil)
    }
    
    func playButtonPressed(_ button: UIButton) {
        if dataSource.count > 0 {
            MusicManager.shared.appendSongsToPlaylist(dataSource, autoPlay: true)
            Device.keyWindow().topMostController()!.present(PlayerViewController.mainController, animated: true, completion: nil)
            
            TrackManager.playMusicTypeEvent(.SongList)
        }
    }
    
    func moreButtonPressed(_ button: UIButton) {
        let alertController = UIAlertController()
        let action1 = UIAlertAction(title: "全部加入播放列表", style: .default, handler: { (action) in
            debugPrint("add to playlist")
            MusicManager.shared.appendSongsToPlaylist(self.dataSource, autoPlay: false)
        })
        let action2 = UIAlertAction(title: "收藏全部歌曲", style: .default, handler: { (action) in
            debugPrint("add to collecte")
        })
        let action3 = UIAlertAction(title: "下载全部歌曲", style: .default, handler: { (action) in
            debugPrint("download music")
            CoreDB.addSongsToDownloadingList(self.dataSource)
        })
//        let action4 = UIAlertAction(title: "和好友分享", style: .Default, handler: {[weak self] (action) in
//            debugPrint("sharing")
//            let social  = SocialController(shareTitle: (self?.program.programName)!, shareText: (self?.program.programDesc)!, shareImage: (self?.coverImageView.image)!, shareUrl: DOMAIN)
//            social.shareAudio = false
//            self?.navigationController!.presentViewController(social, animated: true, completion: nil)
//        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
//        alertController.addAction(action4)
        alertController.addAction(cancelAction)
        
        navigationController!.present(alertController, animated: true, completion: nil)
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
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(cancelAction)
        
        navigationController!.present(alertController, animated: true, completion: nil)
    }
}

