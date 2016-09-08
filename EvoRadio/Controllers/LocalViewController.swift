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
        ["key":"recently", "title": "最近播放", "icon":"setting_history", "count":"12 🎵"],
        ["key":"favorite", "title": "歌单收藏", "icon":"setting_hearts", "count":"3 💿"],
        ["key":"download", "title": "音乐下载", "icon":"player_download", "count":"21/32 🎵"],
        ["key":"import", "title": "音乐导入", "icon":"setting_download", "count":"121 🎵"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareTableView()
        prepareSearchBar()
        
        prepareSoundRecognizerView()
        
    }
    
    //MARK: prepare
    func prepareTableView() {
        
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(LocalTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.contentInset = UIEdgeInsetsMake(60, 0, 50, 0)
        tableView.separatorStyle  = .None
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
    }
    
    
    func prepareSearchBar() {
        let searchBar = UIButton()
        view.addSubview(searchBar)
        searchBar.clipsToBounds = true
        searchBar.layer.cornerRadius = 6
        searchBar.layer.borderWidth = 2
        searchBar.layer.borderColor = UIColor.grayColor().CGColor
        searchBar.backgroundColor = UIColor.blackColor()
        searchBar.alpha = 0.8
        searchBar.snp_makeConstraints { (make) in
            make.height.equalTo(40)
            make.top.equalTo(view.snp_top).offset(10)
            make.left.equalTo(view.snp_left).offset(60)
            make.right.equalTo(view.snp_right).offset(-10)
        }
        searchBar.contentHorizontalAlignment = .Left
        searchBar.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        searchBar.titleLabel?.font = UIFont.systemFontOfSize(14)
        searchBar.setTitleColor(UIColor(netHex:0xDDDDDD), forState: .Normal)
        searchBar.setTitle("输入歌单名、歌曲名", forState: .Normal)
        
    }
    
    func prepareSoundRecognizerView() {
        
    }
    
    

}

extension LocalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! LocalTableViewCell
        let cellInfo = dataSource[indexPath.row]
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cellInfo = dataSource[indexPath.row]
        if let key = cellInfo["key"] {
            
            switch key {
            case "recently":
                navigationController?.pushViewController(HistorySongListViewController(), animated: true)
                break
            case "favorite":
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