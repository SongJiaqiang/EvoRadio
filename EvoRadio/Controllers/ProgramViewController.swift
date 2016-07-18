//
//  ProgramViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import MJRefresh

class ProgramViewController: ViewController {
    let cellID = "programCellID"
    
    var channel: Channel!
    var dataSource = [Program]()
    private var collectionView: UICollectionView?
    private var endOfFeed = false
    private let pageSize: Int = 60
    
    convenience init(channel: Channel) {
        self.init()
        
        self.channel = channel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        setupBackButton()
        title = channel.channelName
        
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
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView!.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        collectionView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ProgramViewController.headerRefresh))
        collectionView!.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(ProgramViewController.footerRefresh))
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
        let channelID = channel.channelID!
        
        var pageIndex = dataSource.count
        if isRefresh {
            pageIndex = 0
        }
        
        api.fetch_programs(channelID, page: Page(index: pageIndex, size: pageSize), onSuccess: {[weak self] (items) in
            
            if items.count > 0 {
//                let newData = Program.programsWithDict(responseData)
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

extension ProgramViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
    
}

extension ProgramViewController: ProgramCollectionViewCellDelegate {
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

