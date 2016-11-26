//
//  NotificationManager.swift
//  EvoRadio
//
//  Created by Jarvis on 5/27/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

//  开始播放
let NOTI_PLAYMUSICPROGRESS_STARTED = Notification.Name("play_music_progress_started")
// 播放中
let NOTI_PLAYMUSICPROGRESS_CHANGED = Notification.Name("play_music_progress_changed")
// 播放结束
let NOTI_PLAYMUSICPROGRESS_ENDED = Notification.Name("play_music_progress_ended")
// 播放暂停
let NOTI_PLAYMUSICPROGRESS_PAUSED = Notification.Name("play_music_progress_paused")
// 更新播放控制器
let NOTI_UPDATE_PLAYER = Notification.Name("update_player")
// 下载列表发生变化
let NOTI_DOWNLOADING_LIST_CHANGED = Notification.Name("downloading_list_changed")
// 已下载列表发生变化
let NOTI_DOWNLOADED_LIST_CHANGED = Notification.Name("downloaded_list_changed")
// 下载一首歌曲文件成功
let NOTI_DOWNLOAD_A_SONG_FINISHED = Notification.Name("download_a_song_finished")



class NotificationManager {
    
    //MARK: instance
    open static let shared = NotificationManager()
    
    func removeObserver(_ observer: AnyObject) {
        NotificationCenter.default.removeObserver(observer)
    }
    
    func removeObserver(_ observer: AnyObject, name: Notification.Name) {
        NotificationCenter.default.removeObserver(observer, name: name, object: nil)
    }
    
    func postPlayMusicProgressStartedNotification() {
        NotificationCenter.default.post(name: NOTI_PLAYMUSICPROGRESS_STARTED, object: nil, userInfo: nil)
    }
    func addPlayMusicProgressStartedObserver(_ target: AnyObject, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_STARTED, object: nil)
    }
    
    func postPlayMusicProgressChangedNotification(_ userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: NOTI_PLAYMUSICPROGRESS_CHANGED, object: nil, userInfo: userInfo)
    }
    func addPlayMusicProgressChangedObserver(_ target: AnyObject, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_CHANGED, object: nil)
    }
    
    func postPlayMusicProgressEndedNotification() {
        NotificationCenter.default.post(name: NOTI_PLAYMUSICPROGRESS_ENDED, object: nil, userInfo: nil)
    }
    func addPlayMusicProgressEndedObserver(_ target: AnyObject, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_ENDED, object: nil)
    }
    
    func postPlayMusicProgressPausedNotification() {
        NotificationCenter.default.post(name: NOTI_PLAYMUSICPROGRESS_PAUSED, object: nil)
    }
    func addPlayMusicProgressPausedObserver(_ target: AnyObject, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: NOTI_PLAYMUSICPROGRESS_PAUSED, object: nil)
    }
    
    func postUpdatePlayerNotification() {
        NotificationCenter.default.post(name: NOTI_UPDATE_PLAYER, object: nil)
    }
    func addUpdatePlayerObserver(_ target: AnyObject, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: NOTI_UPDATE_PLAYER, object: nil)
    }
    
    func postDownloadingListChangedNotification(_ userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: NOTI_DOWNLOADING_LIST_CHANGED, object: nil, userInfo: userInfo)
    }
    func addDownloadingListChangedObserver(_ target: AnyObject, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: NOTI_DOWNLOADING_LIST_CHANGED, object: nil)
    }
    
    func postDownloadedListChangedNotification(_ userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: NOTI_DOWNLOADED_LIST_CHANGED, object: nil, userInfo: userInfo)
    }
    func addDownloadedListChangedObserver(_ target: AnyObject, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: NOTI_DOWNLOADED_LIST_CHANGED, object: nil)
    }
    
    func postDownloadASongFinishedNotification(_ userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: NOTI_DOWNLOAD_A_SONG_FINISHED, object: nil, userInfo: userInfo)
    }
    func addDownloadASongFinishedObserver(_ target: AnyObject, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: NOTI_DOWNLOAD_A_SONG_FINISHED, object: nil)
    }
    
    
    
}
