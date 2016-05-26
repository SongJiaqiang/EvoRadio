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
    
    var soundQueue: AFSoundQueue?
    var soundItems = [AFSoundItem]()
    
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
    
    override init() {
        super.init()
        
        soundQueue?.listenFeedbackUpdatesWithBlock({ (currentItem) in
            print("\(currentItem.duration) - \(currentItem.timePlayed)")
            }, andFinishedBlock: { (nextItem) in
                
                print("finished and next one")
        })
    }
    
    func addMusicToList(filePath: String) {
        
        let soundItem = AFSoundItem(localResource: "", atPath: filePath)
        
        soundItems.append(soundItem)
        if let soundQueue = soundQueue {
            soundQueue.addItem(soundItem)
        }else {
            soundQueue = AFSoundQueue(items: soundItems)
            
            soundQueue!.listenFeedbackUpdatesWithBlock({ (currentItem) in
                
                print("\(currentItem.duration) - \(currentItem.timePlayed)")
                
                }, andFinishedBlock: { (nextItem) in
                    
                    print("finished and next one")
            })
        }
        
        
//        soundQueue?.playItem(soundItems.last)
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
    
    func playItem() {
        soundQueue?.playCurrentItem()
        updatePlayingInfo()
    }
    
    func pauseItem() {
        soundQueue?.pause()
    }
    
    func playNext() {
        soundQueue?.playNextItem()
        updatePlayingInfo()
    }
    
    func playPrev() {
        soundQueue?.playPreviousItem()
        updatePlayingInfo()
    }
    
    
}