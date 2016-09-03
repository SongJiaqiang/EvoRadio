//
//  NowViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 9/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import iCarousel
import MJRefresh

class NowViewController: ViewController {
    
    let cellID = "groundProgramCellID"
    let headerViewID = "NowCollectionHeaderViewID"
    let footerViewID = "footerViewID"
    
    var dataSource = [Program]()
    var nowChannels = [Channel]()
    var collectionView: UICollectionView!
    var collectionHeaderView: NowCollectionHeaderView?
    private var endOfFeed = false
    private let pageSize: Int = 60
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Now"
        
        prepareCollectionView()
        
        collectionView!.mj_header.beginRefreshing()
    }
    
    func prepareCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let margin: CGFloat = 15
        let itemW: CGFloat = programCollectionCellWidth
        let itemH: CGFloat = itemW + 30
        
        layout.itemSize = CGSizeMake(itemW, itemH)
        layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin)
        layout.minimumInteritemSpacing = margin
        
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.registerClass(ProgramCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView!.registerClass(NowCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerViewID)
        collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerViewID)
        
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView!.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        collectionView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(NowViewController.headerRefresh))
        collectionView!.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(NowViewController.footerRefresh))
        collectionView!.mj_footer.automaticallyHidden = true
        
    }
    
    
    func headerRefresh() {
        listChannelPrograms(true)
    }
    
    func footerRefresh() {
        if endOfFeed {
            collectionView!.mj_footer.endRefreshing()
        }else {
            listChannelPrograms(false)
        }
    }
    
    func listChannelPrograms(isRefresh: Bool) {
        
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
                
                self?.dataSource.appendContentsOf(newData)
                
                self?.collectionView!.reloadData()
                self?.endRefreshing()
                
            }else {
                self?.endOfFeed = true
                self?.endRefreshing()
                self?.collectionView!.mj_footer.endRefreshingWithNoMoreData()
            }
            
            }, onFailed: nil)
    }
    
    func endRefreshing() {
        if collectionView!.mj_header.isRefreshing() {
            collectionView!.mj_header.endRefreshing()
        }
        
        if collectionView!.mj_footer.isRefreshing() {
            collectionView!.mj_footer.endRefreshing()
        }
        
    }
    
}

extension NowViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! ProgramCollectionViewCell
        
        let program = dataSource[indexPath.item]
        cell.updateContent(program)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let program = dataSource[indexPath.item]
        
        let listController = SongListViewController()
        listController.program = program
        navigationController?.pushViewController(listController, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            if let headerView = collectionHeaderView {
                return headerView
            }
            collectionHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerViewID, forIndexPath: indexPath) as! NowCollectionHeaderView
            collectionHeaderView!.frame = CGRectMake(0, 0, Device.width(), 200)
            collectionHeaderView!.delegate = self
            api.fetch_all_now_channels({[weak self] (responseData) in
                let week = CoreDB.currentDayOfWeek()
                let time = CoreDB.currentTimeOfDay()
                
                let anyList = responseData[week*8+time]
                let channels = [Channel](dictArray: anyList["channels"] as? [NSDictionary])
                dispatch_async(dispatch_get_main_queue(), {[weak self] in
                    self?.nowChannels = channels
                    self?.collectionHeaderView!.updateChannels(channels)
                })
                
                }, onFailed: nil)

            return collectionHeaderView!
        }else {
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: footerViewID, forIndexPath: indexPath)
            return footerView
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: Device.width(), height: 200);
    }
    
}

extension NowViewController: ProgramCollectionViewCellDelegate {
    func playMusicOfProgram(programID: String) {
        TrackManager.playMusicTypeEvent(.ProgramCover)
        
        api.fetch_songs(programID, isVIP: true, onSuccess: { (songs) in
            if songs.count > 0 {
                MusicManager.sharedManager.clearList()
                MusicManager.sharedManager.appendSongsToPlaylist(songs as! [Song], autoPlay: true)
                Device.keyWindow().topMostController()!.presentViewController(PlayerViewController.playerController, animated: true, completion: nil)
            }
            
            }, onFailed: nil)
    }
}



extension NowViewController: NowCollectionHeaderViewDelegate {
    func headerView(headerView: NowCollectionHeaderView, didSelectedAtIndex index: Int) {
        let channel = nowChannels[index]
        navigationController?.pushViewController(ProgramViewController(channel: channel), animated: true)
    }
}