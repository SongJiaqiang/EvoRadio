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
    
    // Singleton Instance
    public static let shared = MusicManager()
    
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
            
            if let first = songs.first {                
                if let index = indexOf(array: playlist, song: first) {
                    currentIndex = index
                }
            }
            
            NotificationManager.shared.postUpdatePlayerNotification()
            play()
        }
    }
    
    func appendSongToPlaylist(_ song: Song, autoPlay: Bool){
        var exit = false
        for item in playlist {
            if item.songId == song.songId {
                exit = true
                break
            }
        }
        
        if exit == false {
            playlist.append(song)
        }
        
        if autoPlay {
            if let index = indexOf(array: playlist, song: song) {
                currentIndex = index
            }
            
            play()
        }
        
        // 更新历史列表
        saveLastPlaylist()
    }
    
    func removeSongFromPlaylist(_ song: Song) {
        
        for item in playlist {
            if item.songId == song.songId {
                if let index = indexOf(array: playlist, song: item) {
                    playlist.remove(at: index)
                    if index < currentIndex {
                        currentIndex -= 1
                    }
                    return
                }
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
        func updateCoverInfo(title: String?, artist: String?, duration: TimeInterval?, image: UIImage?) {
            
            var info = [String:AnyObject]()
            
            info[MPMediaItemPropertyTitle] = (title == nil ? "Untitled" : title) as AnyObject
            info[MPMediaItemPropertyArtist] = (artist == nil ? "Anonymity" : artist) as AnyObject
            info[MPMediaItemPropertyPlaybackDuration] = (duration == nil ? 0 : duration) as AnyObject
            
            if let img = image {
                let artwork = MPMediaItemArtwork(image:img)
                info[MPMediaItemPropertyArtwork] = artwork
            }else {
                let artwork = MPMediaItemArtwork(image:UIImage.placeholder_cover())
                info[MPMediaItemPropertyArtwork] = artwork
            }
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
        
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
            
            if let picURLString = song.picURL {
                if let picURL = URL(string: picURLString) {
                    let downloader = KingfisherManager.shared.downloader
                    
                    downloader.downloadImage(with: picURL, options: nil, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
                        updateCoverInfo(title: title, artist: artist, duration: duration, image: image)
                    })
                }
            }else {
//                if let albumImage = song.albumImage {
//                    updateCoverInfo(title: title, artist: artist, duration: duration, image: albumImage)
//                }
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
    
    //MARK: - player control
    func play() {
        
        if let cSong = currentSong() {
            if let audioURL = cSong.audioURL {
                if let audioPath = self.findMusicFileCachedPath(cSong) {
                    let url = URL(fileURLWithPath: audioPath)
//                    audioPlayer.play(url)
                    let datasource = STKAudioPlayer.dataSource(from: url)
                    audioPlayer.setDataSource(datasource, withQueueItemId: SampleQueueId(url: url, count: 0))
                }else {
                    if let url = URL(string: audioURL) {
//                        audioPlayer.play(audioURL)
                        
                        let datasource = STKAudioPlayer.dataSource(from: url)
                        audioPlayer.setDataSource(datasource, withQueueItemId: SampleQueueId(url: url, count: 0))
                    }
                }
            }else {
//                if let url = cSong.assetURL {
////                    audioPlayer.play(url)
//                    
//                    let datasource = STKAudioPlayer.dataSource(from: url)
//                    audioPlayer.setDataSource(datasource, withQueueItemId: SampleQueueId(url: url, count: 0))
//                }
            }
            
            // 更新控制中心的音乐播放信息
            updatePlayingInfo()

            // 缓存历史播放歌曲
            CoreDB.addSongToHistoryList(currentSong()!)
            
            NotificationManager.shared.postUpdatePlayerNotification()
            NotificationCenter.default.post(name: .updateHistoryCount, object: nil)
            
            // 更新历史列表
            saveLastPlaylist()
        }
        
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
    
     // BUG：使用stop会自动跳转到下一曲，再增长序号播放，会出现跳曲的问题
    func playNext() {
        audioPlayer.pause()
        incrementIndex()
        play()
    }
    
    func playNextWhenFinished() {
        let currentMode = currentPlayMode()
        if currentMode == .Random {
            currentIndex = Int(arc4random_uniform(UInt32(playlist.count)))
            play()
            NotificationManager.shared.postUpdatePlayerNotification()
        }else if currentMode == .ListLoop {
            incrementIndex()
            play()
            NotificationManager.shared.postUpdatePlayerNotification()
        }else {
            play()
        }
        
    }
    
    func playPrev() {
        audioPlayer.pause()
        decrementIndex()
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
    
    //MARK: -
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
            currentIndex = lastPlaylist.indexOfPlaylist!
            
            print("Get Last play music: \(currentIndex) / \(playlist.count)")
            play()
            
        }
    }
    
    func saveLastPlaylist() {
        if playlist.count > 0 {
            print("Save Last play music: \(currentIndex) / \(playlist.count)")
            
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
    
    func indexOf(array: [Song], song: Song) -> Int? {
        
        for index in 0..<array.count {
            let item = array[index]
            if item.songId == song.songId {
                return index
            }
        }
        
        return nil
    }
    
    func indexOfPlaylist(song: Song) -> Int? {
        
        for index in 0..<playlist.count {
            let item = playlist[index]
            if item.songId == song.songId {
                return index
            }
        }
        
        return nil
    }
    
    func findMusicFileCachedPath(_ song: Song) -> String? {
        if song.audioURL?.isEmpty == true {
            return nil
        }
        
        guard let programId = song.programId else {
            return nil
        }
        
        let fileName = song.audioURL!.lastPathComponent()
        let downloadPath = MZUtility.baseFilePath.appendPathComponents(["downloads",programId])
        let filePath = downloadPath.appendPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: filePath) {
            return filePath
        }
        
        return nil
    }
}

final class SampleQueueId: NSObject {
    var count: Int
    var url: URL
    
    init(url:URL, count: Int) {
        self.count = count
        self.url = url
    }
}

