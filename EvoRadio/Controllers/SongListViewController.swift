//
//  SongListViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 5/29/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class SongListViewController: ViewController {

    let cellID = "songCellID"
    
    var program: Program!
    var dataSource = [Song]()

    var tableView = UITableView()
    var coverImageView = UIImageView()
    
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        
        if let _ = program {
            title = program.programName
            listProgramSongs()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: prepare UI
    func prepareTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clearColor()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, playerBarHeight, 0)
//        tableView.bounces = false
        tableView.snp_makeConstraints(closure: {(make) in
            make.edges.equalTo(UIEdgeInsetsZero)
//            make.height.equalTo(Device.width())
//            make.top.equalTo(view.snp_top)
//            make.left.equalTo(view.snp_left)
//            make.right.equalTo(view.snp_right)
        })
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        let headerView = UIView()
        headerView.frame = CGRectMake(0, 0, Device.width(), Device.width())
        
        
        headerView.addSubview(coverImageView)
        coverImageView.contentMode = .ScaleAspectFill
        coverImageView.clipsToBounds = true
        if let _ = program {
            coverImageView.kf_setImageWithURL(NSURL(string: program.cover!.pics!.first!)!, placeholderImage: UIImage.placeholder_cover())
        }else {
            coverImageView.image = UIImage.placeholder_cover()
        }
        coverImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        tableView.tableHeaderView = headerView
    }
    
    //MARK: events
    func listProgramSongs() {
        
        if let _ = program {
            let programID = program.programID!
            
            api.fetch_songs(programID, onSuccess: {[weak self] (items) in
                
                if items.count > 0 {
                    let songs = items as! [Song]
                    self?.dataSource = songs
                    PlaylistManager.instance.saveList(songs)
                    
                    self?.updateCover()
                    self?.tableView.reloadData()
                }else {
                    print("This program has no songs")
                }
                
            }, onFailed: nil)
        }
        
    }
    
    func updateCover() {
        if let _ = program {
            coverImageView.kf_setImageWithURL(NSURL(string: program.cover!.pics!.first!)!, placeholderImage: UIImage.placeholder_cover())
        }else {
            coverImageView.image = UIImage.placeholder_cover()
        }
    }


}

extension SongListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("dataSource count: \(dataSource.count)")
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        
        let song = dataSource[indexPath.row]
        
        cell?.textLabel?.text = song.songName
        cell?.detailTextLabel?.text = song.artistsName
        cell?.imageView?.kf_setImageWithURL(NSURL(string: song.picURL!)!, placeholderImage: UIImage.placeholder_cover())
        
        return cell!
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRectMake(0,0,tableView.bounds.width,40))
        
        let playButton = UIButton()
        header.addSubview(playButton)
        playButton.titleLabel?.font = UIFont.systemFontOfSize(12)
        playButton.backgroundColor = UIColor(white: 0.2, alpha: 1)
        playButton.clipsToBounds = true
        playButton.layer.cornerRadius = 15
        playButton.setTitle("Play All", forState: .Normal)
        playButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(80, 30))
            make.centerY.equalTo(header.snp_centerY)
            make.leftMargin.equalTo(10)
        }
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 1. download file
        let song = dataSource[indexPath.row]
        
        Downloader.downloader.downloadFile(song.audioURL!, complete: {[weak self] (filePath) -> Void in
            
            // 2. play audio
            if !MusicManager.sharedManager.isPlayingOfSong(filePath) {
                let itemIndex = MusicManager.sharedManager.addMusicToList(filePath)
                MusicManager.sharedManager.playItemAtIndex(itemIndex)

                playerView.hide()
                playerControler.song = song
            }
            
            self?.presentViewController(playerControler, animated: true, completion: nil)
            
            }, progress: { (velocity, progress) in
                print("\(velocity)MB/S - \(progress*100)%)")
        })
    }
}

class songListCell: UITableViewCell {
    
    
    
}
