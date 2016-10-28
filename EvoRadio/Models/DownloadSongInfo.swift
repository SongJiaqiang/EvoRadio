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

    static var downloadSongs: [DownloadSongInfo] = [DownloadSongInfo]()
    
    var taskId: String!
    var song: Song!
    
    var status: TaskStatus!
    var progress: Float!
    
    convenience init(taskId: String, downloadSong: Song, status: TaskStatus = .gettingInfo, progress: Float? = 0) {
        self.init()
        
        self.taskId = taskId
        self.song = downloadSong
        self.status = status
        self.progress = progress
    }
    
    convenience init(_ downloadSong: Song) {
        self.init()
        
        self.taskId = downloadSong.songID
        self.song = downloadSong
        self.status = .gettingInfo
        self.progress = 0
    }
}
