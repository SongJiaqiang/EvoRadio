//
//  StreamingKitViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 7/19/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import StreamingKit

class StreamingKitViewController: ViewController {

    
    let cellID = "cellID"
    var tableView: UITableView = UITableView()
    let controlView = UIView()
    let playButton = UIButton()
    let playSlider: UISlider = UISlider()
    
    var dataSource: [Song] = [Song]()
    var audioPlayer: STKAudioPlayer = STKAudioPlayer()
    var playTimer: Timer?
    
    var currentIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        prepareControlView()
        prepareTableView()
        preparePlayer()
        prepareTimer()
        
        loadSongs()
        
    }
    
    deinit {
        if let _ = playTimer {
            playTimer?.invalidate()
            playTimer = nil
        }
        
    }

    //MARK: Prepare something
    func prepareTableView() {
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(controlView.snp.top)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    func prepareControlView() {
        
        view.addSubview(controlView)
        controlView.backgroundColor = UIColor(netHex: 0x414141)
        controlView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(100)
        }
        
        
        controlView.addSubview(playButton)
        playButton.setTitle("Play", for: UIControlState())
        playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(controlView.snp.center)
        }
        
        let prevButton = UIButton()
        controlView.addSubview(prevButton)
        prevButton.setTitle("<", for: UIControlState())
        prevButton.addTarget(self, action: #selector(prevButtonPressed), for: .touchUpInside)
        prevButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.centerY.equalTo(controlView.snp.centerY)
            make.right.equalTo(playButton.snp.left).offset(-20)
        }
        
        let nextButton = UIButton()
        controlView.addSubview(nextButton)
        nextButton.setTitle(">", for: UIControlState())
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        nextButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.centerY.equalTo(controlView.snp.centerY)
            make.left.equalTo(playButton.snp.right).offset(20)
        }
        
        
        controlView.addSubview(playSlider)
        playSlider.addTarget(self, action: #selector(playSliderChanged), for: .valueChanged)
        playSlider.minimumValue = 0
        playSlider.maximumValue = 0
        playSlider.snp.makeConstraints { (make) in
            make.left.equalTo(controlView.snp.left).offset(20)
            make.right.equalTo(controlView.snp.right).offset(-20)
            make.top.equalTo(controlView.snp.top)
        }
        
    }
    
    func preparePlayer() {
        
//        let options = STKAudioPlayerOptions()
//        audioPlayer = STKAudioPlayer()
        audioPlayer.meteringEnabled = true
        audioPlayer.volume = 1
        audioPlayer.delegate = self
        
        
    }
    
    func prepareTimer() {
        if playTimer == nil {
            playTimer = Timer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            RunLoop.current.add(playTimer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    
    //MARK: load songs
    func loadSongs() {
        let programID = "6938"
        api.fetch_songs(programID, isVIP: true, onSuccess: {[weak self] (items) in
            
            if items.count > 0 {
                let songs = items as! [Song]
                self?.dataSource = songs
                PlaylistManager.playlist.saveList(songs)
                
                self?.tableView.reloadData()
            }else {
                debugPrint("This program has no songs")
            }
            
            }, onFailed: nil)
    }
    
    //MARK: events
    func playButtonPressed() {
        
        if audioPlayer.state == .paused {
            audioPlayer.resume()
        }
        else if audioPlayer.state == .playing {
            audioPlayer.pause()
        } else {
            HudManager.showText("Opps~还没有播放的音乐。")
        }
        
        
        
        
    }

    func prevButtonPressed() {
        if currentIndex == 0 {
            currentIndex = dataSource.count-1
        }else {
            currentIndex -= 1
        }
        audioPlayer.pause()
        playMusic()
    }
    
    func nextButtonPressed() {
        
        if currentIndex == dataSource.count-1 {
            currentIndex = 0
        }else {
            currentIndex += 1
        }
        audioPlayer.pause()
        playMusic()
        
    }
    
    func playSliderChanged() {
        audioPlayer.seek(toTime: Double(playSlider.value))
    }
    
    func timerAction() {
        playSlider.maximumValue = (Float)(audioPlayer.duration)
        playSlider.value = (Float)(audioPlayer.progress)
        
    }
    
    //MARK: others
    func playMusic() {
        
        let currentSong = dataSource[currentIndex]
        audioPlayer.play(currentSong.audioURL!)
        
    }
}


extension StreamingKitViewController: STKAudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        debugPrint("queueid: \(queueItemId)")
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        debugPrint("didFinishBufferingSourceWithQueueItemId")
        
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        debugPrint("didFinishPlayingQueueItemId")
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        debugPrint("stateChanged: \(state)")
        
        if state == .playing {
            playButton.setTitle("Pause", for: UIControlState())
        }
        else if state == .paused {
            playButton.setTitle("Play", for: UIControlState())
        }
        else if state == .stopped {
            nextButtonPressed()
        }
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        debugPrint("unexpectedError")
    }
    
    
}


extension StreamingKitViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        let song = dataSource[(indexPath as NSIndexPath).row]
        
        cell?.textLabel!.text = song.songName
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if currentIndex == (indexPath as NSIndexPath).row {
            return
        }
        
        reset()
        
        currentIndex = (indexPath as NSIndexPath).row
        playMusic()
        
        
    }
    
    func reset() {
        playSlider.maximumValue = 0
        playSlider.value = 0
        playButton.setTitle("Play", for: UIControlState())
    }

}







