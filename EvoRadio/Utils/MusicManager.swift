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
                
                print("\(currentItem.duration) - \(currentItem.timePlayed)")
                let userInfo = [
                    "duration":currentItem.duration,
                    "timePlayed":currentItem.timePlayed
                ]
                
                NotificationManager.instance.postPlayMusicProgressChangedNotification(userInfo)
                
                }, andFinishedBlock: {[weak self] (nextItem) in
                    print("Finished and next one")
                    if nextItem == nil {
                        print("Haven't next")
                    }else {
                        NotificationManager.instance.postPlayMusicProgressEndedNotification(["nextItem":nextItem])
                    }
                    self?.playNext()
            })
        }
        
        return soundItems.count-1
    }
    
    func clearList() {
        soundQueue?.clearQueue()
    }
    
    func updatePlayingInfo() {
        
        let currentItem = soundQueue?.getCurrentItem()
        
        var title = ""
        if let _ = currentItem!.title {
            title = currentItem!.title
        }
        
        var artist = ""
        if let _ = currentItem!.artist {
            artist = currentItem!.artist
        }
        
        var artwork = MPMediaItemArtwork(image: UIImage(named: "placeholder_cover")!)
        if let _ = currentItem!.artwork {
            artwork = MPMediaItemArtwork(image:currentItem!.artwork)
        }
        
        let info: [String:AnyObject] = [MPMediaItemPropertyTitle: title,
                    MPMediaItemPropertyArtist: artist,
                    MPMediaItemPropertyArtwork: artwork
        ]
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
    }
    
    func playItemAtIndex(index: Int) {
        soundQueue?.playItemAtIndex(index)
        updatePlayingInfo()
    }
    
    func playItem() {
        soundQueue?.playCurrentItem()
        updatePlayingInfo()
    }
    
    func pauseItem() {
        soundQueue?.pause()
    }
    
    func playNext() {
        
        if soundQueue?.getCurrentItem() == soundItems.last {
            soundQueue?.playItemAtIndex(0)
        }else {
            soundQueue?.playNextItem()
        }
        
        updatePlayingInfo()
    }
    
    func playPrev() {
        if soundQueue?.indexOfCurrentItem() == 0 {
            soundQueue?.playItemAtIndex(soundItems.count-1)
        }else {
            soundQueue?.playPreviousItem()
        }
        updatePlayingInfo()
    }
    
    func isPlaying() -> Bool{
        if soundQueue?.status == .Playing {
            return true
        }else {
            return false
        }
    }
    
    
    func isPlayingOfSong(filePath: String) -> Bool {
        return (soundQueue?.getCurrentItem().URL.absoluteString.containsString(filePath))!
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
    
}