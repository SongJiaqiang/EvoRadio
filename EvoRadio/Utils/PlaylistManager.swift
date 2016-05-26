//
//  PlaylistManager.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 5/26/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

class PlaylistManager {
    
    //MARK: instance
    class var sharedManager: PlaylistManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PlaylistManager! = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = PlaylistManager()
        }
        
        return Static.instance
    }
    
    
}