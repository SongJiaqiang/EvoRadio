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
    var dataSources = [Program]()
    var collectionView: UICollectionView?
    fileprivate var endOfFeed = false
    fileprivate let pageSize: Int = 30
    
    var showHeaderView: Bool = false
    
    //MARK life cycle
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AssistiveTouch.shared.removeTarget(nil, action: nil, for: .allTouchEvents)
        AssistiveTouch.shared.addTarget(self, action: #selector(ProgramViewController.goBack), for: .touchUpInside)
        AssistiveTouch.shared.updateImage(UIImage(named: "touch_back")!)
    }
    
    //MARK: prepare
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
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        collectionView!.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(ProgramViewController.headerRefresh))
        collectionView!.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(ProgramViewController.footerRefresh))
//        collectionView!.mj_footer.isAutomaticallyHidden = true
        
        
        if showHeaderView {
            collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProgramCollectionHeaderView")
            collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView")
        }

    }

    //MARK events
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
    
    
    func listChannelPrograms(_ isRefresh: Bool) {
        let channelID = channel.channelID!
        
        var pageIndex = dataSources.count
        if isRefresh {
            pageIndex = 0
        }
        
        api.fetch_programs(channelID, page: Page(index: pageIndex, size: pageSize), onSuccess: {[weak self] (newItems) in
            
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
    func playMusicOfProgram(_ programID: String) {
        
        api.fetch_songs(programID, isVIP: true, onSuccess: { (songs) in
            if songs.count > 0 {
                MusicManager.shared.clearList()
                MusicManager.shared.appendSongsToPlaylist(songs, autoPlay: true)
//
//                if let topVC = Device.keyWindow().topMostController() {
//                    topVC.present(PlayerViewController.mainController, animated: true, completion: nil)
//                }
            }
            
            }, onFailed: nil)
    }
}

