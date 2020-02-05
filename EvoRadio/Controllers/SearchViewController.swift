//
//  SearchViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 4/3/17.
//  Copyright © 2017 JQTech. All rights reserved.
//

import UIKit
import MBProgressHUD

class SearchViewController: ViewController {

    let cellID = "LocalTableViewCell"
    var tableView = UITableView()
    var dataSources = [SearchSongInfo]()
    let searchBar = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    
    //MAR: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareSearchBar()
        prepareTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
    
    
    //MARK: - prepare UI
    func prepareSearchBar() {
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        searchBar.leftView = leftView
        searchBar.leftViewMode = .always
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        searchBar.placeholder = "输入歌单名、歌曲名"
        searchBar.font = UIFont.systemFont(ofSize: 14)
        searchBar.textColor = UIColor(netHex:0xDDDDDD)
        searchBar.clipsToBounds = true
        searchBar.layer.cornerRadius = 6
        searchBar.layer.borderWidth = 2
        searchBar.layer.borderColor = UIColor.gray.cgColor
        searchBar.backgroundColor = UIColor.black
        searchBar.alpha = 0.8
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.top.equalTo(view.snp.top).offset(30)
            make.left.equalTo(view.snp.left).offset(60)
            make.right.equalTo(view.snp.right).offset(-10)
        }
        
    }
    
    func prepareTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: playerBarHeight, right: 0)
        tableView.separatorStyle  = .none
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }
        tableView.keyboardDismissMode = .onDrag
    }
    
    //MARK: - Action events
    override func goBack() {
        dismiss(animated: false, completion: nil)
    }
    
    func doSearch(keyword: String) {
        if keyword == "" {
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        api.search_songs_from_baidu(keyword, onSuccess: {[weak self] (searchSongs) in
            
            self?.dataSources.removeAll()
            self?.dataSources.append(contentsOf: searchSongs)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                let _ = self?.tableView.scrollsToTop
                
                MBProgressHUD.hide(for: (self?.view)!, animated: true)
            }
        }) {[weak self] (error) in
            print(">> search songs failed: \(error)")
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: (self?.view)!, animated: true)
            }
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return false
        }
        
        if string == "\n" {
            doSearch(keyword: text)
            
            return false
        }
        
        return true
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SimpleTableViewCell
        
        let songInfo = dataSources[indexPath.row]
        cell.update(title: songInfo.songName, subTitle: songInfo.artistName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let songInfo = dataSources[indexPath.row]
        if let songId = songInfo.songId {
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            api.fetch_song_info_from_baidu(songId, onSuccess: {[weak self] (searchedResult) in
                print(">> fetch song info success")
                let songInfo = searchedResult.songInfo
                let bitrate = searchedResult.bitrate
                
                let song = Song()
                song.songId = songInfo?.songId
                song.songName = songInfo?.title
                song.picURL = songInfo?.picBig
                song.artistsName = songInfo?.author
                song.salbumsName = songInfo?.albumTitle
                song.duration = String(format:"%d", (bitrate?.fileDuration!)!)
                song.filesize = String(format:"%d", (bitrate?.fileSize!)!)
                song.audioURL = bitrate?.fileLink
                
                MusicManager.shared.appendSongToPlaylist(song, autoPlay: true)
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: (self?.view)!, animated: true)
                    
                    self?.present(PlayerViewController.mainController)
                }
                
            }) {[weak self] (error) in
                print(">> fetch song info failed: \(error)")
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: (self?.view)!, animated: true)
                }
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    
    
}
