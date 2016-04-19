//
//  ProgramViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class ProgramViewController: UITableViewController {
    let cellID = "programCellID"
    
    var channel: Channel!
    var dataSource = [Program]()
    
    convenience init(channel: Channel) {
        self.init()
        
        self.channel = channel
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = channel.channelName
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        listChannelPrograms()
    }
    
    func listChannelPrograms() {
        let channelID = channel.channelID!
        
        api.fetch_programs(channelID, page: Page(index: 0, size: 20), onSuccess: {[weak self] (responseData) in
            
            if responseData.count > 0 {
                
                let newData = Program.programsWithDict(responseData)
                
                self?.dataSource.appendContentsOf(newData)
                
                self?.tableView.reloadData()
            }else {
                print("没有更多数据了")
            }
            
            
            }, onFailed: nil)
        
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)

        let program = dataSource[indexPath.row]
        
        cell?.textLabel?.text = program.programName
        cell?.detailTextLabel?.text = program.programDesc
        cell?.imageView?.kf_setImageWithURL(NSURL(string: program.picURL!)!, placeholderImage: UIImage.placeholder_cover())
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let program = dataSource[indexPath.row]
        let player = PlayerViewController(program: program)
        presentViewController(player, animated: true, completion: nil)
        
    }

}
