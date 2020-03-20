//
//  LastPlaylist.swift
//  EvoRadio
//
//  Created by Jarvis on 6/2/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import ObjectMapper

class LastPlaylist: NSObject {

    var playlist: [Song]?
    var indexOfPlaylist: Int? = 0
    var timePlayed: Int? = 0
    
    convenience init(json: [String : Any]) {
        
        let songs = Mapper<Song>().mapArray(JSONArray: json["playlist"] as! [[String : Any]])
        let index = json["indexOfPlaylist"] as! Int
        let time = json["timePlayed"] as! Int
        
        self.init(list: songs, index: index, time: time)
    }
    
    convenience init(list: [Song], index: Int, time: Int) {
        self.init()
        
        self.playlist = list
        self.indexOfPlaylist = index
        self.timePlayed = time
    }
    
    func toJSON() -> [String : Any] {
        let songArray = playlist?.toJSON()
        
        return ["playlist":songArray as Any,
                "indexOfPlaylist":indexOfPlaylist as Any,
                "timePlayed":timePlayed as Any]
    }
    
    func objectOfJson(json: [String : Any]) -> LastPlaylist {
        
        let songs = Mapper<Song>().mapArray(JSONArray: json["playlist"] as! [[String : Any]])
        let index = json["indexOfPlaylist"] as! Int
        let time = json["timePlayed"] as! Int
        
        let playlist = LastPlaylist(list: songs, index: index, time: time)
        
        return playlist
    }
    
//    required init?(map: Map) {
//        
//    }
//    
//    func mapping(map: Map) {
//        playlist    <- map["playlist"]
//        indexOfPlaylist    <- map["indexOfPlaylist"]
//        timePlayed    <- map["timePlayed"]
//    }

}
