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
    fileprivate var playerView: UIView!
    fileprivate var contentView = UIScrollView()
    fileprivate var playerViewTopConstraint: Constraint?
    
    fileprivate var radioController: RadioViewController?
    fileprivate var nowViewController: NowViewController?
    fileprivate var localViewController: LocalViewController?
    fileprivate var playerController = PlayerViewController()
    
    fileprivate var topTabBarHeightConstraint: Constraint!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AssistiveTouch.shared.removeTarget(nil, action: nil, for: .allTouchEvents)
        AssistiveTouch.shared.addTarget(self, action: #selector(MainViewController.showMenu), for: .touchUpInside)

        AssistiveTouch.shared.updateImage(touchIcon != nil ? touchIcon! : UIImage(named: "touch_ring")!)
    }
    
    //MARK: prepare
    func prepareAssistiveTouch() {
        let assitiveTouch = AssistiveTouch.shared
        assitiveTouch.frame = CGRect(x: 10, y: 30, width: 40, height: 40)
        Device.keyWindow().addSubview(assitiveTouch)
    }
    
    func prepareTabBar() {
        
        topTabBar = TopTabBar(titles: ["电台","当下","本地"])
        view.addSubview(topTabBar)
        topTabBar.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
        }
        
    }
    
    func preparePlayerView() {
        
        playerView = UIView()
        playerView.backgroundColor = UIColor.goldColor()
        Device.keyWindow().addSubview(playerView)
        playerView.snp.makeConstraints { (make) in
            make.size.equalTo(Device.size())
            make.leftMargin.equalTo(0)
            make.right.equalTo(0)
            playerViewTopConstraint = make.topMargin.equalTo(Device.height()-barHeight).constraint
        }
        
        
        playerView.addSubview(playerController.view)
        playerController.view.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
//        
//        playerBar = PlayerBar()
//        playerView.addSubview(playerBar)
//        playerBar.delegate = self
//        playerBar.snp.makeConstraints { (make) in
//            make.height.equalTo(barHeight)
//            make.topMargin.equalTo(0)
//            make.leftMargin.equalTo(0)
//            make.rightMargin.equalTo(0)
//        }
    }
    
    func prepareContentView() {        
        view.addSubview(contentView)
        contentView.isPagingEnabled = true
        contentView.showsVerticalScrollIndicator = false
        contentView.showsHorizontalScrollIndicator = false
        contentView.clipsToBounds = true
        contentView.delegate = self
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).offset(20)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        
        contentView.contentSize = CGSize(width: Device.width()*3, height: 0)
        contentView.contentOffset = CGPoint(x: Device.width(), y: 0)
        
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        topTabBar.animationWithOffsetX(offsetX)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        let pageIndex = offsetX.truncatingRemainder(dividingBy: Device.width()) == 0 ? Int(offsetX / Device.width()) : Int(offsetX / Device.width())
        
        if pageIndex == 0 {
            touchIcon = UIImage(named: "touch_refresh")
        } else if pageIndex == 1 {
            touchIcon = UIImage(named: "touch_ring")
        } else if pageIndex == 2 {
            touchIcon = UIImage(named: "touch_sound")
        }
        AssistiveTouch.shared.updateImage(touchIcon!)
        
        topTabBar.currentIndex = pageIndex
        topTabBar.updateFrames()
    }

}

extension MainViewController: ScrollTabBarDelegate {
    func scrollTabBar(_ scrollTabBar: ScrollTabBar, didSelectedItemIndex index: Int) {
        self.contentView.setContentOffset(CGPoint(x: Device.width()*CGFloat(index), y: 0), animated: true)
    }
}

