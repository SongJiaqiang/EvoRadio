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
    
    var topTabBar: TopTabBar!
    private var playerView: UIView!
    private var contentView = UIScrollView()
    private var playerViewTopConstraint: Constraint?
    
    private var channel1Controller = ChannelViewController()
    private var radioController = RadioViewController()
    private var nowViewController = NowViewController()
    private var personalController = PersonalViewController()
    private var playerController = PlayerViewController()
    
    private var topTabBarHeightConstraint: Constraint!
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "EvoRadio"
        prepareAssistiveTouch()
        prepareTabBar()
        prepareContentView()
//        preparePlayerView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.customRadiosChanged), name: "CustomRadiosChanged", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AssistiveTouch.sharedTouch.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        AssistiveTouch.sharedTouch.addTarget(self, action: #selector(MainViewController.showMenu), forControlEvents: .TouchUpInside)
    }
    
    //MARK: prepare
    func prepareAssistiveTouch() {
        let assitiveTouch = AssistiveTouch.sharedTouch
        assitiveTouch.frame = CGRectMake(10, 30, 40, 40)
        Device.keyWindow().addSubview(assitiveTouch)
    }
    
    func prepareTabBar() {
        
        topTabBar = TopTabBar(titles: ["电台","当下","本地"])
        view.addSubview(topTabBar)
        topTabBar.backgroundColor = UIColor.blackColor()
        topTabBar.snp_makeConstraints { (make) in
            topTabBarHeightConstraint = make.height.equalTo(20).constraint
            make.top.equalTo(view.snp_top)
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
            make.top.equalTo(topTabBar.snp_bottom)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        
        contentView.contentSize = CGSizeMake(Device.width()*5, 0)
        contentView.contentOffset = CGPointMake(Device.width(), 0)
        
        
        let customRadios = CoreDB.getCustomRadios()
        channel1Controller.radioID = customRadios[0]["radio_id"] as! Int
        addChildViewControllers([radioController, nowViewController, personalController], inView: contentView)
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
    
    func showMenu() {
        print("Show top menu")
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

