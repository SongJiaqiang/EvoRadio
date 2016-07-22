//
//  MusicManager.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/21.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import StreamingKit
import MediaPlayer
import Kingfisher

enum SoundQueuePlayMode: String {
    case ListLoop = "list_loop"
    case SingleLoop = "single_loop"
    case Random = "random"
}

class MusicManager: NSObject {
    
    var audioPlayer: STKAudioPlayer = STKAudioPlayer()
    private var playTimer: NSTimer?

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
            playItem()
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
            playItem()
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
    
    // 更新控制中心上的音乐信息 - 标题、专辑等
    func updatePlayingInfo() {
        
        if let song = currentSong() {
            
            var title = ""
            if let songName = song.songName {
                title = songName
            }
            
            var artist = ""
            if let artistsName = song.artistsName {
                artist = artistsName
            }
            
            var duration: Double = 0
            if let d = song.duration {
                duration = Double(d)!
            }
            
            var artwork = MPMediaItemArtwork(image: UIImage(named: "placeholder_cover")!)
            if let _ = song.picURL {
                let downloader = KingfisherManager.sharedManager.downloader
                downloader.downloadImageWithURL(NSURL(string: song.picURL!)!, options: nil, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
                    if let _ = image {
                        artwork = MPMediaItemArtwork(image:image!)
                    }
                    
                    let info: [String:AnyObject] = [MPMediaItemPropertyTitle: title,
                        MPMediaItemPropertyArtist: artist,
                        MPMediaItemPropertyArtwork: artwork,
                        MPMediaItemPropertyPlaybackDuration: duration
                    ]
                    MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
                })
            }
        }
    }
    
    // 更新控制中心上的音乐信息 - 时间
    func updatePlaybackTime(elapsedTime: Double) {
        if let info = MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo {
            var playingInfo:[String:AnyObject] = info
            playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = playingInfo
        }
    }
    
    func playItemAtIndex(index: Int) {
        currentIndex = index
        
        audioPlayer.pause()
        playItem()
        
    }
    
    func playItem() {
        
        if let cSong = currentSong() {
            let audioURL = cSong.audioURL
            audioPlayer.play(audioURL!)
            
            // 更新控制中心的音乐播放信息
            updatePlayingInfo()
            // 缓存播放列表
            saveLastPlaylist()
            // 缓存历史播放歌曲
            CoreDB.addSongToHistoryList(currentSong()!)
            
            NotificationManager.instance.postUpdatePlayerControllerNotification()
        }
        
    }
    
    func pauseItem() {
        if audioPlayer.state == .Playing {
            audioPlayer.pause()
        }
    }
    
    func resumeItem() {
        if audioPlayer.state == .Paused {
            audioPlayer.resume()
        }
    }
    
    
    func playNext() {
        incrementIndex()
        
        audioPlayer.pause()
        playItem()
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
        
        audioPlayer.pause()
        playItem()
    }
    
    func isPlaying() -> Bool{
        if audioPlayer.state == .Playing {
            return true
        }else {
            return false
        }
    }
    
    func isStoped() -> Bool{
        if audioPlayer.state == .Stopped {
            return true
        }else {
            return false
        }
    }
    
    
//    func isPlayingOfSong(filePath: String) -> Bool {
//        if let cItem = soundQueue?.getCurrentItem() {
//            return cItem.URL.absoluteString.containsString(filePath)
//        }else {
//            return false
//        }
//    }
//    
//    func indexOfItemWithPath(filePath: String) -> Int {
//        for item in soundItems {
//            if item.URL.path?.containsString(filePath) == true {
//                return soundItems.indexOf(item)!
//            }
//        }
//        
//        return -1
//    }
    
    func playAtSecond(second: Int) {
        audioPlayer.seekToTime(Double(second))
    }
    
    func currentSong() -> Song? {
        if currentIndex < 0 || playlist.count <= 0 {
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
