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
    private var pageIndicator: PageIndicator?
    private let titleLabel = UILabel()
    private var playerView: UIView!
    private var scrollView = UIScrollView()
    private var playerViewTopConstraint: Constraint?
    
    private var radioController: RadioViewController = RadioViewController()
    private var fmVC: FMViewController = FMViewController()
    private var localController: LocalViewController = LocalViewController()
    private var playerController = PlayerViewController()
    
    private let narBarItems = ["私人电波", "所有音乐", "个人中心"]
    
    var touchIcon: UIImage?
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EvoRadio"
        
        prepareUI()
        
        selectedPage(atIndex: 0)
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
        //TODO: 添加阴影
        navBar.backgroundColor = ThemeColors.bgColorDark
        navBar.layer.shadowColor = UIColor.red.cgColor
        navBar.layer.shadowOffset = CGSize(width: 10, height: 10);
        navBar.layer.shadowRadius = 10
        
        titleLabel.textColor = ThemeColors.textColorDark
        titleLabel.font = UIFont.boldSize22()
        
        let indicatorItemHeight: CGFloat = 4
        let indicatorItemCount: Int = 3
        let pageIndicator = PageIndicator(itemCount: indicatorItemCount, itemHeight: indicatorItemHeight)
        
        self.view.addSubview(navBar)
        navBar.addSubview(titleLabel)
        navBar.addSubview(pageIndicator)
        
        // layout
        navBar.autoPinEdge(toSuperviewSafeArea: .top)
        navBar.autoPinEdge(toSuperviewEdge: .left)
        navBar.autoPinEdge(toSuperviewEdge: .right)
        navBar.autoSetDimension(.height, toSize: 60)
        
        titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        pageIndicator.autoPinEdge(.left, to: .left, of: titleLabel)
        pageIndicator.autoPinEdge(toSuperviewEdge: .bottom)
        pageIndicator.autoSetDimension(.height, toSize: indicatorItemHeight)
        pageIndicator.autoSetDimension(.width, toSize: indicatorItemHeight * CGFloat(2 + indicatorItemCount * 2))
        
        self.pageIndicator = pageIndicator
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
//        scrollView.contentOffset = CGPoint(x: Device.width(), y: 0)
        
        // 初始化子控制器，并添加到ContentView中
        addChildViewControllers([fmVC, radioController, localController], inView: scrollView)
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
    
    func selectedPage(atIndex index: Int) {
        titleLabel.text = narBarItems[index]
        if index == 0 {
            touchIcon = UIImage(named: "touch_refresh")
        } else if index == 1 {
            touchIcon = UIImage(named: "touch_ring")
        } else if index == 2 {
            touchIcon = UIImage(named: "touch_sound")
        }
        
        pageIndicator?.selectItem(atIndex: index, animated: true)
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetX = scrollView.contentOffset.x
        
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        
        let pageIndex = offsetX.truncatingRemainder(dividingBy: Device.width()) == 0 ? Int(offsetX / Device.width()) : Int(offsetX / Device.width())
        
        selectedPage(atIndex: pageIndex)
    }

}


/// 分页指示器
/// 设置itemCount个子元素，每个子元素默认宽高为itemHeight，元素之间间隔同为itemHeight，当前选中的元素宽度为4*itemHeight，
/// 假设有n个元素，则PageIndicator的size是(itemHeight * 4 + itemHeight * (n-1) + itemHeight * (n-1), itemHeight)，
/// 简化为size = (itemHeight * (2 + 2n), itemHeight)
class PageIndicator: UIView {
    private var itemViews: [UIView] = []
    
    var itemCount: Int = 3
    var itemHeight: CGFloat = 4 // 单个子视图的高度
    var normalColor: UIColor = UIColor.green
    var hightlightedColor: UIColor = UIColor.darkGray
    
    var selectedIndex: Int = 0
    
    init(itemCount: Int, itemHeight: CGFloat) {
        self.init()
        
        self.itemCount = itemCount
        self.itemHeight = itemHeight
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareUI()
        selectItem(atIndex: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareUI() {
        itemViews.removeAll()
        
        var maxX: CGFloat = 0
        let itemWidth: CGFloat = itemHeight
        let itemSpacing: CGFloat = itemHeight
        for _ in 0..<itemCount {
            let itemView = createItemView(radius: itemHeight / 2.0, bgColor: normalColor)
            self.addSubview(itemView)
            itemView.frame = CGRect(x: maxX, y: 0, width: itemWidth, height: itemHeight)
            
            itemViews.append(itemView)
            maxX = maxX + (itemWidth + itemSpacing)
        }
        
    }
    
    func createItemView(radius: CGFloat, bgColor: UIColor) -> UIView {
        let itemView = UIView()
        itemView.backgroundColor = bgColor
        itemView.layer.cornerRadius = radius
        itemView.backgroundColor = bgColor
        
        return itemView
    }
    
    func selectItem(atIndex index: Int, animated: Bool = false) {
        selectedIndex = index
        
        var maxX: CGFloat = 0
        var itemWidth: CGFloat = itemHeight
        let itemSpacing: CGFloat = itemHeight
        
        for i in 0..<itemViews.count {
            itemWidth = i == index ? itemHeight * 4 : itemHeight
            
            let itemView = itemViews[i]
            if animated {
                UIView.animate(withDuration: 0.5) {
                    itemView.frame = CGRect(x: maxX, y: 0, width: itemWidth, height: self.itemHeight)
                }
            } else {
                itemView.frame = CGRect(x: maxX, y: 0, width: itemWidth, height: itemHeight)
            }
            
            maxX = maxX + (itemWidth + itemSpacing)
        }
        
    }
    
}
