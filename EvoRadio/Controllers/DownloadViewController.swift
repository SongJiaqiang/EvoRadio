//
//  DownloadViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadViewController: ViewController {

    var segmentedControl = UISegmentedControl(items: [" 已下载 ", " 下载中 "])
    
    
    var downloadedController: DownloadedViewController?
    var downloadingController: DownloadingSongListViewController?
    
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupBackButton()
        prepareSegmentControl()
        
        updateContentView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PlayerView.instance.hide()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        AssistiveTouch.sharedTouch.removeTarget(nil, action: nil, forControlEvents: .AllTouchEvents)
        AssistiveTouch.sharedTouch.addTarget(self, action: #selector(DownloadViewController.goBack), forControlEvents: .TouchUpInside)
        AssistiveTouch.sharedTouch.updateImage(UIImage(named: "touch_back")!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        PlayerView.instance.show()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: prepare ui
    func prepareSegmentControl() {
        
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: #selector(DownloadViewController.segmentedCotnrolValueChanged(_:)), forControlEvents: .ValueChanged)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    func updateContentView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            if downloadedController == nil {
                downloadedController = DownloadedViewController()
            }
            addChildController(downloadedController!, toView: nil)
            if let _ = downloadingController {
                downloadingController?.view.removeFromSuperview()
                downloadingController?.removeFromParentViewController()
            }
        }else {
            if downloadingController == nil {
                downloadingController = DownloadingSongListViewController()
            }
            addChildController(downloadingController!, toView: nil)
            if let _ = downloadedController {
                downloadedController?.view.removeFromSuperview()
                downloadedController?.removeFromParentViewController()
            }
        }
    }

    
    //MARK: events
    func segmentedCotnrolValueChanged(segment: UISegmentedControl) {
        updateContentView()
    }
    
    
    

}
