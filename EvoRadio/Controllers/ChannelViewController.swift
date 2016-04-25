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
    
    var collectionView: UICollectionView?
    var dataSource = [Channel]()
    var radioID: Int = 0
    
    // init with radioID, if now, pass 0
    convenience init(radioID: Int) {
        self.init()
        
        self.radioID = radioID
        
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
        
        collectionView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ChannelViewController.mjHeaderRefresh))
        
        
    }
    
    func mjHeaderRefresh() {
        
        if radioID == 0 {
            listAllNowChannels()
        }else {
            listAllChannels()
        }

    }
    
    func listAllChannels() {
        api.fetch_all_channels({[weak self] (responseData) in
            
            let radios = Radio.radiosWithDict(responseData)
            for radio in radios {
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
            let count = UInt32(responseData.count)
            let random = Int(arc4random_uniform(count))
            let anyList = responseData[random]
            
            self?.dataSource.removeAll()
            self?.dataSource.appendContentsOf(Channel.channelsWithDict(anyList["channels"] as! [[String : AnyObject]]))
            
            self?.collectionView!.reloadData()
            self?.collectionView!.mj_header.endRefreshing()
            }, onFailed: nil)
        
    }

    func updateChannels() {
        collectionView!.mj_header.beginRefreshing()
    }
}


extension ChannelViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! ChannelCollectionViewCell
        
        let channel = dataSource[indexPath.item]
        cell.updateContent(channel)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let channel = dataSource[indexPath.item]
        navigationController?.pushViewController(ProgramViewController(channel: channel), animated: true)
    }
    
}


