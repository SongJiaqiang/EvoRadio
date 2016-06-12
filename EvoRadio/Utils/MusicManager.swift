//
//  MusicManager.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/21.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import AFSoundManager

enum SoundQueuePlayMode: String {
    case ListLoop = "list_loop"
    case SingleLoop = "single_loop"
    case Random = "random"
}

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
                    debugPrint("Finished and next one")
                    
                    NotificationManager.instance.postPlayMusicProgressEndedNotification()
                    self?.playNextWhenFinished()
                    
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
    
    func removeSongFromPlaylist(song: Song) {
        
        for item in playlist {
            if item.songID == song.songID {
                let index = playlist.indexOf(item)
                playlist.removeAtIndex(index!)
                if index < currentIndex {
                    currentIndex -= 1
                }
                return
            }
        }
    }
    
    func clearList() {
        currentIndex = -1
        playlist.removeAll()
//        soundQueue?.clearQueue()
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
        soundQueue?.playItemAtIndex(index)
        soundQueue?.status = .Playing
        
        CoreDB.addSongToHistoryList(currentSong()!)
        
        updatePlayingInfo()
        
    }
    
    func playItem() {
        soundQueue?.playCurrentItem()
        soundQueue?.status = .Playing
        
        CoreDB.addSongToHistoryList(currentSong()!)
        
        updatePlayingInfo()
    }
    
    func pauseItem() {
        soundQueue?.status = .Paused
        soundQueue?.pause()
    }
    
    func playNext() {
        incrementIndex()
        NotificationManager.instance.postUpdatePlayerControllerNotification()
    }
    
    func playNextWhenFinished() {
        let currentMode = currentPlayMode()
        if currentMode == .Random {
            currentIndex = Int(arc4random_uniform(UInt32(playlist.count)))
            NotificationManager.instance.postUpdatePlayerControllerNotification()
        }else if currentMode == .ListLoop {
            incrementIndex()
            NotificationManager.instance.postUpdatePlayerControllerNotification()
        }else {
            playAtSecond(0)
        }
    }
    
    func playPrev() {
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
    
    func loadLastPlaylist() {
        if let lastPlaylist = CoreDB.getLastPlaylist() {
            playlist = lastPlaylist.playlist!
            currentIndex = (lastPlaylist.indexOfPlaylist?.integerValue)!
            NotificationManager.instance.postUpdatePlayerControllerNotification()
        }
    }
    
    func saveLastPlaylist() {
        if playlist.count > 0 {
            CoreDB.saveLastPlaylist(playlist, indexOfPlaylist: currentIndex, timePlayed: 0)
        }
    }
    
    func changePlayMode() -> SoundQueuePlayMode {
        var newMode: SoundQueuePlayMode = .ListLoop
        if let mode = CoreDB.playerPlayMode() {
            switch mode {
            case SoundQueuePlayMode.ListLoop.rawValue:
                    newMode = .SingleLoop
            case SoundQueuePlayMode.SingleLoop.rawValue:
                newMode = .Random
            case SoundQueuePlayMode.Random.rawValue:
                newMode = .ListLoop
            default:
                break
            }
        }
        
        CoreDB.changePlayerPlayMode(newMode.rawValue)
        return newMode
    }
    
    func currentPlayMode() -> SoundQueuePlayMode {
        if let mode = CoreDB.playerPlayMode() {
            switch mode {
            case SoundQueuePlayMode.ListLoop.rawValue:
                return.ListLoop
            case SoundQueuePlayMode.SingleLoop.rawValue:
                return .SingleLoop
            case SoundQueuePlayMode.Random.rawValue:
                return .Random
            default:
                break
            }
        }
        return .ListLoop
    }
}