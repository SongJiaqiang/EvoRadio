//
//  RadioViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 9/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import MJRefresh

class RadioViewController: ViewController {

    let cellID = "radioTableViewCellID"
    
    var tableView: UITableView!
    var dataSource = [Radio]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareTableView()
        
        listAllChannels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: prepare
    func prepareTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(RadioTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
//        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ChannelViewController.headerRefresh))
        
    }
    
    //MARK: loading data
    func listAllChannels() {
        api.fetch_all_channels({[weak self] (radios) in
            
            if radios.count > 0 {
                self?.dataSource = radios
                self?.tableView!.reloadData()
//                self?.tableView!.mj_header.endRefreshing()
            }
            }, onFailed: nil)
    }

}

extension RadioViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! RadioTableViewCell
        let radio = dataSource[indexPath.section]
        cell.delegate = self
        cell.setupChannels(radio)
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.frame = CGRectMake(0, 0, Device.width(), 30)
        
        let nameLabel = UILabel()
        header.addSubview(nameLabel)
        nameLabel.frame = CGRectMake(10, 10, Device.width()-20, 20)
        nameLabel.font = UIFont.systemFontOfSize(14)
        nameLabel.textColor = UIColor.whiteColor()
        
        let radio = dataSource[section]
        nameLabel.text = radio.radioName
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ((Device.width() - itemMargin * 3) / 2.5) + itemMargin * 2
    }
    
}

extension RadioViewController: RadioTableViewCellDelegate {
    func radioTableViewCell(cell: RadioTableViewCell, didSelectedItem channel: Channel) {
        navigationController?.pushViewController(ProgramViewController(channel: channel), animated: true)
    }
    
    func radioTableViewCell(cell: RadioTableViewCell, showMoreChannelWithRadio radioId: Int) {
        let channelController = ChannelViewController(radioID: radioId)
        navigationController?.pushViewController(channelController, animated: true)
    }
}
