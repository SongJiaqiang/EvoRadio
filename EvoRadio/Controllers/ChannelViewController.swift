//
//  ChannelViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import MJRefresh


class ChannelViewController: UIViewController {

    let cellID = "cellID"
    
    var dataSource = [Channel]()
    var radioID: Int = 0
    let tableView = UITableView()
    
    // init with radioID, if now, pass 0
    convenience init(radioID: Int) {
        self.init()
        
        self.radioID = radioID
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareTableView()
        
//        tableView.mj_header.beginRefreshing()
    }
    
    
    func prepareTableView() {
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ChannelViewController.tableHeaderRefresh))
    }
    
    func tableHeaderRefresh() {
        
        if radioID == 0 {
            listAllNowChannels()
        }else {
            listAllChannels()
        }

    }
    
    func listAllChannels() {
        api.fetch_all_channels({[weak self] (responseData) in
            
            let radios = Radio.radiosWithDict(responseData)
            for radio in radios {
                if radio.radioID == self?.radioID {
                    self?.dataSource.removeAll()
                    self?.dataSource.appendContentsOf(radio.channels!)
                    break
                }
            }
            self?.tableView.reloadData()
            self?.tableView.mj_header.endRefreshing()
            }, onFailed: nil)
    }
    
    func listAllNowChannels() {
        
        api.fetch_all_now_channels({[weak self] (responseData) in
            let count = UInt32(responseData.count)
            let random = Int(arc4random_uniform(count))
            let anyList = responseData[random]
            
            self?.dataSource.removeAll()
            self?.dataSource.appendContentsOf(Channel.channelsWithDict(anyList["channels"] as! [[String : AnyObject]]))
            
            self?.tableView.reloadData()
            self?.tableView.mj_header.endRefreshing()
            }, onFailed: nil)
        
    }

}

extension ChannelViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        
        let channel = dataSource[indexPath.row]
        
        cell!.textLabel?.text = channel.channelName
        cell!.detailTextLabel?.text = channel.radioName
        cell!.imageView?.kf_setImageWithURL(NSURL(string: channel.picURL!)!, placeholderImage: UIImage.placeholder_cover())
        
        return cell!
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let channel = dataSource[indexPath.row]
        
        navigationController?.pushViewController(ProgramViewController(channel: channel), animated: true)
        
    }
}


