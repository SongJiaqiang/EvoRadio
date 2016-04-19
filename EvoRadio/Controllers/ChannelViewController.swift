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

class ChannelViewController: UITableViewController {

    let cellID = "cellID"
    
    var dataSource = [Channel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        listAllNowChannels()
    }
    
    // http://www.lavaradio.com/api/radio.listAllNowChannels.json
    func listAllNowChannels() {
        
        api.fetch_all_now_channels({[weak self] (responseData) in
            
            let count = UInt32(responseData.count)
            
            let random = Int(arc4random_uniform(count))
            
            let anyList = responseData[random]
            
            self?.dataSource = Channel.channelsWithDict(anyList["channels"] as! [[String : AnyObject]])
            
            self?.tableView.reloadData()
            }, onFailed: nil)
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)

        let channel = dataSource[indexPath.row]
        
        cell!.textLabel?.text = channel.channelName
        cell!.detailTextLabel?.text = channel.radioName
        cell!.imageView?.kf_setImageWithURL(NSURL(string: channel.picURL!)!, placeholderImage: UIImage.placeholder_cover())
        
        return cell!
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let channel = dataSource[indexPath.row]
        
        navigationController?.pushViewController(ProgramViewController(channel: channel), animated: true)
        
    }

}
