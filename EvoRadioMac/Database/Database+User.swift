//
//  Database+User.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2020/2/10.
//  Copyright © 2020 JQTech. All rights reserved.
//

import Foundation
import SQLite

// table: user
extension Database {
    
    func createUser() -> SQLite.Table? {
        let t = Table("song")
        let programId = Expression<Int64>("program_id")
        let programName = Expression<String>("program_name")
        let programDesc = Expression<String>("program_desc")
        let picURL = Expression<String>("pic_url")
        let channels = Expression<String>("channels")
        let covers = Expression<String>("covers")
        let uid = Expression<Int64>("uid")
        let songNum = Expression<Int64>("song_num")
        
        do {
            try db?.run(t.create(ifNotExists: true) { t in
                t.column(programId, primaryKey: true)
                t.column(programName)
                t.column(programDesc)
                t.column(picURL)
                t.column(channels)
                t.column(covers)
                t.column(uid)
                t.column(songNum)
            })
            return t
        } catch let e {
            print("Create table failed: \(e)")
        }
        return nil
    }
    
    /// 插入单条数据
    /// - Parameter object: 数据模型
    func insertUser(_ object: LRProgram) -> Bool {
        guard let t = createProgram() else {
            return false
        }
        let programId = Expression<Int64>("program_id")
        let programName = Expression<String>("program_name")
        let programDesc = Expression<String>("program_desc")
        let picURL = Expression<String>("pic_url")
        let channels = Expression<String>("channels")
        let covers = Expression<String>("covers")
        let uid = Expression<Int64>("uid")
        let songNum = Expression<Int64>("song_num")
        
        var setters = [Setter]()
        setters.append(programId <- Int64(object.programId!)!)
        setters.append(programName <- object.programName ?? "")
        setters.append(programDesc <- object.programDesc ?? "")
        setters.append(picURL <- object.picURL!)
        
        var channelsValue = "["
        if let channels = object.channels {
            if channels.count > 0 {
                channelsValue.append("[")
                for channel in channels {
                    if let channelId = channel.channelId {
                        let idValue = String(format: "%@,", channelId)
                        channelsValue.append(idValue)
                    }
                }
                channelsValue.append("]")
            }
        }
        setters.append(channels <- channelsValue)
        setters.append(covers <- object.cover?.pics?.description ?? "")
        setters.append(uid <- Int64(object.uid ?? "0")!)
        setters.append(songNum <- object.songNum ?? 0)
        
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
    
}
