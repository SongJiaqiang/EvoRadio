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
    private var contentView = UIView()
    
    private var nowViewController: ChannelViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Evo Radio"
    
        prepareTabBar()
        preparePlayerBar()
        prepareContentView()
        
        addChildViewController(ChannelViewController(), inView: contentView)
    }
    
    func prepareTabBar() {
        
        sortTabBar = TabBar(titles: ["时刻", "活动", "情绪", "文化", "个人"])
        view.addSubview(sortTabBar)
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
        contentView.clipsToBounds = true
        contentView.snp_makeConstraints { (make) in
            make.top.equalTo(sortTabBar.snp_bottom)
            make.bottom.equalTo(playerBar.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
    }
    
    
}
