//
//  LRSong.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper

class LRSong : NSObject, Mappable {

    var songId: String!
    var songName: String!
    var salbumsName: String?
    var artistsName: String?
    var language: String?
    var duration: String?
    var filesize: String?
    var audioURL: String?
    var picURL: String?
    var tsid: String?
    var programId: String?
    var status: String?
    
    #if os(iOS)
    var assetURL: URL?
    var albumImage: UIImage?
    #endif
    
    override init() {
        super.init()
    }
    
    convenience init(songName: String) {
        self.init()
        
        self.songName = songName
    }

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        songId    <- map["song_id"]
        songName   <- map["song_name"]
        salbumsName    <- map["salbums_name"]
        artistsName   <- map["artists_name"]
        language   <- map["language"]
        duration   <- map["duration"]
        filesize   <- map["filesize"]
        audioURL   <- map["audio_url"]
        picURL   <- map["pic_url"]
        tsid    <- map["tsid"]
        programId    <- map["program_id"]
        status   <- map["status"]
    }

}
