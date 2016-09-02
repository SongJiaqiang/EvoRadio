//
//  CoreDB.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation

let DB_ALLCHANNELS = "all_channels"
let DB_ALLNOWCHANNELS = "all_now_channels"
let DB_CUSTOMRADIOS = "custom_radios"
let DB_PROGRAMS = "programs"
let DB_GROUND_PROGRAMS = "ground_programs"
let DB_SONGS = "songs"
let DB_SELECTEDINDEXES = "selected_indexes"
let DB_PLAYLSIT = "playlist"
let DB_LAST_PLAYLSIT = "last_playlist"
let DB_DOWNLOADED_LIST = "downloaded_list"
let DB_DOWNLOADING_LIST = "downloading_list"
let DB_HISTORY_LIST = "history_list"
let DB_PLAY_MODE = "play_mode"


let leveldb: WLevelDb = WLevelDb.sharedDb()

class CoreDB {
    
    class func clearAll() {
        CoreDB.clearHistory()
        CoreDB.clearDownloadedList()
        CoreDB.clearDownloadingList()
    }
    
    class func saveAllChannels(responseData: [[String : AnyObject]]) {
        WLevelDb.sharedDb().setObject(responseData, forKey: DB_ALLCHANNELS)
    }
    
    class func getAllChannels() -> [[String : AnyObject]]?{
        let responseData = WLevelDb.sharedDb().objectForKey(DB_ALLCHANNELS)
        if let _ = responseData {
            return responseData as? [[String : AnyObject]]
        }
        return nil
    }
    class func saveAllNowChannels(responseData: [[String : AnyObject]]) {
        WLevelDb.sharedDb().setObject(responseData, forKey: DB_ALLNOWCHANNELS)
    }
    
    class func getAllNowChannels() -> [[String : AnyObject]]?{
        let responseData = WLevelDb.sharedDb().objectForKey(DB_ALLNOWCHANNELS)
        if let _ = responseData {
            return responseData as? [[String : AnyObject]]
        }
        return nil
    }
    
    class func savePrograms(endpoint: String, responseData: [[String : AnyObject]]) {
        WLevelDb.sharedDb().setObject(responseData, forKey: DB_PROGRAMS+endpoint)
    }
    
    class func getPrograms(endpoint: String) -> [[String : AnyObject]]?{
        let responseData = WLevelDb.sharedDb().objectForKey(DB_PROGRAMS+endpoint)
        if let _ = responseData {
            return responseData as? [[String : AnyObject]]
        }
        return nil
    }
    
    class func saveGroundPrograms(endpoint: String, responseData: [[String : AnyObject]]) {
        WLevelDb.sharedDb().setObject(responseData, forKey: DB_GROUND_PROGRAMS+endpoint)
    }
    
    class func getGroundPrograms(endpoint: String) -> [[String : AnyObject]]?{
        let responseData = WLevelDb.sharedDb().objectForKey(DB_GROUND_PROGRAMS+endpoint)
        if let _ = responseData {
            return responseData as? [[String : AnyObject]]
        }
        return nil
    }
    
    class func saveSongs(endpoint: String, responseData: [[String : AnyObject]]) {
        WLevelDb.sharedDb().setObject(responseData, forKey: DB_SONGS+endpoint)
    }
    
    class func getSongs(endpoint: String) -> [[String : AnyObject]]?{
        let responseData = WLevelDb.sharedDb().objectForKey(DB_SONGS+endpoint)
        if let _ = responseData {
            return responseData as? [[String : AnyObject]]
        }
        return nil
    }
    
    
    class func saveCustomRadios(customRadios: [[String: AnyObject]]) {
        WLevelDb.sharedDb().setObject(customRadios, forKey: DB_CUSTOMRADIOS)
    }
    
    class func getCustomRadios() -> [[String: AnyObject]]{
        let customRadios = WLevelDb.sharedDb().objectForKey(DB_CUSTOMRADIOS)
        if let _ = customRadios {
            return customRadios as! [[String : AnyObject]]
        }
        return [
            ["radio_id": NSNumber(int: 1), "radio_name": "活动"],
            ["radio_id": NSNumber(int: 2), "radio_name": "情绪"],
            ["radio_id": NSNumber(int: 6), "radio_name": "餐饮"]
        ]
    }
    
    class func getAllDaysOfWeek() -> [String] {
        return ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"]
    }
    
    class func currentDayOfWeek() -> Int {
        return NSDate.getSomeDate([.Weekday])-1
    }
    class func currentDayOfWeekString() -> String {
        return CoreDB.getAllDaysOfWeek()[CoreDB.currentDayOfWeek()]
    }
    
    class func getAllTimesOfDay() -> [String] {
        return ["清晨","上午","中午","下午","傍晚","晚上","午夜","凌晨"]
    }
    
    class func currentTimeOfDay() -> Int {
        let hour = NSDate.getSomeDate([.Hour])
        
        var timeIndex = 0
        if hour >= 5 && hour <= 6 {
            timeIndex = 0
        }
        else if hour >= 7 && hour <= 11 {
            timeIndex = 1
        }
        else if hour >= 12 && hour <= 13 {
            timeIndex = 2
        }
        else if hour >= 14 && hour <= 16 {
            timeIndex = 3
        }
        else if hour >= 17 && hour <= 19 {
            timeIndex = 4
        }
        else if hour >= 20 && hour <= 23 {
            timeIndex = 5
        }
        else if hour >= 0 && hour <= 1 {
            timeIndex = 6
        }
        else if hour >= 2 && hour <= 4 {
            timeIndex = 7
        }
        
        return timeIndex
    }
    
    class func currentTimeOfDayString() -> String {
        return CoreDB.getAllTimesOfDay()[CoreDB.currentTimeOfDay()]
    }
    
    class func saveSelectedIndexes(indexes: [String : Int]) {
        WLevelDb.sharedDb().setObject(indexes, forKey: DB_SELECTEDINDEXES)
    }
    
    class func getSelectedIndexes() -> [String : Int]? {
        if let indexes = WLevelDb.sharedDb().objectForKey(DB_SELECTEDINDEXES) {
            return indexes as? [String : Int]
        }else {
            return nil
        }
    }
    // 清除选择时刻缓存
    class func clearSelectedIndexes() {
        WLevelDb.sharedDb().removeObjectForKey(DB_SELECTEDINDEXES)
    }
    
    
    // 存储播放列表
    class func savePlaylist(songs: [Song]) {
        let songsDict = songs.toDictionaryArray()
        WLevelDb.sharedDb().setObject(songsDict, forKey: DB_PLAYLSIT)
    }
    /** 获取播放列表 */
    class func getPlaylist() -> [Song] {
        var songs = [Song]()
        if let songsDict = leveldb.objectForKey(DB_PLAYLSIT) {
            songs = [Song](dictArray: songsDict as? [NSDictionary])
        }
        
        return songs
    }
    
    /** 保存最后的播放列表 */
    class func saveLastPlaylist(playlist:[Song], indexOfPlaylist: Int, timePlayed: Int) {
        let lastPlaylist = LastPlaylist(list: playlist, index: indexOfPlaylist, time: timePlayed)
        let playlistDict = lastPlaylist.toDictionary()
        
        WLevelDb.sharedDb().setObject(playlistDict, forKey: DB_LAST_PLAYLSIT)
    }
    
    /** 获取上次的播放列表 */
    class func getLastPlaylist() -> LastPlaylist? {
        if let lastPlaylist = leveldb.objectForKey(DB_LAST_PLAYLSIT) {
            return LastPlaylist(dictionary: lastPlaylist as! NSDictionary)
        }
        return nil
    }
    
    /** 已下载的歌曲数据 */
    class func addSongToDownloadedList(song: Song) {
        let dict = song.toDictionary()
        var newSongs: [NSDictionary]
        if let songs = leveldb.objectForKey(DB_DOWNLOADED_LIST) {
            for item in (songs as! [NSDictionary]) {
                if (item["song_id"] as! String) == song.songID {
                    return
                }
            }
            newSongs = songs as! [NSDictionary]
        }else {
            newSongs = [NSDictionary]()
        }
        newSongs.append(dict)
        leveldb.setObject(newSongs, forKey: DB_DOWNLOADED_LIST)
    }
    
    /** 获取已下载歌曲数据 */
    class func getDownloadedSongs() -> [Song]? {
        if let songs = leveldb.objectForKey(DB_DOWNLOADED_LIST) {
            return [Song](dictArray: songs as? [NSDictionary])
        }
        
        return nil
    }
    
    /** 获取已下载歌单数据 */
    class func getDownloadedPrograms() -> [Program] {
        let programs = [Program]()
        
        if let songs = leveldb.objectForKey(DB_DOWNLOADED_LIST) {
            
            (songs as! [NSDictionary])
            
//            for song in songs {
//                var songList =
//            }
            
        }
        
        return programs
    }
    
    /** 添加歌曲下载 */
    class func addSongToDownloadingList(song: Song) {
        let dict = song.toDictionary()
        var newSongs: [NSDictionary]
        if let songs = leveldb.objectForKey(DB_DOWNLOADING_LIST) {
            for item in (songs as! [NSDictionary]) {
                if (item["song_id"] as! String) == song.songID {
                    return
                }
            }
            newSongs = songs as! [NSDictionary]
        }else {
            newSongs = [NSDictionary]()
        }
        newSongs.append(dict)
        leveldb.setObject(newSongs, forKey: DB_DOWNLOADING_LIST)
        
        NotificationManager.instance.postDownloadingListChangedNotification(["songs":[Song](dictArray:newSongs)])
    }
    
    /** 添加一波歌曲下载 */
    class func addSongsToDownloadingList(songs: [Song]) {
        var newSongs: [NSDictionary]
        if let songsArray = leveldb.objectForKey(DB_DOWNLOADING_LIST) {
            newSongs = songsArray as! [NSDictionary]
            for song in songs {
                var isExit = false
                for item in (songsArray as! [NSDictionary]) {
                    if (item["song_id"] as! String) == song.songID {
                        isExit = true
                        break
                    }
                }
                if !isExit {
                    let dict = song.toDictionary()
                    newSongs.append(dict)
                }
            }
        }else {
            newSongs = [NSDictionary]()
        }
        
        leveldb.setObject(newSongs, forKey: DB_DOWNLOADING_LIST)
        
        NotificationManager.instance.postDownloadingListChangedNotification(["songs":[Song](dictArray:newSongs)])
    }
    
    /** 删除一首歌曲下载数据 */
    class func removeSongFromDownloadingList(song: Song) {
        var newSongs: [NSDictionary]
        if let songs = leveldb.objectForKey(DB_DOWNLOADING_LIST) {
            newSongs = songs as! [NSDictionary]
            for item in newSongs {
                if (item["song_id"] as! String) == song.songID {
                    newSongs.removeAtIndex(newSongs.indexOf(item)!)
                    break
                }
            }
        }else {
            newSongs = [NSDictionary]()
        }
        leveldb.setObject(newSongs, forKey: DB_DOWNLOADING_LIST)
        
        NotificationManager.instance.postDownloadingListChangedNotification(["songs":[Song](dictArray:newSongs)])
    }
    
    /** 删除所有歌曲下载数据 */
    class func removeAllFromDownloadingList() {
        if let _ = leveldb.objectForKey(DB_DOWNLOADING_LIST) {
            leveldb.removeObjectForKey(DB_DOWNLOADING_LIST)
        }
        
        NotificationManager.instance.postDownloadingListChangedNotification(["songs":[Song]()])
    }
    
    /** 获取正在下载的歌曲数据 */
    class func getDownloadingSongs() -> [Song]? {
        if let songs = leveldb.objectForKey(DB_DOWNLOADING_LIST) {
            return [Song](dictArray: songs as? [NSDictionary])
        }else {
            return nil
        }
    }
    
    class func clearDownloadedList() {
        leveldb.removeObjectForKey(DB_DOWNLOADED_LIST)
    }

    class func clearDownloadingList() {
        leveldb.removeObjectForKey(DB_DOWNLOADING_LIST)
    }
    
    /** 修改播放模式 */
    class func changePlayerPlayMode(mode: String) {
        leveldb.setObject(mode, forKey: DB_PLAY_MODE)
    }
    
    /** 获取当前播放模式 */
    class func playerPlayMode() -> String? {
        if let mode = leveldb.objectForKey(DB_PLAY_MODE) {
            return mode as? String
        }else {
            return nil
        }
    }
    
    class func getHistorySongs() -> [Song]? {
        if let songs = leveldb.objectForKey(DB_HISTORY_LIST) {
            return [Song](dictArray: songs as? [NSDictionary])
        }else {
            return nil
        }
    }
    
    
    class func addSongToHistoryList(song: Song) {
        let dict = song.toDictionary()
        var newSongs: [NSDictionary]
        if let songs = leveldb.objectForKey(DB_HISTORY_LIST) {
            newSongs = songs as! [NSDictionary]
            for item in newSongs {
                if (item["song_id"] as! String) == song.songID {
                    newSongs.removeAtIndex(newSongs.indexOf(item)!)
                    break
                }
            }
        }else {
            newSongs = [NSDictionary]()
        }
        newSongs.insert(dict, atIndex: 0)
        // The count can not exceed 100
        if newSongs.count > 100 {
            newSongs.removeLast()
        }
        leveldb.setObject(newSongs, forKey: DB_HISTORY_LIST)
    }
    
    class func clearHistory() {
        leveldb.removeObjectForKey(DB_HISTORY_LIST)
    }
    
    
}