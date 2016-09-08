//
//  DownloadedViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadedViewController: ViewController {
    
    let contentView = UIView()
    let item1Button = UIButton()
    let item2Button = UIButton()
    var selectedIndex: Int = 0
    
    var songListController: DownloadedSongListViewController?
    var programListController: DownloadedProgramListViewController?
    
    //MARK: cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateContentView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: prepare ui
    func updateContentView() {
        if selectedIndex == 0 {
            if songListController == nil {
                songListController = DownloadedSongListViewController()
            }
            addChildController(songListController!, toView: view)
            if let _ = programListController {
                programListController?.view.removeFromSuperview()
                programListController?.removeFromParentViewController()
            }
        }else {
            if programListController == nil {
                programListController = DownloadedProgramListViewController()
            }
            addChildController(programListController!, toView: view)
            if let _ = songListController {
                songListController?.view.removeFromSuperview()
                songListController?.removeFromParentViewController()
            }
        }
    }
    
    //MARK: events
    func itemButtonPressed(button: UIButton) {
        if button.tag == 0 {
            item1Button.selected = true
            item2Button.selected = false
        }else {
            item1Button.selected = false
            item2Button.selected = true
        }
        
        selectedIndex = button.tag
        updateContentView()
    }
}

