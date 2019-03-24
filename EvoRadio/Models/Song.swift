//
//  Song.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import ObjectMapper

class Song : NSObject, Mappable {

    var songId: String!
    var jujingId: String?
    var programId: String?
    var songName: String!
    var artistId: String?
    var salbumId: String?
    var language: String?
    var salbumsName: String?
    var artistsName: String?
    var playNum: String?
    var shareNum: String?
    var duration: String?
    var filesize: String?
    var audioURL: String?
    var picURL: String?
    var status: String?
    
    var assetURL: URL?
    var albumImage: UIImage?
    
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
        jujingId   <- map["jujing_id"]
        programId    <- map["program_id"]
        songName   <- map["song_name"]
        artistId    <- map["artist_id"]
        salbumId   <- map["salbum_id"]
        salbumsName    <- map["salbums_name"]
        artistsName   <- map["artists_name"]
        playNum    <- map["play_num"]
        shareNum   <- map["share_num"]
        audioURL   <- map["audio_url"]
        picURL   <- map["pic_url"]
        status   <- map["status"]
    }

}
