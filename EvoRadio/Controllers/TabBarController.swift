//
//  TabBarController.swift
//  EvoRadio
//
//  Created by Jarvis on 2020/2/4.
//  Copyright © 2020 JQTech. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    fileprivate let radioController = NavigationController(rootViewController: RadioViewController())
    fileprivate let nowController = NavigationController(rootViewController: NowViewController())
    fileprivate let localController = NavigationController(rootViewController: LocalViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radioController.tabBarItem = UITabBarItem.init(title: "LRRadio", image: UIImage(named: "tabVC_music"), tag: 0)
        nowController.tabBarItem = UITabBarItem.init(title: "Now", image: UIImage(named: "tabVC_recommand"), tag: 1)
        localController.tabBarItem = UITabBarItem.init(title: "Me", image: UIImage(named: "tabVC_mine"), tag: 2)
        
        viewControllers = [radioController, nowController, localController]
        selectedIndex = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 准备播放界面
        preparePlayer()
    }
    
    func preparePlayer() {
        PlayerView.main.prepareUI()
        PlayerViewController.mainController.prepare()
        
        MusicManager.shared.loadLastPlaylist()
    }

}
