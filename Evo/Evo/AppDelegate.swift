//
//  AppDelegate.swift
//  Evo
//
//  Created by Jarvis on 2019/3/6.
//  Copyright © 2019 SongJiaqiang. All rights reserved.
//

import Cocoa
import LeanCloud

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
//        LCApplication.default.set(
//            id:  "5dDL7DnX1EsrhMGa006nna2H-gzGzoHsz",
//            key: "bvJxHMx1zB4Vrnx46xw35gRs"
//        )
        
        CoreDB().createRadioTable()
        CoreDB().createChannelTable()
        CoreDB().createProgramTable()
        CoreDB().createSongTable()
        CoreDB().createUserTable()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

