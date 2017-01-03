//
//  NowViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 9/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import MJRefresh

class NowViewController: ViewController {
    
    let cellID = "groundProgramCellID"
    let headerViewID = "NowCollectionHeaderViewID"
    let footerViewID = "footerViewID"
    
    var dataSource = [Program]()
    var nowChannels = [Channel]()
    var collectionView: UICollectionView!
    var collectionHeaderView: NowCollectionHeaderView?
    fileprivate var endOfFeed = false
    fileprivate let pageSize: Int = 60
    // tH : w = 200 : 375
    let heardViewHeight = Device.width() * (200 / 375)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Now"
        
        prepareCollectionView()
//        collectionView!.mj_header.beginRefreshing()
        headerRefresh()
        
        prepareClock()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelViewController.nowTimeChanged(_:)), name: NOTI_NOWTIME_CHANGED, object: nil)
    }
    
    func prepareClock() {
        let clockFrame = CGRect(x: Device.width()-50, y: 10, width: 40, height: 40)
        let clock = ClockView(frame: clockFrame)
        view.addSubview(clock)
        clock.addTarget(self, action: #selector(NowViewController.clockViewPressed), for: .touchUpInside)
    }
    
    func prepareCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let margin: CGFloat = 15
        let itemW: CGFloat = programCollectionCellWidth
        let itemH: CGFloat = itemW + 30
        
        layout.itemSize = CGSize(width: itemW, height: itemH)
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin)
        layout.minimumInteritemSpacing = margin
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.register(ProgramCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView!.register(NowCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerViewID)
        collectionView!.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerViewID)
        
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
//        collectionView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(NowViewController.headerRefresh))
        collectionView!.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(NowViewController.footerRefresh))
        collectionView!.mj_footer.isAutomaticallyHidden = true
        
    }
    
    
    //MARK: events
    func clockViewPressed() {
        SelectiveTimePanel.timePanel.show()
    }
    
    func nowTimeChanged(_ notification: Notification) {
        
        if let userInfo = (notification as NSNotification).userInfo {
            let dayIndex = userInfo["dayIndex"] as! Int
            let timeIndex = userInfo["timeIndex"] as! Int
            
            api.fetch_all_now_channels({[weak self] (responseData) in
                let channelList = responseData[dayIndex*8+timeIndex]
                let newChannels = [Channel](dictArray: channelList["channels"] as? [NSDictionary])
                print("newChannels:\(newChannels.count)")
                
                self?.nowChannels.removeAll()
                self?.nowChannels.append(contentsOf: newChannels)
                
                self?.collectionHeaderView = nil
                self?.collectionView!.reloadDataOnMainQueue(after: nil)
                }, onFailed: nil)
        }
    }
    
    func headerRefresh() {
        listNowChannels()
        listGroundPrograms(true)
    }
    
    func footerRefresh() {
        if endOfFeed {
            collectionView!.mj_footer.endRefreshing()
        }else {
            listGroundPrograms(false)
        }
    }
    
    func listGroundPrograms(_ isRefresh: Bool) {
        var pageIndex = dataSource.count
        if isRefresh {
            pageIndex = 0
        }
        
        api.fetch_ground_programs(Page(index: pageIndex, size: pageSize), onSuccess: {[weak self] (items) in
            
            if items.count > 0 {
                let newData = items as! [Program]
                if isRefresh {
                    self?.dataSource.removeAll()
                }
                
                self?.dataSource.append(contentsOf: newData)
                
                self?.collectionView!.reloadDataOnMainQueue(after: {
                    self?.endRefreshing()
                })
                
            }else {
                self?.endOfFeed = true
                self?.endRefreshing()
                self?.collectionView!.mj_footer.endRefreshingWithNoMoreData()
            }
            
            }, onFailed: nil)
    }
    
    func listNowChannels() {
        api.fetch_all_now_channels({[weak self] (responseData) in
            let week = CoreDB.currentDayOfWeek()
            let time = CoreDB.currentTimeOfDay()
            
            let anyList = responseData[week*8+time]
            let channels = [Channel](dictArray: anyList["channels"] as? [NSDictionary])
            DispatchQueue.main.async(execute: {[weak self] in
                self?.nowChannels = channels
                self?.collectionHeaderView!.updateChannels(channels)
                })
            
            }, onFailed: nil)
    }
    
    
    func endRefreshing() {
//        if collectionView!.mj_header.isRefreshing() {
//            collectionView!.mj_header.endRefreshing()
//        }
        
        if collectionView!.mj_footer.isRefreshing() {
            collectionView!.mj_footer.endRefreshing()
        }
    }
    
}

extension NowViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProgramCollectionViewCell
        
        let program = dataSource[(indexPath as NSIndexPath).item]
        cell.updateContent(program)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let program = dataSource[(indexPath as NSIndexPath).item]
        
        let listController = SongListViewController()
        listController.program = program
        navigationController?.pushViewController(listController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            if let headerView = collectionHeaderView {
                return headerView
            }
            collectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerViewID, for: indexPath) as? NowCollectionHeaderView
            collectionHeaderView!.frame = CGRect(x: 0, y: 0, width: Device.width(), height: heardViewHeight)
            collectionHeaderView!.delegate = self
            collectionHeaderView?.updateChannels(nowChannels)
            
            return collectionHeaderView!
        }else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerViewID, for: indexPath)
            return footerView
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: Device.width(), height: heardViewHeight);
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var title = "当下"
        if scrollView.contentOffset.y > heardViewHeight {
            title = "精品推荐"
        }
        
        TopTabBar.mainBar.updateTitle(title: title, atIndex: 1);
    }
    
}


extension NowViewController: ProgramCollectionViewCellDelegate {
    func playMusicOfProgram(_ programID: String) {
        TrackManager.playMusicTypeEvent(.ProgramCover)
        
        api.fetch_songs(programID, isVIP: true, onSuccess: { (songs) in
            if songs.count > 0 {
                MusicManager.shared.clearList()
                MusicManager.shared.appendSongsToPlaylist(songs as! [Song], autoPlay: true)
                Device.keyWindow().topMostController()!.present(PlayerViewController.mainController, animated: true, completion: nil)
            }
            
            }, onFailed: nil)
    }
}


extension NowViewController: NowCollectionHeaderViewDelegate {
    func headerView(_ headerView: NowCollectionHeaderView, didSelectedAtIndex index: Int) {
        let channel = nowChannels[index]
        navigationController?.pushViewController(ProgramViewController(channel: channel), animated: true)
    }
}
