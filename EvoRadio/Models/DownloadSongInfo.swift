//
//  DownloadSongInfo.swift
//  EvoRadio
//
//  Created by Jarvis on 28/10/2016.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import ObjectMapper

class DownloadSongInfo: NSObject {
    
    var taskid: String?
    var status: Int?
    var song: Song?
    
    convenience init(json: [String : Any]) {
        self.init()
        
        let taskid = json["taskid"] as! String
        let status = json["status"] as! Int
        let song = Song(JSON: json["song"] as! [String:Any])
        
        
        self.taskid = taskid
        self.status = status
        self.song = song
        
    }
    
    convenience init(song: Song) {
        self.init()
        
        self.taskid = song.songID
        self.song = song
        self.status = TaskStatus.gettingInfo.rawValue
    }

    func toJSON() -> [String:Any] {
        
        return ["taskid" : taskid as Any,
         "status" : status as Any,
         "song" : song?.toJSON() as Any]
    }
    
    
    class func objectsOfJsonArray(jsonArray: [[String:Any]]) -> [DownloadSongInfo] {
        
        var objects = [DownloadSongInfo]()
        
        for json in jsonArray {
            let object = DownloadSongInfo(json: json)
            
            objects.append(object)
        }
        
        return objects
    }
    
    class func toJSONArray(objects: [DownloadSongInfo]) -> [[String:Any]] {
        
        var jsonArray = [[String:Any]]()
        for object in objects {
            let json = object.toJSON()
            
            jsonArray.append(json)
        }
        
        return jsonArray
    }
    
}
