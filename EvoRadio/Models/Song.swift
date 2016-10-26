//
//  Song.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import EVReflection

class Song: EVObject {

    var songID: String!
    var jujingID: String?
    var programID: String?
    var songName: String!
    var artistID: String?
    var salbumID: String?
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
    
    override func propertyMapping() -> [(String?, String?)] {
        return [
            ("songID", "song_id"),
            ("jujingID", "jujing_id"),
            ("programID", "program_id"),
            ("songName", "song_name"),
            ("artistID", "artist_id"),
            ("salbumID", "salbum_id"),
            ("salbumsName", "salbums_name"),
            ("artistsName", "artists_name"),
            ("playNum", "play_num"),
            ("shareNum", "share_num"),
            ("audioURL", "audio_url"),
            ("picURL", "pic_url")
        ]
    }
}
