//
//  ChannelViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import MJRefresh


class ChannelViewController: UIViewController {
    let cellID = "channelCellID"
    let headerID = "channelHeaderID"
    
    private var collectionView: UICollectionView?
    var dataSource = [Channel]()
    var radioID: Int = 0
    
    // init with radioID, if now, pass 0
    convenience init(radioID: Int) {
        self.init()
        
        self.radioID = radioID
        
        if radioID == 0 {
            Device.defaultNotificationCenter().addObserver(self, selector: #selector(ChannelViewController.nowTimeChanged(_:)), name: NOWTIME_CHANGED, object: nil)
        }
    }
    
    deinit{
        Device.defaultNotificationCenter().removeObserver(self, name: NOWTIME_CHANGED, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareCollectionView()
        
        collectionView!.mj_header.beginRefreshing()
    }
    

    func prepareCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let margin: CGFloat = 15
        let itemW: CGFloat = channelCollectionCellWidth
        let itemH: CGFloat = itemW + 30
        
        layout.itemSize = CGSizeMake(itemW, itemH)
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin)
        layout.minimumInteritemSpacing = margin
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.registerClass(ChannelCollectionViewCell.self, forCellWithReuseIdentifier: cellID)

        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView!.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        collectionView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ChannelViewController.headerRefresh))
        
        //        if radioID == 0 {
//            collectionView!.registerClass(ChannelCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
//        }
        
        
    }
    
    func headerRefresh() {
        
        if radioID == 0 {
            listAllNowChannels()
        }else {
            listAllChannels()
        }

    }
    
    func listAllChannels() {
        api.fetch_all_channels({[weak self] (items) in
            
            for reflect in items {
                let radio = reflect as! Radio
                if radio.radioID == self?.radioID {
                    self?.dataSource.removeAll()
                    self?.dataSource.appendContentsOf(radio.channels!)
                    break
                }
            }
            self?.collectionView!.reloadData()
            self?.collectionView!.mj_header.endRefreshing()
            }, onFailed: nil)
    }
    
    func listAllNowChannels() {
        
        api.fetch_all_now_channels({[weak self] (responseData) in
            let week = CoreDB.currentDayOfWeek()
            let time = CoreDB.currentTimeOfDay()
            
            let anyList = responseData[week*8+time]
            
            self?.dataSource.removeAll()
            
            let channels = Channel.parses(arr: anyList["channels"] as! NSArray)
            self?.dataSource.appendContentsOf(channels as! [Channel])
            
            self?.collectionView!.reloadData()
            self?.collectionView!.mj_header.endRefreshing()
            if self?.radioID == 0 {
                self?.collectionView!.mj_header.hidden = true
            }
        }, onFailed: nil)
        
    }

    func updateChannels() {
        collectionView!.mj_header.beginRefreshing()
    }
    
    func nowTimeChanged(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let dayIndex = userInfo["dayIndex"] as! Int
            let timeIndex = userInfo["timeIndex"] as! Int

            api.fetch_all_now_channels({[weak self] (responseData) in
                let someList = responseData[dayIndex*8+timeIndex]

                self?.dataSource.removeAll()
                self?.dataSource.appendContentsOf(Channel.channelsWithDict(someList["channels"] as! [[String : AnyObject]]))
                self?.collectionView!.reloadData()
                }, onFailed: nil)
        }
        
    }
    
}


extension ChannelViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! ChannelCollectionViewCell
        
        let channel = dataSource[indexPath.item]
        cell.updateContent(channel, isNow: !Bool(radioID))
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let channel = dataSource[indexPath.item]
        navigationController?.pushViewController(ProgramViewController(channel: channel), animated: true)
    }
    
//    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerID, forIndexPath: indexPath) as! ChannelCollectionHeaderView
//        
//        return headerView
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        
//        if radioID == 0 {
//            return CGSizeMake(Device.width(), 100)
//        }
//        
//        return CGSizeZero
//    }
    
}

extension ChannelViewController: ChannelCollectionViewCellDelegate {
    
    func playMusicOfChannel(channelID: String) {
        
        let pageIndex: Int = Int(arc4random_uniform(10))
        api.fetch_programs(channelID, page: Page(index: pageIndex, size: 1), onSuccess: { (reflects) in
            
            if reflects.count > 0 {
//                let program = Program.programWithDict(responseData.first!)
                let program = reflects.first as! Program
                let player = PlayerViewController(program: program)
                player.autoPlaying = true
                Device.rootController().presentViewController(player, animated: true, completion: nil)
            }
            
            }, onFailed: nil)
    }
}


