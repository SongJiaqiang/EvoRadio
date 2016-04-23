//
//  MainViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/15.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import SnapKit


class MainViewController: ViewController {

    private var sortTabBar: TabBar!
    private var playerBar: PlayerBar!
    private var contentView = UIScrollView()
    
    private var nowViewController = ChannelViewController(radioID: 0)
    private var channel1Controller = ChannelViewController(radioID: 1)
    private var channel2Controller = ChannelViewController(radioID: 2)
    private var channel3Controller = ChannelViewController(radioID: 3)
    private var personalController = PersonalViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Evo Radio"
    
        prepareTabBar()
        preparePlayerBar()
        prepareContentView()
        
        addChildViewControllers([nowViewController, channel1Controller, channel2Controller,channel3Controller,personalController], inView: contentView)
    }
    
    func prepareTabBar() {
        
        sortTabBar = TabBar(titles: ["时刻", "活动", "情绪", "文化", "个人"])
        view.addSubview(sortTabBar)
        sortTabBar.delegate = self
        sortTabBar.snp_makeConstraints { (make) in
            make.height.equalTo(34)
            make.top.equalTo(view.snp_top).inset(64)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
    }
    
    func preparePlayerBar() {
        playerBar = PlayerBar()
        view.addSubview(playerBar)
        playerBar.snp_makeConstraints { (make) in
            make.height.equalTo(50)
            make.bottom.equalTo(view.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        
        
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
            make.bottom.equalTo(playerBar.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        contentView.contentSize = CGSizeMake(Device.width()*5, 0)
    }
    
    
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        self.sortTabBar.updateLineConstraint(offsetX*0.2)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        let pageIndex = (offsetX+Device.width()) / Device.width()
        
        
        
    }
}

extension MainViewController: TabBarDelegate {
    func tabBarSelectedItemAtIndex(index: Int) {
        self.contentView.setContentOffset(CGPointMake(Device.width()*CGFloat(index), 0), animated: true)
    }
}

