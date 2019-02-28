//
//  CoreDB.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper
import ObjcLevelDB

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
let DB_COLLECT_MUSIC_LIST = "collect_music_list"
let DB_PLAY_MODE = "play_mode"

let mainDB: LevelDB = LevelDB.databaseInLibrary(withName: "main.db")

class CoreDB {
    
    class func clearAll() {
        CoreDB.clearHistory()
        CoreDB.removeAllDownloadedSongs()
        CoreDB.removeAllDownloadingSongs()
    }
    
    class func saveAllChannels(_ jsonArray: [[String : Any]]) {
        mainDB.setObject(jsonArray, forKey: DB_ALLCHANNELS)
    }
    
    class func getAllChannels() -> [[String : Any]]? {
        if let jsonArray = mainDB.object(forKey: DB_ALLCHANNELS) {
            return jsonArray as? [[String : Any]]
        }
        return nil
    }
    
    class func saveAllNowChannels(_ jsonArray: [[String : Any]]) {
        mainDB.setObject(jsonArray, forKey: DB_ALLNOWCHANNELS)
    }
    
    class func getAllNowChannels() -> [[String : Any]]?{
        if let jsonArray = mainDB.object(forKey: DB_ALLNOWCHANNELS) {
            return jsonArray as? [[String : Any]]
        }
        return nil
    }
    
    class func savePrograms(_ endpoint: String, jsonArray: [[String : Any]]) {
        mainDB.setObject(jsonArray, forKey: DB_PROGRAMS+endpoint)
    }
    
    class func getPrograms(_ endpoint: String) -> [[String : Any]]?{
        if let jsonArray = mainDB.object(forKey: DB_PROGRAMS+endpoint) {
            return jsonArray as? [[String : Any]]
        }
        return nil
    }
    
    class func saveGroundPrograms(_ endpoint: String, jsonArray: [[String : Any]]) {
        mainDB.setObject(jsonArray, forKey: DB_GROUND_PROGRAMS+endpoint)
    }
    
    class func getGroundPrograms(_ endpoint: String) -> [[String : Any]]?{
        if let jsonArray = mainDB.object(forKey: DB_GROUND_PROGRAMS+endpoint) {
            return jsonArray as? [[String : Any]]
        }
        return nil
    }
    
    class func saveSongs(_ endpoint: String, jsonArray: [[String : Any]]) {
        mainDB.setObject(jsonArray, forKey: DB_SONGS+endpoint)
    }
    
    class func getSongs(_ endpoint: String) -> [[String : Any]]?{
        if let jsonArray = mainDB.object(forKey: DB_SONGS+endpoint) {
            return jsonArray as? [[String : Any]]
        }
        return nil
    }
    
    
    class func saveCustomRadios(_ customRadios: [[String: Any]]) {
        mainDB.setObject(customRadios, forKey: DB_CUSTOMRADIOS)
    }
    
    class func getCustomRadios() -> [[String: Any]]{
        if let jsonArray = mainDB.object(forKey: DB_CUSTOMRADIOS) {
            return jsonArray as! [[String : Any]]
        }
        
        return [
            ["radio_id": 1, "radio_name": "活动"],
            ["radio_id": 2, "radio_name": "情绪"],
            ["radio_id": 6, "radio_name": "餐饮"]
        ]
    }
    
    class func getAllDaysOfWeek() -> [String] {
        return ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"]
    }
    
    class func currentDayOfWeek() -> Int {
        return Date.getSomeDate([.weekday])-1
    }
    class func currentDayOfWeekString() -> String {
        return CoreDB.getAllDaysOfWeek()[CoreDB.currentDayOfWeek()]
    }
    
    class func getAllTimesOfDay() -> [String] {
        return ["清晨","上午","中午","下午","傍晚","晚上","午夜","凌晨"]
    }
    
    class func currentTimeOfDay() -> Int {
        let hour = Date.getSomeDate([.hour])
        
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
    
    class func saveSelectedIndexes(_ indexes: [String : Int]) {
        mainDB.setObject(indexes, forKey: DB_SELECTEDINDEXES)
    }
    
    class func getSelectedIndexes() -> [String : Int]? {
        if let indexes = mainDB.object(forKey: DB_SELECTEDINDEXES) {
            return indexes as? [String : Int]
        }else {
            return nil
        }
    }
    // 清除选择时刻缓存
    class func clearSelectedIndexes() {
        mainDB.removeObject(forKey: DB_SELECTEDINDEXES)
    }
    
    
    // 存储播放列表
    class func savePlaylist(_ songs: [Song]) {
        let jsonArray = songs.toJSON()
        
        mainDB.setObject(jsonArray, forKey: DB_PLAYLSIT)
    }
    /** 获取播放列表 */
    class func getPlaylist() -> [Song] {
        var songs = [Song]()
        if let jsonArray = mainDB.object(forKey: DB_PLAYLSIT) {
            songs = Mapper<Song>().mapArray(JSONArray: jsonArray as! [[String : Any]])
        }
        
        return songs
    }
    
    /** 保存最后的播放列表 */
    class func saveLastPlaylist(_ playlist:[Song], indexOfPlaylist: Int, timePlayed: Int) {
        let lastPlaylist = LastPlaylist(list: playlist, index: indexOfPlaylist, time: timePlayed)
        let playlistDict = lastPlaylist.toJSON()
        
        mainDB.setObject(playlistDict, forKey: DB_LAST_PLAYLSIT)
    }
        
    /** 获取上次的播放列表 */
    class func getLastPlaylist() -> LastPlaylist? {
        if let lastPlaylist = mainDB.object(forKey: DB_LAST_PLAYLSIT) {
            return LastPlaylist(json: lastPlaylist as! [String : Any])
        }
        return nil
    }
    
    //MARK: 歌曲下载
    /** 添加一首已下载的歌曲 */
    class func addSongToDownloadedList(_ song: Song) {
        
        var newSongs = [[String : Any]]()
        if let jsonArray = mainDB.object(forKey: DB_DOWNLOADED_LIST) {
            for item in jsonArray as! [[String : Any]] {
                if (item["song_id"] as! String) == song.songID {
                    return
                }
            }
            
            newSongs.append(contentsOf: jsonArray as! [[String : Any]])
        }
        
        let dict = song.toJSON()
        newSongs.append(dict)
        
        mainDB.setObject(newSongs, forKey: DB_DOWNLOADED_LIST)
    }
    
    /** 获取已下载歌曲数据 */
    class func getDownloadedSongs() -> [Song]? {
        if let jsonArray = mainDB.object(forKey: DB_DOWNLOADED_LIST) {
            
            let songs = Mapper<Song>().mapArray(JSONArray: jsonArray as! [[String : Any]])
            
            return songs
        }
        
        return nil
    }

    /** 获取已下载歌单数据 */
    class func getDownloadedPrograms() -> [Program] {
        let programs = [Program]()
        
//        if let songs = mainDB.object(forKey: DB_DOWNLOADED_LIST) {
//
//            (songs as! [NSDictionary])
//
//            for song in songs {
//                var songList =
//            }
//
//        }
        
        return programs
    }
    
    
    /** 删除一首已下载歌曲数据 */
    class func removeSongFromDownloadedList(_ song: Song) {
        var newSongs: [NSDictionary]
        if let songs = mainDB.object(forKey: DB_DOWNLOADED_LIST) {
            newSongs = songs as! [NSDictionary]
            for item in newSongs {
                if (item["song_id"] as! String) == song.songID {
                    newSongs.remove(at: newSongs.index(of: item)!)
                    break
                }
            }
        }else {
            newSongs = [NSDictionary]()
        }
        mainDB.setObject(newSongs, forKey: DB_DOWNLOADED_LIST)
    }
    

    /** 删除所有已下载歌曲 */
    class func removeAllDownloadedSongs() {
        if let _ = mainDB.object(forKey: DB_DOWNLOADED_LIST) {
            mainDB.removeObject(forKey: DB_DOWNLOADED_LIST)
        }
        // 同时删除文件
    }

    
    /** 添加一首歌曲下载 */
    class func addSongToDownloadingList(_ song: Song) {
        let downloadSong = DownloadSongInfo(song: song)
        let dict = downloadSong.toJSON()
        
        var newSongs = [[String : Any]]()
        if let jsonArray = mainDB.object(forKey: DB_DOWNLOADING_LIST) {
            for item in jsonArray as! [[String : Any]] {
                if (item["taskid"] as! String) == downloadSong.taskid {
                    return
                }
            }
            newSongs.append(contentsOf: jsonArray as! [[String : Any]])
        }
        
        newSongs.append(dict)

        mainDB.setObject(newSongs, forKey: DB_DOWNLOADING_LIST)
    }

    /** 添加一批歌曲下载 */
    class func addSongsToDownloadingList(_ songs: [Song]) {
        var newSongs = [[String:Any]]()
        
        for song in songs {
            var isExit = false
            
            // 检查正在下载列表
            if let jsonArray = mainDB.object(forKey: DB_DOWNLOADING_LIST) {
                for item in jsonArray as! [[String:Any]] {
                    if (item["taskid"] as! String) == song.songID {
                        isExit = true
                        break
                    }
                }
            }
            
            // 检查已下载列表
            if let jsonArray2 = mainDB.object(forKey: DB_DOWNLOADED_LIST) {
                for item in jsonArray2 as! [[String:Any]] {
                    if (item["song_id"] as! String) == song.songID {
                        isExit = true
                        break
                    }
                }
            }
            
            if !isExit {
                let downloadSong = DownloadSongInfo(song: song)
                let dict = downloadSong.toJSON()
                newSongs.append(dict)
            }
            
        }
        
        mainDB.setObject(newSongs, forKey: DB_DOWNLOADING_LIST)
    }
    
    /** 删除一首歌曲下载 */
    class func removeSongFromDownloadingList(_ downloadSong: DownloadSongInfo) {
        var newSongs: [NSDictionary]
        if let songs = mainDB.object(forKey: DB_DOWNLOADING_LIST) {
            newSongs = songs as! [NSDictionary]
            for item in newSongs {
                if (item["taskid"] as! String) == downloadSong.taskid {
                    newSongs.remove(at: newSongs.index(of: item)!)
                    break
                }
            }
        }else {
            newSongs = [NSDictionary]()
        }
        mainDB.setObject(newSongs, forKey: DB_DOWNLOADING_LIST)
    }
    
    /** 获取下载中的歌曲 */
    class func getDownloadingSongs() -> [DownloadSongInfo]? {
        if let jsonArray = mainDB.object(forKey: DB_DOWNLOADING_LIST) {
            
            let infos = DownloadSongInfo.objectsOfJsonArray(jsonArray: jsonArray as! [[String : Any]])
            
            return infos
        }else {
            return nil
        }
    }
    
    /** 删除所有下载中的歌曲 */
    class func removeAllDownloadingSongs() {
        if let _ = mainDB.object(forKey: DB_DOWNLOADING_LIST) {
            mainDB.removeObject(forKey: DB_DOWNLOADING_LIST)
        }
        // 同时删除文件
    }

//MARK: 歌曲播放
    
    /** 修改播放模式 */
    class func changePlayerPlayMode(_ mode: String) {
        mainDB.setObject(mode, forKey: DB_PLAY_MODE)
    }
    
    /** 获取当前播放模式 */
    class func playerPlayMode() -> String? {
        if let mode = mainDB.object(forKey: DB_PLAY_MODE) {
            return mode as? String
        }else {
            return nil
        }
    }
    
//MARK: 播放历史
    /** 获取播放历史 */
    class func getHistorySongs() -> [Song]? {
        if let jsonArray = mainDB.object(forKey: DB_HISTORY_LIST) {
            let songs = Mapper<Song>().mapArray(JSONArray: jsonArray as! [[String : Any]])
            return songs
        }else {
            return nil
        }
    }
    
    /** 添加播放历史 */
    class func addSongToHistoryList(_ song: Song) {
        let dict = song.toJSON()
        
        var newSongs = [[String : Any]]()
        if let jsonArray = mainDB.object(forKey: DB_HISTORY_LIST) {
            newSongs.append(contentsOf: jsonArray as! [[String : Any]])
            
            for (index, item) in newSongs.enumerated() {
                if (item["song_id"] as! String) == song.songID {
                    newSongs.remove(at: index)
                    break
                }
            }
        }
        
        newSongs.insert(dict, at: 0)
        // The count can not exceed 100
        if newSongs.count > 100 {
            newSongs.removeLast()
        }
        mainDB.setObject(newSongs, forKey: DB_HISTORY_LIST)
    }
    
    /** 清除播放历史 */
    class func clearHistory() {
        mainDB.removeObject(forKey: DB_HISTORY_LIST)
    }
    
    //MARK: iTunes音乐
    /** 获取iTunes音乐 */
    class func getITunesSongs() -> [Song]? {
        if let jsonArray = mainDB.object(forKey: DB_HISTORY_LIST) {
            let songs = Mapper<Song>().mapArray(JSONArray: jsonArray as! [[String : Any]])
            return songs
        }else {
            return nil
        }
    }
    
    /** 添加iTunes音乐缓存 */
    class func addSongToITunesList(_ song: Song) {
        let dict = song.toJSON()
        
        var newSongs = [[String : Any]]()
        if let jsonArray = mainDB.object(forKey: DB_HISTORY_LIST) {
            newSongs.append(contentsOf: jsonArray as! [[String : Any]])
            
            for (index, item) in newSongs.enumerated() {
                if (item["song_id"] as! String) == song.songID {
                    newSongs.remove(at: index)
                    break
                }
            }
        }
        
        newSongs.insert(dict, at: 0)
        // The count can not exceed 100
        if newSongs.count > 100 {
            newSongs.removeLast()
        }
        mainDB.setObject(newSongs, forKey: DB_HISTORY_LIST)
    }
}


// MARK: - 收藏歌曲
extension CoreDB {
    class func addMusicToCollectList(_ song: Song) {
        let dict = song.toJSON()
        
        var newSongs = [[String : Any]]()
        if let jsonArray = mainDB.object(forKey: DB_COLLECT_MUSIC_LIST) {
            newSongs.append(contentsOf: jsonArray as! [[String : Any]])
            
            for (index, item) in newSongs.enumerated() {
                if (item["song_id"] as! String) == song.songID {
                    newSongs.remove(at: index)
                    break
                }
            }
        }
        
        newSongs.insert(dict, at: 0)
        // The count can not exceed 100
        if newSongs.count > 100 {
            newSongs.removeLast()
        }
        mainDB.setObject(newSongs, forKey: DB_COLLECT_MUSIC_LIST)
    }
    
    class func getCollectedMusics() -> [Song]? {
        if let jsonArray = mainDB.object(forKey: DB_COLLECT_MUSIC_LIST) {
            let songs = Mapper<Song>().mapArray(JSONArray: jsonArray as! [[String : Any]])
            return songs
        }else {
            return nil
        }
    }
    
    class func clearCollectedSongs() {
        mainDB.removeObject(forKey: DB_COLLECT_MUSIC_LIST)
    }
    
}
