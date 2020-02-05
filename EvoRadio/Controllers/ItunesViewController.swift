//
//  ItunesViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 26/08/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer


class ItunesViewController: ViewController {
    
    let cellID = "cellID"
    
    var tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var songs = [Song]()
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUI()
        
        prepareTableView()
        
        loadMusicFromItunes()
    }
    
    //MARK: prepare UI
    func prepareUI() {
        
        let navBar = UIView()
        navBar.backgroundColor = UIColor.grayColor1C().alpha(0.98)
        view.addSubview(navBar)
        navBar.snp.makeConstraints { (make) in
            make.height.equalTo(84)
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
        }
        
        let separationLine = UIView()
        separationLine.backgroundColor = UIColor.goldColor()
        navBar.addSubview(separationLine)
        separationLine.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.equalTo(navBar.snp.left)
            make.right.equalTo(navBar.snp.right)
            make.bottom.equalTo(navBar.snp.bottom)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "iTunes"
        titleLabel.font = UIFont.boldSize16()
        titleLabel.textColor = UIColor.grayColorBF()
        navBar.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(navBar.snp.centerX)
            make.centerY.equalTo(navBar.snp.centerY).offset(10)
        }
        
        let playAllButton = UIButton()
        playAllButton.titleLabel?.font = UIFont.size12()
        playAllButton.setTitleColor(UIColor.grayColor66(), for: .normal)
        playAllButton.setTitle("PlayAll", for: .normal)
        navBar.addSubview(playAllButton)
        playAllButton.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.right.equalTo(navBar.snp.right).offset(-15)
            make.centerY.equalTo(navBar.snp.centerY).offset(10)
        }
        playAllButton.addTarget(self, action: #selector(playAllButtonPressed(_:)), for: .touchUpInside)
    }
    
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        view.insertSubview(tableView, at: 0)
        tableView.snp.makeConstraints({(make) in
            make.edges.equalTo(UIEdgeInsets.zero)
        })

        tableView.register(SongListTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.contentInset = UIEdgeInsets(top: 84, left: 0, bottom: playerBarHeight, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -84)
        
    }
    
    //MARK: Event actions
    @objc func playAllButtonPressed(_ butotn: UIButton) {
        print(">>> play all itunes musics")
    }
    
    
    //MARK: others
    func loadMusicFromItunes() {
        
        let mediaQuery = MPMediaQuery()
        let albumNamePredicate = MPMediaPropertyPredicate(value: MPMediaType.music.rawValue, forProperty: MPMediaItemPropertyMediaType)
        mediaQuery.addFilterPredicate(albumNamePredicate)
        
        if let items = mediaQuery.items {
            print("Selected items:\(items.count)")
            
            songs.removeAll()
            
            for item in items {
                let song = resolverMediaItem(item: item)
                
                songs.append(song)
            }
            
            tableView.reloadData()
        }
    }
    
    func resolverMediaItem(item: MPMediaItem) -> Song {
        
        let song = Song()
        song.songId = String(format: "%lld", Date().timeIntervalSince1970)
        song.songName = item.value(forKey: MPMediaItemPropertyTitle) as? String
        song.artistsName = item.value(forKey: MPMediaItemPropertyArtist) as? String
        song.salbumsName = item.value(forKey: MPMediaItemPropertyAlbumTitle) as? String
        
        if let duration = item.value(forKey: MPMediaItemPropertyPlaybackDuration) {
            song.duration = String(format: "%.0f", duration as! Float)
        }
        
        if let assetURL = item.value(forKey: MPMediaItemPropertyAssetURL) as? NSURL {
            song.assetURL = assetURL as URL
            //            print(">>> iTunes song url: \(assetURL)")
        }
        
//        if let duration = song.value(forKey: MPMediaItemPropertyPlaybackDuration) as? NSNumber {
//            song.duration = String(format: "%d", duration.doubleValue)
//        }
        
        if let albumArtwork = item.value(forKey: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
            
            let image = albumArtwork.image(at: CGSize(width: 120, height: 120))
            song.albumImage = image
            //            print(">>> iTunes album image: \(String(describing: image))")
        }
        
        return song
    }
    
    func presentMediaController() {
        let controller = MPMediaPickerController(mediaTypes: .music)
        controller.allowsPickingMultipleItems = true
        controller.prompt = "Prompt是神马"
        controller.delegate = self
        
        self.present(controller, animated: true, completion: nil)
    }

}

extension ItunesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SongListTableViewCell
        
        let song = songs[indexPath.row]
        cell.updateSongInfo(song)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let song = songs[indexPath.row]
        MusicManager.shared.appendSongToPlaylist(song, autoPlay: true)
        
        present(PlayerViewController.mainController, animated: true, completion: nil)
        
    }
    
}

extension ItunesViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
//        mediaPicker.dismiss(animated: true, completion: nil)
        
        print("Selected items:\(mediaItemCollection.items.count)")
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}
