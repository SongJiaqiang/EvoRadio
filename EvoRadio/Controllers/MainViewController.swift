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
import PureLayout

class MainViewController: ViewController {
    let barHeight: CGFloat = 50
    
    private let navBar: UIView = UIView();
    private let titleLabel = UILabel()
    private var playerView: UIView!
    private var scrollView = UIScrollView()
    private var playerViewTopConstraint: Constraint?
    
    private var radioController: RadioViewController = RadioViewController()
    private var fmVC: FMViewController = FMViewController()
    private var localController: LocalViewController = LocalViewController()
    private var playerController = PlayerViewController()
    
    private let narBarItems = ["所有音乐", "私人电波", "个人中心"]
    
    var touchIcon: UIImage?
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EvoRadio"
        
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //MARK: prepare
    func prepareUI() {
        prepareNavBar()
        prepareContentView()
        
        //        preparePlayerView()
        
        // 准备播放界面
        //        preparePlayer()
        
    }
    
    func prepareNavBar() {
        navBar.backgroundColor = UIColor.red

        titleLabel.textColor = ThemeColors.textColorDark
        titleLabel.text = "私人电台"
        
        self.view.addSubview(navBar);
        navBar.addSubview(titleLabel);
        
        navBar.autoPinEdge(toSuperviewSafeArea: .top)
        navBar.autoPinEdge(toSuperviewEdge: .left)
        navBar.autoPinEdge(toSuperviewEdge: .right)
        navBar.autoSetDimension(.height, toSize: 60)
        
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
    }
    
    func prepareContentView() {
        self.view.backgroundColor = ThemeColors.bgColorDark;
        
        view.addSubview(scrollView)
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = true
        scrollView.delegate = self
        scrollView.autoPinEdge(toSuperviewEdge: .left)
        scrollView.autoPinEdge(toSuperviewEdge: .right)
        scrollView.autoPinEdge(toSuperviewEdge: .bottom)
        scrollView.autoPinEdge(.top, to: .bottom, of: navBar)
        
        scrollView.contentSize = CGSize(width: Device.width()*3, height: 0)
        scrollView.contentOffset = CGPoint(x: Device.width(), y: 0)
        
        // 初始化子控制器，并添加到ContentView中
        addChildViewControllers([radioController, fmVC, localController], inView: scrollView)
    }
    
    func preparePlayer() {
        PlayerView.main.prepareUI()
        PlayerViewController.mainController.prepare()
        
        MusicManager.shared.loadLastPlaylist()
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
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
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

    
    //MARK: event
    
    @objc func showMenu() {
        print("Show top menu")
    }
    
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        let pageIndex = offsetX.truncatingRemainder(dividingBy: Device.width()) == 0 ? Int(offsetX / Device.width()) : Int(offsetX / Device.width())
        titleLabel.text = narBarItems[pageIndex]
        
        if pageIndex == 0 {
            touchIcon = UIImage(named: "touch_refresh")
        } else if pageIndex == 1 {
            touchIcon = UIImage(named: "touch_ring")
        } else if pageIndex == 2 {
            touchIcon = UIImage(named: "touch_sound")
        }
    }

}

