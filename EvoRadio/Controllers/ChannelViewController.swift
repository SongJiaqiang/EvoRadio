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
import Lava


class ChannelViewController: ViewController {
    let cellID = "channelCellID"
    let headerID = "channelHeaderID"
    
    fileprivate var collectionView: UICollectionView?
    var dataSources = [LRChannel]()
    var radioId: Int = 0
    
    // init with radioId, if now, pass 0
    convenience init(radioId: Int) {
        self.init()
        
        self.radioId = radioId
        
        if radioId == 0 {
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

    func prepareCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let margin: CGFloat = 15
        let itemW: CGFloat = channelCollectionCellWidth
        let itemH: CGFloat = itemW + 30
        
        layout.itemSize = CGSize(width: itemW, height: itemH)
        layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        layout.minimumInteritemSpacing = margin
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.register(ChannelCollectionViewCell.self, forCellWithReuseIdentifier: cellID)

        collectionView!.backgroundColor = UIColor.clear
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: playerBarHeight, right: 0)
        collectionView!.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        collectionView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ChannelViewController.headerRefresh))        
    }
    
    @objc func headerRefresh() {
        
        if radioId == 0 {
            listAllNowChannels()
        }else {
            listAllChannels()
        }

    }
    
    func listAllChannels() {
        Lava.shared.fetchAllRadios({[weak self] (items) in
            
            for reflect in items {
                let radio = reflect 
                if radio.radioId == self?.radioId {
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
        Lava.shared.fetchNowChannels({[weak self] (nowChannels) in
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
            
//            if self?.radioId == 0 {
//                self?.collectionView!.mj_header.hidden = true
//            }
        }, onFailed: nil)
        
    }

    func updateChannels() {
        collectionView!.mj_header.beginRefreshing()
    }
    
    @objc func nowTimeChanged(_ notification: Notification) {
        
        if let userInfo = (notification as NSNotification).userInfo {
            let dayIndex = userInfo["dayIndex"] as! Int
            let timeIndex = userInfo["timeIndex"] as! Int
            Lava.shared.fetchNowChannels({[weak self] (nowChannels) in
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
        cell.updateContent(channel, isNow: ((radioId == 0) ? false : true))
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
//        if radioId == 0 {
//            return CGSizeMake(Device.width(), 100)
//        }
//        
//        return CGSizeZero
//    }
    
}



