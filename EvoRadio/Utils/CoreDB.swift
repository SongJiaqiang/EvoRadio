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
    
}