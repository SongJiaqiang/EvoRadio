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
    
    var topTabBar: UIView!
    private var playerView: UIView!
    private var contentView = UIScrollView()
    private var playerViewTopConstraint: Constraint?
    
    private var channel1Controller = ChannelViewController()
    private var nowViewController = NowViewController()
    private var personalController = PersonalViewController()
    private var playerController = PlayerViewController()
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "EvoRadio"
    
        prepareTabBar()
        prepareContentView()
//        preparePlayerView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.customRadiosChanged), name: "CustomRadiosChanged", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    //MARK: prepare
    func prepareTabBar() {
        
        topTabBar = UIView()
        view.addSubview(topTabBar)
        topTabBar.backgroundColor = UIColor.blackColor()
        topTabBar.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.top.equalTo(view.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        let label0 = UILabel()
        topTabBar.addSubview(label0)
        label0.textColor = UIColor.whiteColor()
        label0.font = UIFont.systemFontOfSize(10)
        label0.text = "电台"
        label0.snp_makeConstraints { (make) in
            make.left.equalTo(topTabBar.snp_left).offset(2)
            make.bottom.equalTo(topTabBar.snp_bottom).offset(-2)
        }
        
        let label1 = UILabel()
        topTabBar.addSubview(label1)
        label1.textColor = UIColor.whiteColor()
        label1.font = UIFont.systemFontOfSize(10)
        label1.text = "首页"
        label1.snp_makeConstraints { (make) in
            make.centerX.equalTo(topTabBar.snp_centerX)
            make.bottom.equalTo(topTabBar.snp_bottom).offset(-2)
        }
        
        let label2 = UILabel()
        topTabBar.addSubview(label2)
        label2.textColor = UIColor.whiteColor()
        label2.font = UIFont.systemFontOfSize(10)
        label2.text = "本地"
        label2.snp_makeConstraints { (make) in
            make.right.equalTo(topTabBar.snp_right).offset(-2)
            make.bottom.equalTo(topTabBar.snp_bottom).offset(-2)
        }
        
        let topLine = UIView()
        view.addSubview(topLine)
        topLine.backgroundColor = UIColor.redColor()
        topLine.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 2))
            make.centerX.equalTo(view.snp_centerX)
            make.top.equalTo(view.snp_top)
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
            make.top.equalTo(topTabBar.snp_bottom)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        
        contentView.contentSize = CGSizeMake(Device.width()*5, 0)
        
        
        let customRadios = CoreDB.getCustomRadios()
        channel1Controller.radioID = customRadios[0]["radio_id"] as! Int
        addChildViewControllers([nowViewController, channel1Controller, personalController], inView: contentView)
        
    }
    
    //MARK: event
    func customRadiosChanged(notification: NSNotification) {
        let customRadios = CoreDB.getCustomRadios()
        channel1Controller.radioID = customRadios[0]["radio_id"] as! Int
        
        var titles = ["时刻"]
        for item in customRadios {
            titles.append(item["radio_name"] as! String)
        }
        titles.append("我的")
//        sortTabBar.updateTitles(titles)
        
        channel1Controller.updateChannels()
    }
    
}

extension MainViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let offsetX = scrollView.contentOffset.x
//        
////        self.sortTabBar.updateLineConstraint(offsetX*0.2)
//    }
//    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        let offsetX = scrollView.contentOffset.x
//        
//        let pageIndex = offsetX % Device.width() == 0 ? Int(offsetX / Device.width()) : Int(offsetX / Device.width()) + 1
//        
////        sortTabBar.updateCurrentIndex(max(min(pageIndex, 4), 0))
//    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetX = scrollView.contentOffset.x        
        if offsetX < -80 {
            let panel = SelectiveTimePanel(frame: Device.keyWindow().bounds)
            Device.keyWindow().addSubview(panel)
        }
    }
}

extension MainViewController: ScrollTabBarDelegate {
    func scrollTabBar(scrollTabBar: ScrollTabBar, didSelectedItemIndex index: Int) {
        self.contentView.setContentOffset(CGPointMake(Device.width()*CGFloat(index), 0), animated: true)
    }
}

