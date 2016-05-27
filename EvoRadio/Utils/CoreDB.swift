//
//  CoreDB.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation

let KEY_ALLCHANNELS = "all_channels"
let KEY_ALLNOWCHANNELS = "all_now_channels"
let KEY_CUSTOMRADIOS = "custom_radios"
let KEY_SELECTEDINDEXES = "selected_indexes"
let KEY_PLAYLSIT = "playlist"


let leveldb: WLevelDb = WLevelDb.sharedDb()

class CoreDB {
    
    class func clearAll() {
        WLevelDb.sharedDb().removeAllObjects()
    }
    
    class func saveAllChannels(responseData: [[String : AnyObject]]) {
        WLevelDb.sharedDb().setObject(responseData, forKey: KEY_ALLCHANNELS)
    }
    
    class func getAllChannels() -> [[String : AnyObject]]?{
        let responseData = WLevelDb.sharedDb().objectForKey(KEY_ALLCHANNELS)
        if let _ = responseData {
            return responseData as? [[String : AnyObject]]
        }
        return nil
    }
    class func saveAllNowChannels(responseData: [[String : AnyObject]]) {
        WLevelDb.sharedDb().setObject(responseData, forKey: KEY_ALLNOWCHANNELS)
    }
    
    class func getAllNowChannels() -> [[String : AnyObject]]?{
        let responseData = WLevelDb.sharedDb().objectForKey(KEY_ALLNOWCHANNELS)
        if let _ = responseData {
            return responseData as? [[String : AnyObject]]
        }
        return nil
    }
    
    class func saveCustomRadios(customRadios: [[String: AnyObject]]) {
        WLevelDb.sharedDb().setObject(customRadios, forKey: KEY_CUSTOMRADIOS)
    }
    
    class func getCustomRadios() -> [[String: AnyObject]]{
        let customRadios = WLevelDb.sharedDb().objectForKey(KEY_CUSTOMRADIOS)
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
        WLevelDb.sharedDb().setObject(indexes, forKey: KEY_SELECTEDINDEXES)
    }
    
    class func getSelectedIndexes() -> [String : Int]? {
        if let indexes = WLevelDb.sharedDb().objectForKey(KEY_SELECTEDINDEXES) {
            return indexes as? [String : Int]
        }else {
            return nil
        }
    }
    // 清除选择时刻缓存
    class func clearSelectedIndexes() {
        WLevelDb.sharedDb().removeObjectForKey(KEY_SELECTEDINDEXES)
    }
    
    
    // 存储播放列表
    class func savePlaylist(songs: [Song]) {
        let songsDict = songs.toDictionaryArray()
        WLevelDb.sharedDb().setObject(songsDict, forKey: KEY_PLAYLSIT)
    }
    
    class func getPlaylist() -> [Song] {
        var songs = [Song]()
        if let songsDict = leveldb.objectForKey(KEY_PLAYLSIT) {
            songs = [Song](dictArray: songsDict as? [NSDictionary])
        }
        
        return songs
    }
    
}