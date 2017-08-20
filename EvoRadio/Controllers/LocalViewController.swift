//
//  LocalViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 9/7/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class LocalViewController: ViewController {

    let cellID = "LocalTableViewCell"
    
    var tableView: UITableView!
    var dataSource = [
        ["key":"download", "title": "下载音乐", "icon":"local_download", "count":"0 / 0 首"],
        ["key":"import", "title": "导入音乐", "icon":"local_import", "count":"0 首"],
        ["key":"itunes", "title": "iTunes音乐", "icon":"local_itunes", "count":"0 首"],
        ["key":"recently", "title": "最近播放的音乐", "icon":"local_history", "count":"0 首"],
        ["key":"favorites", "title": "我喜欢的音乐", "icon":"local_favorites", "count":"0 首"],
        ["key":"collect", "title": "我收藏的歌单", "icon":"local_collect", "count":"0 张"],
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareTableView()
        prepareSearchBar()
        
        prepareSoundRecognizerView()
        
        
        updateDownloadCount()
    }
    
    //MARK: prepare
    func prepareTableView() {
        
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocalTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsetsMake(60, 0, playerBarHeight, 0)
        tableView.separatorStyle  = .none
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
    }
    
    
    func prepareSearchBar() {
        let searchBar = UIButton()
        view.addSubview(searchBar)
        searchBar.clipsToBounds = true
        searchBar.layer.cornerRadius = 6
        searchBar.layer.borderWidth = 2
        searchBar.layer.borderColor = UIColor.gray.cgColor
        searchBar.backgroundColor = UIColor.black
        searchBar.alpha = 0.8
        searchBar.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.top.equalTo(view.snp.top).offset(10)
            make.left.equalTo(view.snp.left).offset(60)
            make.right.equalTo(view.snp.right).offset(-10)
        }
        searchBar.contentHorizontalAlignment = .left
        searchBar.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        searchBar.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        searchBar.setTitleColor(UIColor(netHex:0xDDDDDD), for: UIControlState())
        searchBar.setTitle("输入歌单名、歌曲名", for: UIControlState())
        
    }
    
    func prepareSoundRecognizerView() {
        
    }
    
    func updateDownloadCount() {
        var downloadedSongsCount = 0
        var downloadingSongsCount = 0
        
        if let songs = CoreDB.getDownloadedSongs() {
            downloadedSongsCount = songs.count
        }
        if let songs = CoreDB.getDownloadingSongs() {
            downloadingSongsCount = songs.count
        }
        
        for i in 0..<dataSource.count {
            var item = dataSource[i]
            if item["key"] == "download" {
                item["count"] = "\(downloadedSongsCount) / \(downloadingSongsCount) 首"
                dataSource.remove(at: i)
                dataSource.insert(item, at: i);
                tableView.reloadData()
                break
            }
        }
    }
    

}

extension LocalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! LocalTableViewCell
        let cellInfo = dataSource[(indexPath as NSIndexPath).row]
        cell.setupData(cellInfo)
        
        return cell
    }
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = UIView()
//        header.frame = CGRectMake(0, 0, Device.width(), 30)
//        
//        let nameLabel = UILabel()
//        header.addSubview(nameLabel)
//        nameLabel.frame = CGRectMake(10, 10, Device.width()-20, 20)
//        nameLabel.font = UIFont.systemFontOfSize(14)
//        nameLabel.textColor = UIColor.whiteColor()
//        
//        let radio = dataSource[section]
//        nameLabel.text = radio.radioName
//        
//        return header
//    }
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.01
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellInfo = dataSource[indexPath.row]
        if let key = cellInfo["key"] {
            
            switch key {
            case "recently":
                navigationController?.pushViewController(HistorySongListViewController(), animated: true)
                break
            case "favorites":
                navigationController?.pushViewController(DownloadViewController(), animated: true)
                break
            case "download":
                navigationController?.pushViewController(DownloadViewController(), animated: true)
                break
            case "import":
                navigationController?.pushViewController(DownloadViewController(), animated: true)
                break
            default:
                break
            }
        }
    }
    
}
