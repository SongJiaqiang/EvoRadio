//
//  DownloadSongInfo.swift
//  EvoRadio
//
//  Created by Jarvis on 28/10/2016.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import EVReflection

class DownloadSongInfo: EVObject {
    
    var taskid: String?
//    var taskIndex: NSNumber?
    var status: NSNumber?
    var song: Song?
    
    convenience init(taskid: String, song: Song, status: Int = TaskStatus.gettingInfo.rawValue) {
        self.init()
        
        self.taskid = taskid
        self.song = song
        self.status = status as NSNumber?
    }
    
    convenience init(_ song: Song) {
        self.init()
        
        self.taskid = song.songID
        self.song = song
        self.status = TaskStatus.gettingInfo.rawValue as NSNumber?
    }
}
