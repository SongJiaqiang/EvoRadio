//
//  PlaylistManager.swift
//  EvoRadio
//
//  Created by Jarvis on 5/26/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

class PlaylistManager {
    
    var playlist: [Song]?
    var currentItem: Song?
    
    //MARK: instance
    open static let playlist = PlaylistManager()
    
    func savedList() -> [Song] {
        
        if let _ = playlist {
            return playlist!
        }else {
            // load from levelDB
            return CoreDB.getPlaylist()
        }
    }
    
    func saveList(_ songs: [Song]) {
        playlist = songs
        CoreDB.savePlaylist(playlist!)
    }
    
    func appendSong(_ song: Song) {
        playlist?.append(song)
        CoreDB.savePlaylist(playlist!)
    }
    
    
}
