//
//  Song.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
/*
 {
 "song_id": "3676519",
 "jujing_id": "27753045",
 "song_name": "Utviklingssang",
 "artist_id": "101020",
 "salbum_id": "337548",
 "language": "",
 "salbums_name": "Trios",
 "artists_name": "Carla Bley",
 "play_num": "0",
 "share_num": "0",
 "duration": "476",
 "filesize": "9537",
 "audio_url": "http://audio4.lavaradio.com/internet_fetch_extend/n_337/337548/27753045.mp3",
 "status": "1",
 "program_id": "6938",
 "pic_url": "http://img1.lavaradio.com/762/248/7622483998973385800.jpg"
 }
 */
class Song: NSObject {

    var songID: String?
    var jujingID: String?
    var programID: String?
    var songName: String?
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
    
    
    class func songWithDict(dict: [String : AnyObject]) -> Song {
        let song = Song()
        
        song.songID = dict["song_id"] as? String
        song.programID = dict["program_id"] as? String
        song.songName = dict["song_name"] as? String
        song.salbumsName = dict["salbums_name"] as? String
        song.artistsName = dict["artists_name"] as? String
        song.duration = dict["duration"] as? String
        song.filesize = dict["filesize"] as? String
        song.audioURL = dict["audio_url"] as? String
        song.picURL = dict["pic_url"] as? String
        
        return song
    }
    
    class func songsWithDict(dicts: [[String : AnyObject]]) -> [Song] {
        var songs = [Song]()
        for dict in dicts {
            songs.append(Song.songWithDict(dict))
        }
        return songs
    }
}
