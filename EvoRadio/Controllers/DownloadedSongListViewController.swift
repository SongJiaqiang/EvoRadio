//
//  DownloadedSongListViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadedSongListViewController: ViewController {

    let cellID = "downloadedSongsCell"
    
    var tableView: UITableView!
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
    
    //MARK: prepare ui
    func prepareTableView() {
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints({(make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        })
        
        tableView.register(DownloadedTableViewCell.self, forCellReuseIdentifier: cellID)

    }
    
    func loadDataSource() {
        if let songs = CoreDB.getDownloadedSongs() {
            dataSource.removeAll()
            dataSource.append(contentsOf: songs)
            tableView.reloadData()
        }
    }

    //MARK: events 
    func downloadASongFinished(_ noti: Notification) {
        loadDataSource()
        
        NotificationCenter.default.post(name: .updateDownloadCount, object: nil)
    }

}
extension DownloadedSongListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! DownloadedTableViewCell
        cell.delegate = self
        
        let song = dataSource[(indexPath as NSIndexPath).row]

        cell.updateMusicInfo(song, atIndex: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,y: 0,width: tableView.bounds.width,height: 40))
        headerView.backgroundColor = UIColor.grayColor1C()
        
        let leftButton = UIButton()
        headerView.addSubview(leftButton)
        leftButton.titleLabel?.font = UIFont.size12()
        leftButton.backgroundColor = UIColor.grayColor1C()
        leftButton.setTitle("Play All", for: UIControlState())
        leftButton.addTarget(self, action: #selector(DownloadedSongListViewController.leftButtonPressed), for: .touchUpInside)

        let rightButton = UIButton()
        headerView.addSubview(rightButton)
        rightButton.titleLabel?.font = UIFont.size12()
        rightButton.backgroundColor = UIColor.grayColor1C()
        rightButton.setTitle("Delete All", for: UIControlState())
        rightButton.addTarget(self, action: #selector(DownloadedSongListViewController.rightButtonPressed), for: .touchUpInside)
        
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
        separatorView.backgroundColor = UIColor.grayColor41()
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
        
        let song = dataSource[(indexPath as NSIndexPath).row]
        MusicManager.shared.appendSongToPlaylist(song, autoPlay: true)
        
        present(PlayerViewController.mainController, animated: true, completion: nil)
    }
    
    func playButtonPressed(_ button: UIButton) {
        if let songs = CoreDB.getDownloadedSongs() {
            MusicManager.shared.clearList()
            MusicManager.shared.appendSongsToPlaylist(songs, autoPlay: true)
            Device.keyWindow().topMostController()!.present(PlayerViewController.mainController, animated: true, completion: nil)
            
        }
    }
    
    func leftButtonPressed() {
        print("Play all downloaded musics")
        
        if dataSource.count > 0 {
            MusicManager.shared.appendSongsToPlaylist(dataSource, autoPlay: true)
            Device.keyWindow().topMostController()!.present(PlayerViewController.mainController, animated: true, completion: nil)
            
        }
    }
    
    func rightButtonPressed() {
        self.showDestructiveAlert(title: "⚠️危险操作", message: "确定删除所有正在已下载的歌曲吗？", DestructiveTitle: "确定") { (action) in
            self.dataSource.removeAll()
            self.tableView.reloadDataOnMainQueue(after: {
                CoreDB.removeAllDownloadedSongs()
            })
            
            NotificationCenter.default.post(name: .updateDownloadCount, object: nil)
        }
    }

}

extension DownloadedSongListViewController: SongListTableViewCellDelegate {
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
