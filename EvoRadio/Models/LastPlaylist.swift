//
//  LastPlaylist.swift
//  EvoRadio
//
//  Created by Jarvis on 6/2/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import EVReflection

class LastPlaylist: EVObject {

    var playlist: [Song]?
    var indexOfPlaylist: NSNumber? = 0
    var timePlayed: NSNumber? = 0
    
    override func propertyMapping() -> [(String?, String?)] {
        return [
            ("indexOfPlaylist", "index_of_playlist"),
            ("timePlayed", "time_played")
        ]
    }
    
    convenience init(list: [Song], index: Int, time: Int) {
        self.init()
        
        self.playlist = list
        self.indexOfPlaylist = index as NSNumber?
        self.timePlayed = time as NSNumber?
    }
}
