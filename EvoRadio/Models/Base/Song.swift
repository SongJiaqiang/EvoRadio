//
//  LRSong.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper
import Lava

class Song : NSObject, Mappable {

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
    
    //TODO: 不要在model中使用非基础类型的属性
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

extension Song {
    class func fromLRSong(_ lrSong: LRSong) -> Song? {
        if let song = Song(JSON: lrSong.toJSON()) {
            return song
        }
        return nil
    }
    
    class func fromLRSongs(_ lrSongs: [LRSong]) -> [Song] {
        var songs = [Song]();
        lrSongs.forEach { (lrSong) in
            if let song = Song(JSON: lrSong.toJSON()) {
                songs.append(song)
            }
        }
        return songs
    }
    
    func toLRSong() -> LRSong? {
        return LRSong(JSON: self.toJSON())
    }
}
