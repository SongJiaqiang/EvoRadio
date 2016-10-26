//
//  TrackManager.swift
//  EvoRadio
//
//  Created by Jarvis on 6/4/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

enum PlayMusciType: String {
    case ChannelCover = "ChannelCover"
    case ProgramCover = "ProgramCover"
    case SongList = "SongList"
    case SongListCell = "SongListCell"
    case DownloadedSongList  = "DownloadedSongList"
    case DownloadedSongListCell = "DownloadedSongListCell"
    case HistorySongList  = "HistorySongList"
    case HistorySongListCell = "HistorySongListCell"
    case PlayerBar = "PlayerBar"
    case PlayerController = "PlayerController"
}

class TrackManager {
    
    class func playMusicTypeEvent(_ type: PlayMusciType) {
//        let attrs = ["type":type.rawValue]
//        MobClick.event("play_music_type", attributes: attrs)
    }
    
}
