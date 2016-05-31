//
//  MusicManager.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/21.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import AFSoundManager

class MusicManager: NSObject {
    
    private var soundQueue: AFSoundQueue?
    private var soundItems = [AFSoundItem]()
    var playlist = [Song]()
    var currentIndex: Int = -1
    
    //MARK: instance
    class var sharedManager: MusicManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: MusicManager! = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = MusicManager()
        }
        
        return Static.instance
    }
    
    func addMusicToList(filePath: String) -> Int {
        
        if indexOfItemWithPath(filePath) > 0 {
            return indexOfItemWithPath(filePath)
        }
        
        let soundItem = AFSoundItem(localResource: "", atPath: filePath)
        
        soundItems.append(soundItem)
        if let _ = soundQueue {
            soundQueue!.addItem(soundItem)
        }else {
            soundQueue = AFSoundQueue(items: soundItems)
            
            soundQueue!.listenFeedbackUpdatesWithBlock({ (currentItem) in
                let userInfo = [
                    "duration":currentItem.duration,
                    "timePlayed":currentItem.timePlayed
                ]
                
                NotificationManager.instance.postPlayMusicProgressChangedNotification(userInfo)
                
                }, andFinishedBlock: {[weak self] (nextItem) in
                    print("Finished and next one")
                    if let _ = nextItem {
                        NotificationManager.instance.postPlayMusicProgressEndedNotification(["nextItem":nextItem])
                    }else {
                        print("Haven't next")
                    }
                    self?.playNext()
                    
            })
        }
        
        return soundItems.count-1
    }
    
    func appendSongsToPlaylist(songs: [Song], autoPlay: Bool) {
        if songs.count == 0 {
            return
        }
        
        for song in songs {
            appendSongToPlaylist(song, autoPlay: false)
        }
        
        if autoPlay {
            currentIndex = playlist.indexOf(songs.first!)!
            NotificationManager.instance.postUpdatePlayerControllerNotification()
        }
    }
    
    func appendSongToPlaylist(song: Song, autoPlay: Bool){
        
        for item in playlist {
            if item.songID == song.songID {
                return
            }
        }
        playlist.append(song)
        
        if autoPlay {
            currentIndex = playlist.indexOf(song)!
            NotificationManager.instance.postUpdatePlayerControllerNotification()
        }
        
    }
    
    func clearList() {
        currentIndex = -1
        playlist.removeAll()
        soundQueue?.clearQueue()
    }
    
    func updatePlayingInfo() {
        
        if let currentItem = soundQueue?.getCurrentItem() {
            
            var title = ""
            if let _ = currentItem.title {
                title = currentItem.title
            }
            
            var artist = ""
            if let _ = currentItem.artist {
                artist = currentItem.artist
            }
            
            var artwork = MPMediaItemArtwork(image: UIImage(named: "placeholder_cover")!)
            if let _ = currentItem.artwork {
                artwork = MPMediaItemArtwork(image:currentItem.artwork)
            }
            
            let info: [String:AnyObject] = [MPMediaItemPropertyTitle: title,
                                            MPMediaItemPropertyArtist: artist,
                                            MPMediaItemPropertyArtwork: artwork
            ]
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
        }
    }
    
    func playItemAtIndex(index: Int) {
        soundQueue?.status = .Playing
        soundQueue?.playItemAtIndex(index)
        updatePlayingInfo()
    }
    
    func playItem() {
        soundQueue?.status = .Playing
        soundQueue?.playCurrentItem()
        updatePlayingInfo()
    }
    
    func pauseItem() {
        soundQueue?.status = .Paused
        soundQueue?.pause()
    }
    
    func playNext() {
//        soundQueue?.status = .Playing
//        if soundQueue?.getCurrentItem() == soundItems.last {
//            soundQueue?.playItemAtIndex(0)
//        }else {
//            soundQueue?.playNextItem()
//        }
//        updatePlayingInfo()
        
        incrementIndex()
        NotificationManager.instance.postUpdatePlayerControllerNotification()
    }
    
    func playPrev() {
//        soundQueue?.status = .Playing
//        if soundQueue?.indexOfCurrentItem() == 0 {
//            soundQueue?.playItemAtIndex(soundItems.count-1)
//        }else {
//            soundQueue?.playPreviousItem()
//        }
//        updatePlayingInfo()
        
        decrementIndex()
        NotificationManager.instance.postUpdatePlayerControllerNotification()
    }
    
    func isPlaying() -> Bool{
        if soundQueue?.status == .Playing {
            return true
        }else {
            return false
        }
    }
    
    
    func isPlayingOfSong(filePath: String) -> Bool {
        if let cItem = soundQueue?.getCurrentItem() {
            return cItem.URL.absoluteString.containsString(filePath)
        }else {
            return false
        }
    }
    
    func indexOfItemWithPath(filePath: String) -> Int {
        for item in soundItems {
            if item.URL.path?.containsString(filePath) == true {
                return soundItems.indexOf(item)!
            }
        }
        
        return -1
    }
    
    func playAtSecond(second: Int) {
        soundQueue?.playAtSecond(second)
    }
    
    func currentItem() -> AFSoundItem? {
        if let cItem = soundQueue?.getCurrentItem() {
            return cItem
        }else {
            return nil
        }
    }
    
    func currentSong() -> Song? {
        print("Play music at index \(currentIndex)")
        if currentIndex < 0 {
            return nil
        }else {
            return playlist[currentIndex]
        }
    }
    
    func incrementIndex() {
        currentIndex += 1
        if currentIndex >= playlist.count {
            currentIndex = 0
        }
    }
    
    func decrementIndex() {
        currentIndex -= 1
        if currentIndex < 0 {
            currentIndex = playlist.count-1
        }
    }
    
}