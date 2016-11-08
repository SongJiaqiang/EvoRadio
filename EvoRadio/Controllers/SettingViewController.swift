//
//  SettingViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import MBProgressHUD

class SettingViewController: ViewController {
    
    let cellID = "SettingCellID"
    
    var dataSource = [
        [
            ["key":"clean", "title":"清理缓存", "icon": "setting_clean"]
        ],
        [
            ["key":"feedback", "title":"意见反馈", "icon": "setting_feedback"]
        ],
//        [
//            ["key":"about", "title":"关于", "icon": "setting_about"]
//        ],
        [
            ["key":"version", "title":"版本", "icon": "setting_about"]
        ]
    ]
    
    var tableView = UITableView()
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PlayerView.main.hide()
    }

    deinit {
        PlayerView.main.show()
    }
    
    
    //MARK: prepare UI
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


extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = dataSource[section]
        return section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell != nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
        }
        cell?.backgroundColor = UIColor.grayColor3()
        cell?.textLabel?.textColor = UIColor.grayColor7()
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.grayColor2()
        cell?.selectedBackgroundView = selectedView
        
        let section = dataSource[(indexPath as NSIndexPath).section]
        let item = section[(indexPath as NSIndexPath).row]
        cell?.textLabel?.text = item["title"]
        cell?.imageView?.image = UIImage(named: item["icon"]!)
        
//        if item["key"] == "clean" || item["key"] == "feedback" {
//            cell?.accessoryType = .None
//        }else {
//            cell?.accessoryType = .DisclosureIndicator
//        }
        
        if item["key"] == "version" {
            cell?.detailTextLabel?.text = Device.appVersionString()
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = dataSource[(indexPath as NSIndexPath).section]
        let item = section[(indexPath as NSIndexPath).row]
        let key:String = item["key"]!
        switch  key {
        case "clean":
            HudManager.showAnnularDeterminate("正在清理...", completion: {
                HudManager.showText("清理完成")
                CoreDB.clearAll()
            })
            break
        case "about":
            
            break
        case "version":
            if let requestURL = URL(string: DOMAIN) {
                Device.shareApplication().openURL(requestURL)
            }
            break
        case "feedback":
            print("feedback")
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
    
    func closeFeedbackController() {
        Device.shareApplication().statusBarStyle = .lightContent
        dismiss(animated: true, completion: nil)
    }
    

}
