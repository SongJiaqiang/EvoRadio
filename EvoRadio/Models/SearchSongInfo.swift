//
//  SearchSongInfo.swift
//  EvoRadio
//
//  Created by Jarvis on 24/09/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

import UIKit
import ObjectMapper

class SearchSongInfo: NSObject, Mappable {

    var songId: String?
    var songName: String?
    var artistName: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        songId    <- map["songid"]
        songName   <- map["songname"]
        artistName    <- map["artistname"]
    }
}
