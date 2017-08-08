//
//  DownloadSongInfo.swift
//  EvoRadio
//
//  Created by Jarvis on 28/10/2016.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import ObjectMapper

class DownloadSongInfo: Mappable {
    
    var taskid: String?
    var status: NSNumber?
    var song: Song?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        taskid    <- map["taskid"]
        status    <- map["status"]
        song    <- map["song"]
    }
}
