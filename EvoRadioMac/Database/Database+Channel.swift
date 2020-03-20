//
//  Database+Channel.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2020/2/9.
//  Copyright © 2020 JQTech. All rights reserved.
//

import Foundation
import SQLite
import Lava

// table: channels
extension Database {
    
    func createChannel() -> SQLite.Table? {
        let t = Table("channel")
        let channelId = Expression<Int64>("channel_id")
        let channelName = Expression<String?>("channel_name")
        let channelDesc = Expression<String?>("channel_desc")
        let radioId = Expression<Int64>("radio_id")
        let radioName = Expression<String?>("radio_name")
        let picURL = Expression<String>("pic_url")
        
        do {
            try db?.run(t.create(ifNotExists: true) { t in
                t.column(channelId, primaryKey: true)
                t.column(channelName, unique: true)
                t.column(channelDesc)
                t.column(radioId)
                t.column(radioName)
                t.column(picURL)
            })
            return t
        } catch let e {
            print("Create table failed: \(e)")
        }
        return nil
    }
    
    /// 插入单条数据
    /// - Parameter object: 数据模型
    func insertChannel(_ object: LRChannel) -> Bool {
        guard let t = createRadio() else {
            return false
        }
        
        let channelId = Expression<Int64>("channel_id")
        let channelName = Expression<String?>("channel_name")
        let channelDesc = Expression<String?>("channel_desc")
        let radioId = Expression<Int64>("radio_id")
        let radioName = Expression<String?>("radio_name")
        let picURL = Expression<String>("pic_url")
        
        var setters = [Setter]()
        setters.append(channelId <- Int64(object.channelId!)!)
        setters.append(channelName <- object.channelName)
        setters.append(channelDesc <- object.channelDesc)
        setters.append(radioId <- Int64(object.radioId ?? "0")!)
        setters.append(radioName <- object.radioName)
        setters.append(picURL <- object.picURL ?? "")
        
        
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
    func insertChannels(_ objects: [LRChannel]) -> Bool {
        guard let _ = createChannel() else {
            return false
        }
        
        // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        let fieldString = String(format: "('channel_id','channel_name','channel_name_shengmu','english_name','channel_desc','radio_id','radio_name','pic_url')")
        var valuesString: String = ""
        for object in objects {
            valuesString.append("(")
            valuesString.append(String(format: "%@,", object.channelId ?? "0"))
            valuesString.append(String(format: "'%@',", object.channelName ?? ""))
            valuesString.append(String(format: "'%@',", object.channelDesc ?? ""))
            valuesString.append(String(format: "%@,", object.radioId ?? "0"))
            valuesString.append(String(format: "'%@',", object.radioName ?? ""))
            valuesString.append(String(format: "'%@'", object.picURL ?? ""))
            valuesString.append("),")
        }
        valuesString.remove(at: valuesString.index(before: valuesString.endIndex))
        let SQLString = String(format: "INSERT OR IGNORE INTO '%@' %@ VALUES %@", "channel", fieldString, valuesString)
    
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
