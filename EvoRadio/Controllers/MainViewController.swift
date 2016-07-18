//
//  MainViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/15.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class MainViewController: ViewController {
    let barHeight: CGFloat = 50
    
    private var sortTabBar: TabBar!
    private var playerView: UIView!
    private var contentView = UIScrollView()
    private var playerViewTopConstraint: Constraint?
    
    private var nowViewController = ChannelViewController(radioID: 0)
    private var personalController = PersonalViewController()
    private var channel1Controller = ChannelViewController()
    private var channel2Controller = ChannelViewController()
    private var channel3Controller = ChannelViewController()
    private var playerController = PlayerViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "EvoRadio"
    
        prepareTabBar()
        prepareContentView()
//        preparePlayerView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.customRadiosChanged), name: "CustomRadiosChanged", object: nil)
    }
    
    func prepareTabBar() {
        let customRadios = CoreDB.getCustomRadios()
//        customRadios.filter({$key == "name"})
        var titles = ["时刻"]
        for item in customRadios {
            titles.append(item["radio_name"] as! String)
        }
        titles.append("我的")
        sortTabBar = TabBar(titles: titles)
        view.addSubview(sortTabBar)
        sortTabBar.delegate = self
        sortTabBar.snp_makeConstraints { (make) in
            make.height.equalTo(34)
            make.top.equalTo(view.snp_top).inset(64)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
    }
    
    func preparePlayerView() {
        
        playerView = UIView()
        playerView.backgroundColor = UIColor.goldColor()
        Device.keyWindow().addSubview(playerView)
        playerView.snp_makeConstraints { (make) in
            make.size.equalTo(Device.size())
            make.leftMargin.equalTo(0)
            make.right.equalTo(0)
            playerViewTopConstraint = make.topMargin.equalTo(Device.height()-barHeight).constraint
        }
        
        
        playerView.addSubview(playerController.view)
        playerController.view.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
//        
//        playerBar = PlayerBar()
//        playerView.addSubview(playerBar)
//        playerBar.delegate = self
//        playerBar.snp_makeConstraints { (make) in
//            make.height.equalTo(barHeight)
//            make.topMargin.equalTo(0)
//            make.leftMargin.equalTo(0)
//            make.rightMargin.equalTo(0)
//        }
    }
    
    func prepareContentView() {
//        contentView.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(contentView)
        contentView.pagingEnabled = true
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.clipsToBounds = true
        contentView.delegate = self
        contentView.snp_makeConstraints { (make) in
            make.top.equalTo(sortTabBar.snp_bottom)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        
        contentView.contentSize = CGSizeMake(Device.width()*5, 0)
        
        
        let customRadios = CoreDB.getCustomRadios()
        channel1Controller.radioID = customRadios[0]["radio_id"] as! Int
        channel2Controller.radioID = customRadios[1]["radio_id"] as! Int
        channel3Controller.radioID = customRadios[2]["radio_id"] as! Int
        addChildViewControllers([nowViewController, channel1Controller, channel2Controller,channel3Controller,personalController], inView: contentView)
        
    }
    
    //MARK: event
    func customRadiosChanged(notification: NSNotification) {
        let customRadios = CoreDB.getCustomRadios()
        channel1Controller.radioID = customRadios[0]["radio_id"] as! Int
        channel2Controller.radioID = customRadios[1]["radio_id"] as! Int
        channel3Controller.radioID = customRadios[2]["radio_id"] as! Int
        
        var titles = ["时刻"]
        for item in customRadios {
            titles.append(item["radio_name"] as! String)
        }
        titles.append("我的")
        sortTabBar.updateTitles(titles)
        
        channel1Controller.updateChannels()
        channel2Controller.updateChannels()
        channel3Controller.updateChannels()
    }
    
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        self.sortTabBar.updateLineConstraint(offsetX*0.2)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        let pageIndex = offsetX % Device.width() == 0 ? Int(offsetX / Device.width()) : Int(offsetX / Device.width()) + 1
        
        sortTabBar.updateCurrentIndex(max(min(pageIndex, 4), 0))
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetX = scrollView.contentOffset.x        
        if offsetX < -80 {
            let panel = SelectiveTimePanel(frame: Device.keyWindow().bounds)
            Device.keyWindow().addSubview(panel)
        }
    }
}

extension MainViewController: TabBarDelegate {
    func tabBarSelectedItemAtIndex(index: Int) {
        self.contentView.setContentOffset(CGPointMake(Device.width()*CGFloat(index), 0), animated: true)
    }
}

