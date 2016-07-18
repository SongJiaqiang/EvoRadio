//
//  DownloadedViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadedViewController: ViewController {
    
    let itemsView = UIView()
    let contentView = UIView()
    let item1Button = UIButton()
    let item2Button = UIButton()
    var selectedIndex: Int = 0
    
    var songListController: DownloadedSongListViewController?
    var programListController: DownloadedProgramListViewController?
    
    //MARK: cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        preparePageScrollView()
        prepareContentView()
        
        updateContentView()
        
        loadDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: prepare ui
    func preparePageScrollView() {
        
        view.addSubview(itemsView)
        itemsView.backgroundColor = UIColor.grayColor2()
        itemsView.snp_makeConstraints { (make) in
            make.height.equalTo(40)
            make.top.equalTo(view.snp_top).offset(64)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
        }
        
        itemsView.addSubview(item1Button)
        item1Button.titleLabel?.font = UIFont.sizeOf14()
        item1Button.setTitle("歌曲(0)", forState: .Normal)
        item1Button.setTitleColor(UIColor.grayColor6(), forState: .Normal)
        item1Button.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        item1Button.addTarget(self, action: #selector(DownloadedViewController.itemButtonPressed(_:)), forControlEvents: .TouchUpInside)
        item1Button.tag = 0
        item1Button.selected = true
        
        
        itemsView.addSubview(item2Button)
        item2Button.titleLabel?.font = UIFont.sizeOf14()
        item2Button.setTitle("歌单(0)", forState: .Normal)
        item2Button.setTitleColor(UIColor.grayColor6(), forState: .Normal)
        item2Button.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        item2Button.addTarget(self, action: #selector(DownloadedViewController.itemButtonPressed(_:)), forControlEvents: .TouchUpInside)
        item2Button.tag = 1
        
        
        item1Button.snp_makeConstraints { (make) in
            make.topMargin.equalTo(0)
            make.leftMargin.equalTo(0)
            make.bottomMargin.equalTo(0)
            make.right.equalTo(item2Button.snp_left)
            make.width.equalTo(item2Button.snp_width)
        }
        
        item2Button.snp_makeConstraints { (make) in
            make.topMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            make.bottomMargin.equalTo(0)
            make.left.equalTo(item1Button.snp_right)
            make.width.equalTo(item1Button.snp_width)
        }
        
        
    }
    
    func prepareContentView() {
        view.addSubview(contentView)
        contentView.snp_makeConstraints { (make) in
            make.top.equalTo(itemsView.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(view.snp_bottom)
        }
    }
    
    func updateContentView() {
        if selectedIndex == 0 {
            if songListController == nil {
                songListController = DownloadedSongListViewController()
            }
            addChildController(songListController!, toView: contentView)
            if let _ = programListController {
                programListController?.view.removeFromSuperview()
                programListController?.removeFromParentViewController()
            }
        }else {
            if programListController == nil {
                programListController = DownloadedProgramListViewController()
            }
            addChildController(programListController!, toView: contentView)
            if let _ = songListController {
                songListController?.view.removeFromSuperview()
                songListController?.removeFromParentViewController()
            }
        }
    }
    
    func loadDataSource() {
        if let songs = CoreDB.getDownloadedSongs() {
            item1Button.setTitle("歌曲(\(songs.count))", forState: .Normal)
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

