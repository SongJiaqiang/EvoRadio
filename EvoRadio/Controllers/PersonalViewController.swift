//
//  PersonalViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class PersonalViewController: ViewController {
    
    let cellID = "PersonalCellID"
    
    var dataSource = [
        [
            ["key":"custom", "title":"定制电台", "icon": "setting_custom"]
        ],
        [
            ["key":"download", "title":"我的下载", "icon": "setting_download"],
//            ["key":"collection", "title":"我的收藏", "icon": "setting_hearts"],
            ["key":"history", "title":"最近播放", "icon": "setting_history"]
        ],
        [
            ["key":"setting", "title":"设置", "icon": "setting_set"]
        ]
    ]
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
    }
    
    func prepareTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
    }
    
}


extension PersonalViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = dataSource[section]
        return section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        cell?.backgroundColor = UIColor.grayColor3()
        cell?.textLabel?.textColor = UIColor.grayColor7()
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.grayColor2()
        cell?.selectedBackgroundView = selectedView
        
        let section = dataSource[(indexPath as NSIndexPath).section]
        let item = section[(indexPath as NSIndexPath).row]
        cell?.textLabel?.text = item["title"]
        cell?.imageView?.image = UIImage(named: item["icon"]!)
        
        if item["key"] == "custom" {
            cell?.detailTextLabel?.text = "活动、情绪、餐饮"
        }
        
        if item["key"] == "clean" {
            cell?.accessoryType = .none
        }else {
            cell?.accessoryType = .disclosureIndicator
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = dataSource[(indexPath as NSIndexPath).section]
        let item = section[(indexPath as NSIndexPath).row]
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
            navigationController?.pushViewController(HistorySongListViewController(), animated: true)
            break
        case "setting":
            navigationController?.pushViewController(SettingViewController(), animated: true)
            break
        case "clean":
            HudManager.showAnnularDeterminate("正在清理...", completion: {
                HudManager.showText("清理完成")
                CoreDB.clearAll()
            })
            break
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}
