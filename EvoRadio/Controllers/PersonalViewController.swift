//
//  PersonalViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class PersonalViewController: ViewController {
    
    let cellID = "PersonalCellID"
    
    var dataSource = [
        [
            ["key":"custom", "title":"定制电台"]
        ],
        [
            ["key":"download", "title":"我的下载"],
            ["key":"collection", "title":"我的收藏"],
            ["key":"history", "title":"最近播放"]
        ],
        [
            ["key":"setting", "title":"设置"]
        ]
    ]
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
    }
    
    func prepareTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
    }
    
}


extension PersonalViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = dataSource[section]
        return section.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        cell?.accessoryType = .DisclosureIndicator
        cell?.backgroundColor = UIColor.grayColor3()
        cell?.textLabel?.textColor = UIColor.grayColor7()
        
        let section = dataSource[indexPath.section]
        let item = section[indexPath.row]
        cell?.textLabel?.text = item["title"]

        
        if item["key"] == "custom" {
            cell?.detailTextLabel?.text = "活动、情绪、餐饮"
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let section = dataSource[indexPath.section]
        let item = section[indexPath.row]
        let key:String = item["key"]!
        switch  key {
        case "custom":
            navigationController?.pushViewController(CustomRadioViewController(), animated: true)
            break
        case "download":
            navigationController?.pushViewController(DownloadViewController(), animated: true)
            break
        case "collection":
            navigationController?.pushViewController(DownloadViewController(), animated: true)
            break
        case "history":
            navigationController?.pushViewController(DownloadViewController(), animated: true)
            break
        case "setting":
            navigationController?.pushViewController(SettingViewController(), animated: true)
            break
        default: break
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clearColor()
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}