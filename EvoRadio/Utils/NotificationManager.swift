//
//  NotificationManager.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 5/27/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation


let NOTI_PLAYMUSICPROGRESS_CHANGED = "play_music_progress_changed"
let NOTI_PLAYMUSICPROGRESS_ENDED = "play_music_progress_ended"

class NotificationManager {
    
    //MARK: instance
    class var instance: NotificationManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: NotificationManager! = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = NotificationManager()
        }
        return Static.instance
    }
    
    func removeObserver(observer: AnyObject) {
        Device.defaultNotificationCenter().removeObserver(observer)
    }
    
    func removeObserver(observer: AnyObject, name: String) {
        Device.defaultNotificationCenter().removeObserver(observer, name: name, object: nil)
    }
    
    func postPlayMusicProgressChangedNotification(userInfo: [NSObject : AnyObject]) {
        Device.defaultNotificationCenter().postNotificationName(NOTI_PLAYMUSICPROGRESS_CHANGED, object: nil, userInfo: userInfo)
    }
    func addPlayMusicProgressChangedObserver(target: AnyObject, action: Selector) {
        Device.defaultNotificationCenter().addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_CHANGED, object: nil)
    }
    
    func postPlayMusicProgressEndedNotification(userInfo: [NSObject : AnyObject]) {
        Device.defaultNotificationCenter().postNotificationName(NOTI_PLAYMUSICPROGRESS_ENDED, object: nil, userInfo: userInfo)
    }
    func addPlayMusicProgressEndedObserver(target: AnyObject, action: Selector) {
        Device.defaultNotificationCenter().addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_ENDED, object: nil)
    }
    
    
    
    
}