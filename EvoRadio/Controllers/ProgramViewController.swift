//
//  ProgramViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import MJRefresh

class ProgramViewController: UIViewController {
    let cellID = "programCellID"
    
    var channel: Channel!
    var dataSource = [Program]()
    private var tableView = UITableView()
    private var endOfFeed = false
    private let pageSize: Int = 10
    
    convenience init(channel: Channel) {
        self.init()
        
        self.channel = channel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = channel.channelName
        
        prepareTableView()
        
        tableView.mj_header.beginRefreshing()
    }
    
    
    func prepareTableView() {
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ProgramViewController.tableHeaderRefresh))
        
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(ProgramViewController.tableFooterRefresh))
        
        
    }
    
    func tableHeaderRefresh() {
        listChannelPrograms(true)
    }
    
    func tableFooterRefresh() {
        if endOfFeed {
            tableView.mj_footer.endRefreshing()
        }else {
            listChannelPrograms(false)
        }
    }
    
    func listChannelPrograms(isRefresh: Bool) {
        let channelID = channel.channelID!
        
        var pageIndex = dataSource.count
        if isRefresh {
            pageIndex = 0
        }
        
        api.fetch_programs(channelID, page: Page(index: pageIndex, size: pageSize), onSuccess: {[weak self] (responseData) in
            
            if responseData.count > 0 {
                let newData = Program.programsWithDict(responseData)
                
                if isRefresh {
                    self?.dataSource.removeAll()
                }
                
                self?.dataSource.appendContentsOf(newData)
                
                self?.tableView.reloadData()
                self?.endRefreshing()
            }else {
                self?.endOfFeed = true
                self?.endRefreshing()
                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            
            }, onFailed: nil)
    }
    
    func endRefreshing() {
        if tableView.mj_header.isRefreshing() {
            tableView.mj_header.endRefreshing()
        }
        
        if tableView.mj_footer.isRefreshing() {
            tableView.mj_footer.endRefreshing()
        }
        
    }

}


// MARK: - Table view data source
extension ProgramViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        
        let program = dataSource[indexPath.row]
        
        cell?.textLabel?.text = program.programName
        cell?.detailTextLabel?.text = program.programDesc
        cell?.imageView?.kf_setImageWithURL(NSURL(string: program.picURL!)!, placeholderImage: UIImage.placeholder_cover())
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let program = dataSource[indexPath.row]
        let player = PlayerViewController(program: program)
        presentViewController(player, animated: true, completion: nil)
        
    }
}