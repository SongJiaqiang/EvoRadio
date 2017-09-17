//
//  HistorySongListViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/8/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class HistorySongListViewController: ViewController {
    
    let cellID = "historySongsCell"
    
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var dataSource = [Song]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        
        loadDataSource()
        
        NotificationManager.shared.addDownloadASongFinishedObserver(self, action: #selector(DownloadedSongListViewController.downloadASongFinished(_:)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AssistiveTouch.shared.removeTarget(nil, action: nil, for: .allTouchEvents)
        AssistiveTouch.shared.addTarget(self, action: #selector(HistorySongListViewController.goBack), for: .touchUpInside)
        AssistiveTouch.shared.updateImage(UIImage(named: "touch_back")!)
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
            make.edges.equalTo(UIEdgeInsets.zero)
        })
        
        tableView.register(SongListTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    func loadDataSource() {
        if let songs = CoreDB.getHistorySongs() {
            dataSource.removeAll()
            dataSource.append(contentsOf: songs)
            tableView.reloadData()
        }
    }
    
    //MARK: events
    func downloadASongFinished(_ noti: Notification) {
        loadDataSource()
    }
    
}
extension HistorySongListViewController: UITableViewDelegate, UITableViewDataSource {
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
        playButton.titleLabel?.font = UIFont.size12()
        playButton.backgroundColor = UIColor.grayColor1C()
        playButton.clipsToBounds = true
        playButton.layer.cornerRadius = 15
        playButton.setTitle("Play All", for: UIControlState())
        playButton.addTarget(self, action: #selector(HistorySongListViewController.playButtonPressed(_:)), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80, height: 30))
            make.centerY.equalTo(headerView.snp.centerY)
            make.leftMargin.equalTo(10)
        }
        
        let clearButton = UIButton()
        headerView.addSubview(clearButton)
        clearButton.titleLabel?.font = UIFont.size12()
        clearButton.backgroundColor = UIColor.grayColor1C()
        clearButton.clipsToBounds = true
        clearButton.layer.cornerRadius = 15
        clearButton.setTitle("Clear", for: UIControlState())
        clearButton.addTarget(self, action: #selector(HistorySongListViewController.clearButtonPressed(_:)), for: .touchUpInside)
        clearButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 60, height: 30))
            make.centerY.equalTo(headerView.snp.centerY)
            make.right.equalTo(headerView.snp.right).offset(-12)
        }
        
        let separatorView = UIView()
        headerView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor97()
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
        MusicManager.shared.appendSongToPlaylist(song, autoPlay: true)
        
        NotificationManager.shared.postUpdatePlayerNotification()
        present(PlayerViewController.mainController, animated: true, completion: nil)
    }
    
    func playButtonPressed(_ button: UIButton) {
        if let songs = CoreDB.getHistorySongs() {
            MusicManager.shared.clearList()
            MusicManager.shared.appendSongsToPlaylist(songs, autoPlay: true)
            Device.keyWindow().topMostController()!.present(PlayerViewController.mainController, animated: true, completion: nil)
            
        }
    }
    
    func clearButtonPressed(_ button: UIButton) {
        CoreDB.clearHistory()
        dataSource.removeAll()
        tableView.reloadData()
    }
    
}

extension HistorySongListViewController: SongListTableViewCellDelegate {
    func openToolPanelOfSong(_ song: Song) {
        
        let alertController = UIAlertController()
        let action1 = UIAlertAction(title: "加入播放列表", style: .default, handler: { (action) in
            MusicManager.shared.appendSongToPlaylist(song, autoPlay: false)
        })
        let action2 = UIAlertAction(title: "收藏歌曲", style: .default, handler: { (action) in
            debugPrint("add to collecte")
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(cancelAction)
        
        navigationController!.present(alertController, animated: true, completion: nil)
    }
}
