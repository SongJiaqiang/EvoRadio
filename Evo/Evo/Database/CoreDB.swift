//
//  CoreDB.swift
//  Evo
//
//  Created by Jarvis on 2019/3/11.
//  Copyright © 2019 SongJiaqiang. All rights reserved.
//

import Foundation
import SQLite


class CoreDB {
    var db: Connection?

    init() {
        let dbPath = baseURL.appendingPathComponent("evo").appendingPathComponent("db").appendingPathComponent("lava.sqlite3")
        self.db = try! Connection(dbPath.path)
    }

    func createRadioTable() {
        guard let db = db else {
            print("Not found db")
            return
        }

        let radio = Table("radio")
        let id = Expression<Int>("radio_id")
        let name = Expression<String>("radio_name")

        try! db.run(radio.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
        }))
    }
    
    func createChannelTable() {
        guard let db = db else {
            print("Not found db")
            return
        }
        
        let channel = Table("channel")
        let id = Expression<Int>("channel_id")
        let name = Expression<String>("channel_name")
        
        try! db.run(channel.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
        }))
    }
    
    
    func createProgramTable() {
        guard let db = db else {
            print("Not found db")
            return
        }
        
        let program = Table("program")
        let id = Expression<Int>("program_id")
        let name = Expression<String>("program_name")
        
        try! db.run(program.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
        }))
    }
    
    
    func createSongTable() {
        guard let db = db else {
            print("Not found db")
            return
        }
        
        let song = Table("song")
        let id = Expression<Int>("song_id")
        let name = Expression<String>("song_name")
        
        try! db.run(song.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
        }))
    }
    
    
    func createUserTable() {
        guard let db = db else {
            print("Not found db")
            return
        }
        
        let user = Table("user")
        let id = Expression<Int>("user_id")
        let name = Expression<String>("user_name")
        
        try! db.run(user.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
        }))
    }

}
