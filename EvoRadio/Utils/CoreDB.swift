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
    
}