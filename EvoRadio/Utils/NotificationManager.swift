//
//  NotificationManager.swift
//  EvoRadio
//
//  Created by Jarvis on 5/27/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

//  开始播放
let NOTI_PLAYMUSICPROGRESS_STARTED = "play_music_progress_started"
// 播放中
let NOTI_PLAYMUSICPROGRESS_CHANGED = "play_music_progress_changed"
// 播放结束
let NOTI_PLAYMUSICPROGRESS_ENDED = "play_music_progress_ended"
// 播放暂停
let NOTI_PLAYMUSICPROGRESS_PAUSED = "play_music_progress_paused"
// 更新播放控制器
let NOTI_UPDATE_PLAYERCONTROLLER = "update_playercontroller"
// 下载列表发生变化
let NOTI_DOWNLOADING_LIST_CHANGED = "downloading_list_changed"
// 已下载列表发生变化
let NOTI_DOWNLOADED_LIST_CHANGED = "downloaded_list_changed"
// 下载一首歌曲文件成功
let NOTI_DOWNLOAD_A_SONG_FINISHED = "download_a_song_finished"



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
    
    func postPlayMusicProgressStartedNotification(userInfo: [NSObject : AnyObject]) {
        Device.defaultNotificationCenter().postNotificationName(NOTI_PLAYMUSICPROGRESS_STARTED, object: nil, userInfo: userInfo)
    }
    func addPlayMusicProgressStartedObserver(target: AnyObject, action: Selector) {
        Device.defaultNotificationCenter().addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_STARTED, object: nil)
    }
    
    func postPlayMusicProgressChangedNotification(userInfo: [NSObject : AnyObject]) {
        Device.defaultNotificationCenter().postNotificationName(NOTI_PLAYMUSICPROGRESS_CHANGED, object: nil, userInfo: userInfo)
    }
    func addPlayMusicProgressChangedObserver(target: AnyObject, action: Selector) {
        Device.defaultNotificationCenter().addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_CHANGED, object: nil)
    }
    
    func postPlayMusicProgressEndedNotification() {
        Device.defaultNotificationCenter().postNotificationName(NOTI_PLAYMUSICPROGRESS_ENDED, object: nil, userInfo: nil)
    }
    func addPlayMusicProgressEndedObserver(target: AnyObject, action: Selector) {
        Device.defaultNotificationCenter().addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_ENDED, object: nil)
    }
    
    func postPlayMusicProgressPausedNotification() {
        Device.defaultNotificationCenter().postNotificationName(NOTI_PLAYMUSICPROGRESS_PAUSED, object: nil)
    }
    func addPlayMusicProgressPausedObserver(target: AnyObject, action: Selector) {
        Device.defaultNotificationCenter().addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_PAUSED, object: nil)
    }
    
    func postUpdatePlayerControllerNotification() {
        Device.defaultNotificationCenter().postNotificationName(NOTI_UPDATE_PLAYERCONTROLLER, object: nil)
    }
    func addUpdatePlayerControllerObserver(target: AnyObject, action: Selector) {
        Device.defaultNotificationCenter().addObserver(target, selector: action, name: NOTI_UPDATE_PLAYERCONTROLLER, object: nil)
    }
    
    func postDownloadingListChangedNotification(userInfo: [NSObject : AnyObject]) {
        Device.defaultNotificationCenter().postNotificationName(NOTI_DOWNLOADING_LIST_CHANGED, object: nil, userInfo: userInfo)
    }
    func addDownloadingListChangedObserver(target: AnyObject, action: Selector) {
        Device.defaultNotificationCenter().addObserver(target, selector: action, name: NOTI_DOWNLOADING_LIST_CHANGED, object: nil)
    }
    
    func postDownloadASongFinishedNotification(userInfo: [NSObject : AnyObject]) {
        Device.defaultNotificationCenter().postNotificationName(NOTI_DOWNLOAD_A_SONG_FINISHED, object: nil, userInfo: userInfo)
    }
    func addDownloadASongFinishedObserver(target: AnyObject, action: Selector) {
        Device.defaultNotificationCenter().addObserver(target, selector: action, name: NOTI_DOWNLOAD_A_SONG_FINISHED, object: nil)
    }
    
    
    
}