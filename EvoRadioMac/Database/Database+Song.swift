//
//  Database+Song.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2020/2/10.
//  Copyright © 2020 JQTech. All rights reserved.
//

import Foundation
import SQLite
import Lava

// table: song
extension Database {
    
    func createSong() -> SQLite.Table? {
        let t = Table("song")
        let songId = Expression<Int64>("song_id")
        let songName = Expression<String>("song_name")
        let salbumsName = Expression<String>("salbums_name")
        let artistsName = Expression<String>("artists_name")
        let duration = Expression<Int64>("duration")
        let filesize = Expression<Int64>("filesize")
        let audioURL = Expression<String>("audio_url")
        let picURL = Expression<String>("pic_url")
        let programId = Expression<Int64>("program_id")
        do {
            try db?.run(t.create(ifNotExists: true) { t in
                t.column(songId, primaryKey: true)
                t.column(songName)
                t.column(salbumsName)
                t.column(artistsName)
                t.column(duration)
                t.column(filesize)
                t.column(audioURL)
                t.column(picURL)
                t.column(programId)
            })
            return t
        } catch let e {
            print("Create table failed: \(e)")
        }
        return nil
    }
    
    /// 插入单条数据
    /// - Parameter object: 数据模型
    func insertSong(_ object: LRSong) -> Bool {
        guard let t = createSong() else {
            return false
        }
        
        let songId = Expression<Int64>("song_id")
        let songName = Expression<String>("song_name")
        let salbumsName = Expression<String>("salbums_name")
        let artistsName = Expression<String>("artists_name")
        let duration = Expression<Int64>("duration")
        let filesize = Expression<Int64>("filesize")
        let audioURL = Expression<String>("audio_url")
        let picURL = Expression<String>("pic_url")
        let programId = Expression<Int64>("program_id")
        
        var setters = [Setter]()
        setters.append(songId <- Int64(object.songId)!)
        setters.append(songName <- object.songName ?? "")
        setters.append(salbumsName <- object.salbumsName ?? "")
        setters.append(artistsName <- object.artistsName ?? "")
        setters.append(duration <- Int64(object.duration ?? "0")!)
        setters.append(filesize <- Int64(object.filesize ?? "0")!)
        setters.append(audioURL <- object.audioURL ?? "")
        setters.append(picURL <- object.picURL ?? "")
        setters.append(programId <- Int64(object.programId ?? "0")!)
        
        let insert = t.insert(or: .replace, setters)
        do {
            let rowid = try Database.shared.db?.run(insert)
            print("Insert row success \(rowid.debugDescription)")
            return true
        } catch let e {
            print("Insert row failed: \(e)")
        }
        return false
    }
    
    //TODO: SQLite.swift不支持多行插入，通过拼接SQL语句解决
    /// 插入多条数据
    /// - Parameter objects: 数据模型数组
    func insertSongs(_ objects: [LRSong]) -> Bool {
        guard let _ = createSong() else {
            return false
        }
        
        // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        let fieldString = String(format: "('song_id','song_name','salbums_name','artists_name','language','duration','filesize','audio_url','pic_url','tsid','program_id','status')")
        var valuesString: String = ""
        for object in objects {
            valuesString.append("(")
            valuesString.append(String(format: "%@,", object.songId))
            let songName = (object.songName ?? "").replacingOccurrences(of: "\"", with: "'")
            valuesString.append(String(format: "\"%@\",", songName))
            let salbumsName = (object.songName ?? "").replacingOccurrences(of: "\"", with: "'")
            valuesString.append(String(format: "\"%@\",", salbumsName))
            let artistsName = (object.artistsName ?? "").replacingOccurrences(of: "\"", with: "'")
            valuesString.append(String(format: "\"%@\",", artistsName))
            valuesString.append(String(format: "%@,", object.duration ?? "0"))
            valuesString.append(String(format: "%@,", object.filesize ?? "0"))
            valuesString.append(String(format: "'%@',", object.audioURL ?? ""))
            valuesString.append(String(format: "'%@',", object.picURL ?? ""))
            valuesString.append(String(format: "%@,", object.programId ?? "0"))
            valuesString.append("),")
        }
        valuesString.remove(at: valuesString.index(before: valuesString.endIndex))
        let SQLString = String(format: "INSERT OR IGNORE INTO '%@' %@ VALUES %@", "song", fieldString, valuesString)
        do {
            try Database.shared.db?.execute(SQLString)
            print("Insert rows success")
            return true
        } catch let e {
            print("Insert row failed: \(e)")
        }
        return false
    }
    
}
