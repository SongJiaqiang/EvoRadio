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
        updateContentView()
        
        updateDownloadCount()

        NotificationManager.instance.addDownloadASongFinishedObserver(self, action: #selector(DownloadViewController.downloadASongFinished(_:)))

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PlayerView.instance.hide()
        
        AssistiveTouch.sharedTouch.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        AssistiveTouch.sharedTouch.addTarget(self, action: #selector(DownloadViewController.goBack), forControlEvents: .TouchUpInside)
        AssistiveTouch.sharedTouch.updateImage(UIImage(named: "touch_back")!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        PlayerView.instance.show()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: prepare ui
    func prepareSegmentControl() {
        
        topView = UIView()
        view.addSubview(topView)
        topView.snp_makeConstraints { (make) in
            make.height.equalTo(40)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top).offset(30)
        }
        
        segmentedControl = UISegmentedControl(items: [" 已下载 ", " 下载中 "])
        topView.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(DownloadViewController.segmentedCotnrolValueChanged(_:)), forControlEvents: .ValueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = UIColor.whiteColor()
        segmentedControl.snp_makeConstraints { (make) in
//            make.size.equalTo(CGSizeMake(120, 28))
            make.center.equalTo(topView.snp_center)
        }
        
        listButton = UIButton()
        topView.addSubview(listButton)
        listButton.setImage(UIImage(named: "list_singleline"), forState: .Normal)
        listButton.addTarget(self, action: #selector(DownloadViewController.listButtonPressed(_:)), forControlEvents: .TouchUpInside)
        listButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 40))
            make.right.equalTo(topView.snp_right).offset(-10)
            make.centerY.equalTo(topView.snp_centerY)
        }
    }
    
    func updateContentView() {
        
        if containerView == nil {
            containerView = UIView()
            view.addSubview(containerView)
            containerView.snp_makeConstraints { (make) in
                make.top.equalTo(topView.snp_bottom)
                make.left.equalTo(view.snp_left)
                make.right.equalTo(view.snp_right)
                make.bottom.equalTo(view.snp_bottom)
            }
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if downloadedController == nil {
                downloadedController = DownloadedViewController()
            }
            addChildController(downloadedController!, toView: containerView)
            if let _ = downloadingController {
                downloadingController?.view.removeFromSuperview()
                downloadingController?.removeFromParentViewController()
            }
        }else {
            if downloadingController == nil {
                downloadingController = DownloadingSongListViewController()
            }
            addChildController(downloadingController!, toView: containerView)
            if let _ = downloadedController {
                downloadedController?.view.removeFromSuperview()
                downloadedController?.removeFromParentViewController()
            }
        }
    }

    func updateDownloadCount() {
        if let songs = CoreDB.getDownloadedSongs() {
            segmentedControl.setTitle("已下载(\(songs.count))", forSegmentAtIndex: 0)
        }
        
        if let songs = CoreDB.getDownloadingSongs() {
            segmentedControl.setTitle("下载中(\(songs.count))", forSegmentAtIndex: 1)
        }
    }
    
    
    //MARK: events
    func segmentedCotnrolValueChanged(segment: UISegmentedControl) {
        
        listButton.hidden = segment.selectedSegmentIndex == 1 ? true : false
        
        updateContentView()
    }
    
    func listButtonPressed(button: UIButton) {
        button.selected = !button.selected
        
        let icon = button.selected ? UIImage(named: "list_grid") : UIImage(named: "list_singleline")
        button.setImage(icon, forState: .Normal)
        
        downloadedController?.selectedIndex = button.selected ? 1 : 0
        downloadedController?.updateContentView()
    }
    
    func downloadASongFinished(noti: NSNotification) {
        updateDownloadCount()
    }
    

}
