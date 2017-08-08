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
    var dataSources = [Radio]()
    var cellHeight: CGFloat = 0
    
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
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RadioTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
//        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ChannelViewController.headerRefresh))
        
    }
    
    //MARK: loading data
    func listAllChannels() {
        api.fetch_all_channels({[weak self] (radios) in
            
            if radios.count > 0 {
                self?.dataSources = radios
                self?.tableView!.reloadDataOnMainQueue(after: nil)
//                self?.tableView!.mj_header.endRefreshing()
            }
            }, onFailed: nil)
    }

}

extension RadioViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! RadioTableViewCell
        let radio = dataSources[(indexPath as NSIndexPath).section]
        cell.delegate = self
        cell.setupChannels(radio)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.frame = CGRect(x: 0, y: 0, width: Device.width(), height: 30)
        
        let nameLabel = UILabel()
        header.addSubview(nameLabel)
        nameLabel.frame = CGRect(x: 10, y: 10, width: Device.width()-20, height: 20)
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = UIColor.white
        nameLabel.textAlignment = .center
        
        let radio = dataSources[section]
        nameLabel.text = radio.radioName
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return getCellHeight()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var title = "电台"
        if scrollView.contentOffset.y - 30 > 0 {
            let index = Int(scrollView.contentOffset.y - 30) / Int(getCellHeight() + 30 + 0.01)
            if index >= 0 {
                let radio = dataSources[index]
                title = radio.radioName!
            }
        }
        
        TopTabBar.mainBar.updateTitle(title: title, atIndex: 0);
    }

    
    func getCellHeight() -> CGFloat{
        if cellHeight == 0 {
            cellHeight = ((Device.width() - itemMargin * 3) / 2.5) + itemMargin * 2
        }
        return cellHeight
    }
    
}

extension RadioViewController: RadioTableViewCellDelegate {
    func radioTableViewCell(_ cell: RadioTableViewCell, didSelectedItem channel: Channel) {
        navigationController?.pushViewController(ProgramViewController(channel: channel), animated: true)
    }
    
    func radioTableViewCell(_ cell: RadioTableViewCell, showMoreChannelWithRadio radioId: Int) {
        let channelController = ChannelViewController(radioID: radioId)
        navigationController?.pushViewController(channelController, animated: true)
    }
}
