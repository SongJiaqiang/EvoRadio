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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum SoundQueuePlayMode: String {
    case ListLoop = "list_loop"
    case SingleLoop = "single_loop"
    case Random = "random"
}

class MusicManager: NSObject {
    
    
    // Singleton Instance
    open static let shared = MusicManager()
    
    //MARK: properties
    var audioPlayer: STKAudioPlayer!
    fileprivate var playTimer: Timer?

    var playlist = [Song]()
    var currentIndex: Int = -1
    
    override init() {
        super.init()
        
        audioPlayer = STKAudioPlayer()
        audioPlayer.meteringEnabled = true
        
        
    }

    //MARK: functions
    func appendSongsToPlaylist(_ songs: [Song], autoPlay: Bool) {
        if songs.count == 0 {
            return
        }
        
        for song in songs {
            appendSongToPlaylist(song, autoPlay: false)
        }
        
        if autoPlay {
            currentIndex = playlist.index(of: songs.first!)!
            NotificationManager.shared.postUpdatePlayerControllerNotification()
            play()
        }
    }
    
    func appendSongToPlaylist(_ song: Song, autoPlay: Bool){
        var exit = false
        for item in playlist {
            if item.songID == song.songID {
                exit = true
                break
            }
        }
        if exit == false {
            playlist.append(song)
        }
        
        if autoPlay {
            currentIndex = playlist.index(of: song)!
            play()
        }
        
    }
    
    func removeSongFromPlaylist(_ song: Song) {
        
        for item in playlist {
            if item.songID == song.songID {
                let index = playlist.index(of: item)
                playlist.remove(at: index!)
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
            
            if let picURL = URL(string: song.picURL!) {
                let downloader = KingfisherManager.shared.downloader

                downloader.downloadImage(with: picURL, options: nil, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
                    if let _ = image {
                        artwork = MPMediaItemArtwork(image:image!)
                    }
                    
                    let info: [String:AnyObject] = [MPMediaItemPropertyTitle: title as AnyObject,
                                                    MPMediaItemPropertyArtist: artist as AnyObject,
                                                    MPMediaItemPropertyArtwork: artwork,
                                                    MPMediaItemPropertyPlaybackDuration: duration as AnyObject
                    ]
                    
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                })
            }
        }
    }
    
    // 更新控制中心上的音乐信息 - 时间
    func updatePlaybackTime(_ elapsedTime: Double) {
        if let info = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            var playingInfo:[String:AnyObject] = info as [String : AnyObject]
            playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime as AnyObject?
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
        }
    }
    
    func playItemAtIndex(_ index: Int) {
        currentIndex = index
        
        audioPlayer.pause()
        play()
        
    }
    
    func play() {
        
        if let cSong = currentSong() {
            let audioURL = cSong.audioURL
            
            if let audioPath = self.findMusicFileCachedPath(cSong) {
                let url = URL(fileURLWithPath: audioPath)
                audioPlayer.play(url)
            }else {
                audioPlayer.play(audioURL!)
            }
            
            // 更新控制中心的音乐播放信息
            updatePlayingInfo()
            // 缓存播放列表
            saveLastPlaylist()
            // 缓存历史播放歌曲
            CoreDB.addSongToHistoryList(currentSong()!)
            
            NotificationManager.shared.postUpdatePlayerControllerNotification()
        }
        
    }
    
    func findMusicFileCachedPath(_ song: Song) -> String? {
        if song.audioURL?.isEmpty == true {
            return nil
        }
        
        let fileName = song.audioURL!.lastPathComponent()
        let downloadPath = MZUtility.baseFilePath.appendPathComponents(["downloads",song.programID!])
        let filePath = downloadPath.appendPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        
        return nil
    }
    
    func pause() {
        if audioPlayer.state == .playing {
            audioPlayer.pause()
        }
    }
    
    func resume() {
        if audioPlayer.state == .paused {
            audioPlayer.resume()
        }
    }
    
    
    func playNext() {
        incrementIndex()
        
        audioPlayer.pause()
        play()
    }
    
    func playNextWhenFinished() {
        let currentMode = currentPlayMode()
        if currentMode == .Random {
            currentIndex = Int(arc4random_uniform(UInt32(playlist.count)))
            play()
            NotificationManager.shared.postUpdatePlayerControllerNotification()
        }else if currentMode == .ListLoop {
            incrementIndex()
            play()
            NotificationManager.shared.postUpdatePlayerControllerNotification()
        }else {
            play()
        }
        
    }
    
    func playPrev() {
        decrementIndex()
        
        audioPlayer.pause()
        play()
    }
    
    func isPlaying() -> Bool{
        if audioPlayer.state == .playing {
            return true
        }else {
            return false
        }
    }
    
    func isPaused() -> Bool{
        if audioPlayer.state == .paused {
            return true
        }else {
            return false
        }
    }
    
    func isStoped() -> Bool{
        if audioPlayer.state == .stopped {
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
    
    func playAtSecond(_ second: Int) {
        audioPlayer.seek(toTime: Double(second))
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
            currentIndex = (lastPlaylist.indexOfPlaylist?.intValue)!
            NotificationManager.shared.postUpdatePlayerControllerNotification()
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
