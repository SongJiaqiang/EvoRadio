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
    var playTimer: NSTimer?
    
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
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(view.snp_top)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(controlView.snp_top)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    func prepareControlView() {
        
        view.addSubview(controlView)
        controlView.backgroundColor = UIColor(netHex: 0x414141)
        controlView.snp_makeConstraints { (make) in
            make.bottom.equalTo(view.snp_bottom)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.height.equalTo(100)
        }
        
        
        controlView.addSubview(playButton)
        playButton.setTitle("Play", forState: .Normal)
        playButton.addTarget(self, action: #selector(playButtonPressed), forControlEvents: .TouchUpInside)
        playButton.snp_makeConstraints { (make) in
            make.center.equalTo(controlView.snp_center)
        }
        
        let prevButton = UIButton()
        controlView.addSubview(prevButton)
        prevButton.setTitle("<", forState: .Normal)
        prevButton.addTarget(self, action: #selector(prevButtonPressed), forControlEvents: .TouchUpInside)
        prevButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(controlView.snp_centerY)
            make.right.equalTo(playButton.snp_left).offset(-20)
        }
        
        let nextButton = UIButton()
        controlView.addSubview(nextButton)
        nextButton.setTitle(">", forState: .Normal)
        nextButton.addTarget(self, action: #selector(nextButtonPressed), forControlEvents: .TouchUpInside)
        nextButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.centerY.equalTo(controlView.snp_centerY)
            make.left.equalTo(playButton.snp_right).offset(20)
        }
        
        
        controlView.addSubview(playSlider)
        playSlider.addTarget(self, action: #selector(playSliderChanged), forControlEvents: .ValueChanged)
        playSlider.minimumValue = 0
        playSlider.maximumValue = 0
        playSlider.snp_makeConstraints { (make) in
            make.left.equalTo(controlView.snp_left).offset(20)
            make.right.equalTo(controlView.snp_right).offset(-20)
            make.top.equalTo(controlView.snp_top)
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
            playTimer = NSTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(playTimer!, forMode: NSRunLoopCommonModes)
        }
    }
    
    
    //MARK: load songs
    func loadSongs() {
        let programID = "6938"
        api.fetch_songs(programID, isVIP: true, onSuccess: {[weak self] (items) in
            
            if items.count > 0 {
                let songs = items as! [Song]
                self?.dataSource = songs
                PlaylistManager.instance.saveList(songs)
                
                self?.tableView.reloadData()
            }else {
                debugPrint("This program has no songs")
            }
            
            }, onFailed: nil)
    }
    
    //MARK: events
    func playButtonPressed() {
        
        if audioPlayer.state == .Paused {
            audioPlayer.resume()
        }
        else if audioPlayer.state == .Playing {
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
        audioPlayer.seekToTime(Double(playSlider.value))
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
    func audioPlayer(audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        debugPrint("queueid: \(queueItemId)")
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        debugPrint("didFinishBufferingSourceWithQueueItemId")
        
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        debugPrint("didFinishPlayingQueueItemId")
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        debugPrint("stateChanged: \(state)")
        
        if state == .Playing {
            playButton.setTitle("Pause", forState: .Normal)
        }
        else if state == .Paused {
            playButton.setTitle("Play", forState: .Normal)
        }
        else if state == .Stopped {
            nextButtonPressed()
        }
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        debugPrint("unexpectedError")
    }
    
    
}


extension StreamingKitViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        
        let song = dataSource[indexPath.row]
        
        cell?.textLabel!.text = song.songName
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if currentIndex == indexPath.row {
            return
        }
        
        reset()
        
        currentIndex = indexPath.row
        playMusic()
        
        
    }
    
    func reset() {
        playSlider.maximumValue = 0
        playSlider.value = 0
        playButton.setTitle("Play", forState: .Normal)
    }

}







