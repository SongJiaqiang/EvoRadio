//
//  SearchedSongInfo.swift
//  EvoRadio
//
//  Created by Jarvis on 24/09/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

import Foundation
import ObjectMapper

class SearchedResult: NSObject, Mappable {
    
    var songInfo: SearchedResultSongInfo?
    var errorCode: Int?
    var bitrate: SearchedResultBitrate?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        songInfo    <- map["songinfo"]
        bitrate   <- map["bitrate"]
        errorCode    <- map["error_code"]
    }
    
}

class SearchedResultBitrate: NSObject, Mappable {
    
    var fileId: Int?
    var fileSize: Int?
    var fileDuration: Int?
    var fileBitrate: Int?
    var fileExtension: String?
    var fileLink: String?
    var showLink: String?
    var isFree: Int?
    var fileHash: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        fileId    <- map["song_file_id"]
        fileSize   <- map["file_size"]
        fileDuration    <- map["file_duration"]
        fileBitrate    <- map["file_bitrate"]
        fileExtension   <- map["file_extension"]
        fileLink    <- map["file_link"]
        showLink    <- map["show_link"]
        isFree   <- map["free"]
        fileHash    <- map["hash"]
    }
    
}


class SearchedResultSongInfo: NSObject, Mappable {

    var songId: String?
    var title: String?
    var albumTitle: String?
    var author: String?
    var artistId: String?
    var albumId: String?
    var proxycompany: String?
    var picSmall: String?
    var picBig: String?
    var picHuge: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        songId    <- map["song_id"]
        title   <- map["title"]
        albumId    <- map["album_id"]
        albumTitle    <- map["album_title"]
        artistId    <- map["artist_id"]
        author    <- map["author"]
        proxycompany   <- map["si_proxycompany"]
        picSmall    <- map["pic_small"]
        picBig    <- map["pic_big"]
        picHuge   <- map["pic_huge"]
        
    }
    
}
