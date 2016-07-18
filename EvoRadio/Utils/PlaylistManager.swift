//
//  PlaylistManager.swift
//  EvoRadio
//
//  Created by Jarvis on 5/26/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

let instance_playlist = PlaylistManager.instance

class PlaylistManager {
    
    var playlist: [Song]?
    var currentItem: Song?
    
    //MARK: instance
    class var instance: PlaylistManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlaylistManager! = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = PlaylistManager()
        }
        
        return Static.instance
    }
    
    
    func savedList() -> [Song] {
        
        if let _ = playlist {
            return playlist!
        }else {
            // load from levelDB
            return CoreDB.getPlaylist()
        }
    }
    
    func saveList(songs: [Song]) {
        playlist = songs
        CoreDB.savePlaylist(playlist!)
    }
    
    func appendSong(song: Song) {
        playlist?.append(song)
        CoreDB.savePlaylist(playlist!)
    }
    
    
}