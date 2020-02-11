//
//  Database+Program.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2020/2/9.
//  Copyright © 2020 JQTech. All rights reserved.
//

import Foundation
import SQLite

// table: programs
extension Database {
    
    func createProgram() -> SQLite.Table? {
        let t = Table("program")
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
    func insertProgram(_ object: LRProgram) -> Bool {
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
    
    //TODO: SQLite.swift不支持多行插入，通过拼接SQL语句解决
    /// 插入多条数据
    /// - Parameter objects: 数据模型数组
    func insertPrograms(_ objects: [LRProgram]) -> Bool {
        guard let _ = createProgram() else {
            return false
        }
        
        // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        let fieldString = String(format: "('program_id','program_name','program_desc','pic_url','channels','covers','uid','song_num')")
        var valuesString: String = ""
        for object in objects {
            valuesString.append("(")
            valuesString.append(String(format: "%@,", object.programId ?? "0"))
            valuesString.append(String(format: "\"%@\",", object.programName ?? ""))
            valuesString.append(String(format: "\"%@\",", (object.programDesc ?? "").replacingOccurrences(of: "\"", with: " ")))
            valuesString.append(String(format: "'%@',", object.picURL ?? ""))
            var channelsValue = ""
            if let channels = object.channels {
                if channels.count > 0 {
                    channelsValue.append("[")
                    for channel in channels {
                        if let channelId = channel.channelId {
                            let idValue = String(format: "%@,", channelId)
                            channelsValue.append(idValue)
                        }
                    }
                    channelsValue.remove(at: channelsValue.index(before: channelsValue.endIndex))
                    channelsValue.append("]")
                }
            }
            valuesString.append(String(format: "'%@',", channelsValue))
            var coversValue = ""
            if let pics = object.cover?.pics, pics.count > 0 {
                coversValue.append("[")
                for pic in pics {
                    coversValue.append(String(format: "%@,", pic))
                }
                coversValue.remove(at: coversValue.index(before: coversValue.endIndex))
                coversValue.append("]")
            }
            valuesString.append(String(format: "'%@',", coversValue))
            valuesString.append(String(format: "%@,", object.uid ?? "0"))
            valuesString.append(String(format: "%@", object.songNum ?? "0"))
            valuesString.append("),")
        }
        valuesString.remove(at: valuesString.index(before: valuesString.endIndex))
        let SQLString = String(format: "INSERT OR IGNORE INTO '%@' %@ VALUES %@", "program", fieldString, valuesString)
        
        do {
            try Database.shared.db?.execute(SQLString)
            print("Insert rows success")
            
            return true
        } catch let e {
            print("Insert row failed: \(e)")
        }
        return false
    }
    
    func queryAllProgramIds() -> [Int64]? {
        guard let t = createProgram() else {
            return nil
        }
        
        let programId = Expression<Int64>("program_id")
        
        do {
            var ids: [Int64] = []
            if let rows = try db?.prepare(t) {
                for row in rows {
                    ids.append(row[programId])
                }
                print("Select row success");
                return ids
            }
        } catch let e {
            print("Select rows failed: \(e)")
        }
        return []
    }
    
}
