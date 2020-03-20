//
//  ProgramViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import MJRefresh
import Lava

class ProgramViewController: ViewController {
    let cellID = "programCellID"
    
    var channel: LRChannel!
    var dataSources = [LRProgram]()
    var collectionView: UICollectionView?
    fileprivate var endOfFeed = false
    fileprivate let pageSize: Int = 30
    
    var showHeaderView: Bool = false
    
    //MARK life cycle
    convenience init(channel: LRChannel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: prepare
    func prepareCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        let margin: CGFloat = 15
        let itemW: CGFloat = programCollectionCellWidth
        let itemH: CGFloat = itemW + 30
        
        layout.itemSize = CGSize(width: itemW, height: itemH)
        layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        layout.minimumInteritemSpacing = margin
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.addSubview(collectionView!)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.register(ProgramCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        
        collectionView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        collectionView!.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(footerRefresh))
        //        collectionView!.mj_footer.isAutomaticallyH@objc idden = true
        
        
        if showHeaderView {
            collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ProgramCollectionHeaderView")
            collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerView")
        }

    }

    //MARK events
    @objc func headerRefresh() {
        listChannelPrograms(true)
    }
    
    @objc func footerRefresh() {
        if endOfFeed {
            collectionView!.mj_footer.endRefreshing()
        }else {
            listChannelPrograms(false)
        }
    }
    
    
    func listChannelPrograms(_ isRefresh: Bool) {
        let channelId = channel.channelId!
        
        var pageIndex = dataSources.count
        if isRefresh {
            pageIndex = 0
        }
        
        Lava.shared.fetchPrograms(channelId, page: LRPage(index: pageIndex), onSuccess: {[weak self] (newItems) in
            
            if newItems.count > 0 {
                if isRefresh {
                    self?.dataSources.removeAll()
                }
                
                self?.dataSources.append(contentsOf: newItems)
                
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
    
    func endRefreshing() {
        if collectionView!.mj_header.isRefreshing {
            collectionView!.mj_header.endRefreshing()
        }
        
        if collectionView!.mj_footer.isRefreshing {
            collectionView!.mj_footer.endRefreshing()
        }
        
    }

}

extension ProgramViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProgramCollectionViewCell
        
        let program = dataSources[(indexPath as NSIndexPath).item]
        cell.updateContent(program)
//        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let program = dataSources[(indexPath as NSIndexPath).item]
        let cell = collectionView.cellForItem(at: indexPath) as! ProgramCollectionViewCell
        
        let listController = SongListViewController()
        listController.program = program
        if let mainCoverImage = cell.picImageView.image {
            listController.coverImages = [mainCoverImage]
        }
        navigationController?.pushViewController(listController, animated: true)
    }
    
}

extension ProgramViewController: ProgramCollectionViewCellDelegate {
    func playMusicOfProgram(_ programId: String) {
        Lava.shared.fetchSongs(programId, onSuccess: { (songs) in
            if songs.count > 0 {
                MusicManager.shared.clearList()
                MusicManager.shared.appendSongsToPlaylist(Song.fromLRSongs(songs), autoPlay: true)
//
//                if let topVC = Device.keyWindow().topMostController() {
//                    topVC.present(PlayerViewController.mainController)
//                }
            }
            
            }, onFailed: nil)
    }
}

