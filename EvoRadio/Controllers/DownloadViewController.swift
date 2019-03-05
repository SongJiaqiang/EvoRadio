//
//  DownloadViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadViewController: ViewController {

    var topView: UIView!
    var containerView: UIView!
    var segmentedControl: UISegmentedControl!
    var listButton: UIButton!
    
    var downloadedController: DownloadedViewController?
    var downloadingController: DownloadingSongListViewController?
    
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSegmentControl()
        updateDownloadCount()
        
        
        
        NotificationManager.shared.addDownloadASongFinishedObserver(self, action: #selector(DownloadViewController.downloadASongFinished(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PlayerView.main.hide()
        
        AssistiveTouch.shared.removeTarget(nil, action: nil, for: .allTouchEvents)
        AssistiveTouch.shared.addTarget(self, action: #selector(DownloadViewController.goBack), for: .touchUpInside)
        AssistiveTouch.shared.updateImage(UIImage(named: "touch_back")!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PlayerView.main.show()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateContentView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: prepare ui
    func prepareSegmentControl() {
        
        topView = UIView()
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top).offset(30)
        }
        
        segmentedControl = UISegmentedControl(items: [" 已下载 ", " 下载中 "])
        topView.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(DownloadViewController.segmentedCotnrolValueChanged(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.white
        segmentedControl.snp.makeConstraints { (make) in
//            make.size.equalTo(CGSizeMake(120, 28))
            make.center.equalTo(topView.snp.center)
        }
        
        listButton = UIButton()
        topView.addSubview(listButton)
        listButton.setImage(UIImage(named: "list_singleline"), for: .normal)
        listButton.addTarget(self, action: #selector(DownloadViewController.listButtonPressed(_:)), for: .touchUpInside)
        listButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.right.equalTo(topView.snp.right).offset(-10)
            make.centerY.equalTo(topView.snp.centerY)
        }
    }
    
    func updateContentView() {
        
        if containerView == nil {
            containerView = UIView()
            view.addSubview(containerView)
            containerView.snp.makeConstraints { (make) in
                make.top.equalTo(topView.snp.bottom)
                make.left.equalTo(view.snp.left)
                make.right.equalTo(view.snp.right)
                make.bottom.equalTo(view.snp.bottom)
            }
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if downloadedController == nil {
                downloadedController = DownloadedViewController()
            }
            addChildController(downloadedController!, toView: containerView)
            if let _ = downloadingController {
                downloadingController?.view.removeFromSuperview()
                downloadingController?.removeFromParent()
            }
        }else {
            if downloadingController == nil {
                downloadingController = DownloadingSongListViewController.mainController
            }
            addChildController(downloadingController!, toView: containerView)
            if let _ = downloadedController {
                downloadedController?.view.removeFromSuperview()
                downloadedController?.removeFromParent()
            }
        }
    }

    func updateDownloadCount() {
        if let songs = CoreDB.getDownloadedSongs() {
            segmentedControl.setTitle("已下载(\(songs.count))", forSegmentAt: 0)
        }
        
        if let songs = CoreDB.getDownloadingSongs() {
            segmentedControl.setTitle("下载中(\(songs.count))", forSegmentAt: 1)
        }
    }
    
    
    //MARK: events
    @objc func segmentedCotnrolValueChanged(_ segment: UISegmentedControl) {
        
        listButton.isHidden = segment.selectedSegmentIndex == 1 ? true : false
        
        updateContentView()
    }
    
    @objc func listButtonPressed(_ button: UIButton) {
        button.isSelected = !button.isSelected
        
        let icon = button.isSelected ? UIImage(named: "list_grid") : UIImage(named: "list_singleline")
        button.setImage(icon, for: .normal)
        
        downloadedController?.selectedIndex = button.isSelected ? 1 : 0
        downloadedController?.updateContentView()
    }
    
    @objc func downloadASongFinished(_ noti: Notification) {
        updateDownloadCount()
        
        NotificationCenter.default.post(name: .updateDownloadCount, object: nil, userInfo: nil)
    }
    

}
