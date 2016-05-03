//
//  CoreDB.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/22.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation

let ALLCHANNELS = "all_channels"
let ALLNOWCHANNELS = "all_now_channels"
let CUSTOMRADIOS = "custom_radios"
let SELECTEDINDEXES = "selected_indexes"



class CoreDB {
    
    let leveldb: WLevelDb
 
    init() {
        leveldb = WLevelDb.sharedDb()
    }
    
    func dbTest() {
        leveldb.setObject("Hello LevelDb", forKey: "hi")
    }
    
    class func clearAll() {
        WLevelDb.sharedDb().removeAllObjects()
    }
    
    class func saveAllChannels(responseData: [[String : AnyObject]]) {
        WLevelDb.sharedDb().setObject(responseData, forKey: ALLCHANNELS)
    }
    
    class func getAllChannels() -> [[String : AnyObject]]?{
        let responseData = WLevelDb.sharedDb().objectForKey(ALLCHANNELS)
        if let _ = responseData {
            return responseData as? [[String : AnyObject]]
        }
        return nil
    }
    class func saveAllNowChannels(responseData: [[String : AnyObject]]) {
        WLevelDb.sharedDb().setObject(responseData, forKey: ALLNOWCHANNELS)
    }
    
    class func getAllNowChannels() -> [[String : AnyObject]]?{
        let responseData = WLevelDb.sharedDb().objectForKey(ALLNOWCHANNELS)
        if let _ = responseData {
            return responseData as? [[String : AnyObject]]
        }
        return nil
    }
    
    class func saveCustomRadios(customRadios: [[String: AnyObject]]) {
        WLevelDb.sharedDb().setObject(customRadios, forKey: CUSTOMRADIOS)
    }
    
    class func getCustomRadios() -> [[String: AnyObject]]{
        let customRadios = WLevelDb.sharedDb().objectForKey(CUSTOMRADIOS)
        if let _ = customRadios {
            return customRadios as! [[String : AnyObject]]
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
        return NSDate.getSomeDate([.WeekdayOrdinal])
    }
    class func currentDayOfWeekString() -> String {
        let ordinalDay = NSDate.getSomeDate([.WeekdayOrdinal])
        return CoreDB.getAllDaysOfWeek()[ordinalDay]
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
        WLevelDb.sharedDb().setObject(indexes, forKey: SELECTEDINDEXES)
    }
    class func getSelectedIndexes() -> [String : Int]? {
        if let indexes = WLevelDb.sharedDb().objectForKey(SELECTEDINDEXES) {
            return indexes as? [String : Int]
        }else {
            return nil
        }
    }
    
    
}