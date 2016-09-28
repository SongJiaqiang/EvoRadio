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
    
    private var radioController: RadioViewController?
    private var nowViewController: NowViewController?
    private var localViewController: LocalViewController?
    private var playerController = PlayerViewController()
    
    private var topTabBarHeightConstraint: Constraint!
    
    var touchIcon: UIImage?
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "EvoRadio"
        prepareAssistiveTouch()
        prepareTabBar()
        prepareContentView()
//        preparePlayerView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AssistiveTouch.sharedTouch.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        AssistiveTouch.sharedTouch.addTarget(self, action: #selector(MainViewController.showMenu), forControlEvents: .TouchUpInside)

        AssistiveTouch.sharedTouch.updateImage(touchIcon != nil ? touchIcon! : UIImage(named: "touch_ring")!)
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
        topTabBar.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
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
        view.addSubview(contentView)
        contentView.pagingEnabled = true
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.clipsToBounds = true
        contentView.delegate = self
        contentView.snp_makeConstraints { (make) in
            make.top.equalTo(view.snp_top).offset(20)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        
        contentView.contentSize = CGSizeMake(Device.width()*3, 0)
        contentView.contentOffset = CGPointMake(Device.width(), 0)
        
        // 初始化子控制器，并添加到ContentView中
        radioController = RadioViewController()
        nowViewController = NowViewController()
        localViewController = LocalViewController()
        
        addChildViewControllers([radioController!, nowViewController!, localViewController!], inView: contentView)
    }
    
    //MARK: event
    
    func showMenu() {
        print("Show top menu")
    }
    
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        topTabBar.animationWithOffsetX(offsetX)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        let pageIndex = offsetX % Device.width() == 0 ? Int(offsetX / Device.width()) : Int(offsetX / Device.width())
        
        if pageIndex == 0 {
            touchIcon = UIImage(named: "touch_refresh")
        } else if pageIndex == 1 {
            touchIcon = UIImage(named: "touch_ring")
        } else if pageIndex == 2 {
            touchIcon = UIImage(named: "touch_sound")
        }
        AssistiveTouch.sharedTouch.updateImage(touchIcon!)
        
        topTabBar.currentIndex = pageIndex
        topTabBar.updateFrames()
    }

}

extension MainViewController: ScrollTabBarDelegate {
    func scrollTabBar(scrollTabBar: ScrollTabBar, didSelectedItemIndex index: Int) {
        self.contentView.setContentOffset(CGPointMake(Device.width()*CGFloat(index), 0), animated: true)
    }
}

