//
//  ChannelViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import MJRefresh



class ChannelViewController: ViewController {
    let cellID = "channelCellID"
    let headerID = "channelHeaderID"
    
    fileprivate var collectionView: UICollectionView?
    var dataSources = [Channel]()
    var radioID: Int = 0
    
    // init with radioID, if now, pass 0
    convenience init(radioID: Int) {
        self.init()
        
        self.radioID = radioID
        
        if radioID == 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(nowTimeChanged(_:)), name: NOTI_NOWTIME_CHANGED, object: nil)
        }
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: NOTI_NOWTIME_CHANGED, object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareCollectionView()
        
        collectionView!.mj_header.beginRefreshing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AssistiveTouch.shared.removeTarget(nil, action: nil, for: .allTouchEvents)
        AssistiveTouch.shared.addTarget(self, action: #selector(ChannelViewController.goBack), for: .touchUpInside)
        AssistiveTouch.shared.updateImage(UIImage(named: "touch_back")!)
    }

    func prepareCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let margin: CGFloat = 15
        let itemW: CGFloat = channelCollectionCellWidth
        let itemH: CGFloat = itemW + 30
        
        layout.itemSize = CGSize(width: itemW, height: itemH)
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin)
        layout.minimumInteritemSpacing = margin
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.register(ChannelCollectionViewCell.self, forCellWithReuseIdentifier: cellID)

        collectionView!.backgroundColor = UIColor.clear
        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
        collectionView!.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        collectionView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ChannelViewController.headerRefresh))        
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
                let radio = reflect 
                if radio.radioID == self?.radioID {
                    self?.dataSources.removeAll()
                    self?.dataSources.append(contentsOf: radio.channels!)
                    break
                }
            }
            
            self?.collectionView?.reloadDataOnMainQueue(after: { 
                self?.collectionView!.mj_header.endRefreshing()
            })
            
            }, onFailed: nil)
    }
    
    func listAllNowChannels() {
        
        api.fetch_all_now_channels({[weak self] (nowChannels) in
//            let week = CoreDB.currentDayOfWeek()
//            let time = CoreDB.currentTimeOfDay()
//            
//            let channelList = responseData[week*8+time]
//            let newChannels = [Channel](dictArray: channelList["channels"] as? [NSDictionary])
//            
//            self?.dataSource.removeAll()
//            self?.dataSource.append(contentsOf: newChannels)
//            
//            self?.collectionView?.reloadDataOnMainQueue(after: {
//                self?.collectionView!.mj_header.endRefreshing()
//            })
            
//            if self?.radioID == 0 {
//                self?.collectionView!.mj_header.hidden = true
//            }
        }, onFailed: nil)
        
    }

    func updateChannels() {
        collectionView!.mj_header.beginRefreshing()
    }
    
    func nowTimeChanged(_ notification: Notification) {
        
        if let userInfo = (notification as NSNotification).userInfo {
            let dayIndex = userInfo["dayIndex"] as! Int
            let timeIndex = userInfo["timeIndex"] as! Int

            api.fetch_all_now_channels({[weak self] (nowChannels) in
                let nowChannel = nowChannels[dayIndex*8+timeIndex]
                if let newChannels = nowChannel.channels {
                    
                    self?.dataSources.removeAll()
                    self?.dataSources.append(contentsOf: newChannels)
                    
                    self?.collectionView!.reloadDataOnMainQueue(after: nil)
                }

                
                }, onFailed: nil)
        }
        
    }
    
}


extension ChannelViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ChannelCollectionViewCell
        
        let channel = dataSources[(indexPath as NSIndexPath).item]
        cell.updateContent(channel, isNow: ((radioID == 0) ? false : true))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let channel = dataSources[(indexPath as NSIndexPath).item]
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



