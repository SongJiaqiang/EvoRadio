//
//  Database+Radio.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2020/2/9.
//  Copyright © 2020 JQTech. All rights reserved.
//

import Foundation
import SQLite

// table: radio
extension Database {
    
    func createRadio() -> SQLite.Table? {
        let t = Table("radio")
        let id = Expression<Int64>("radio_id")
        let name = Expression<String?>("radio_name")
        let enName = Expression<String?>("radio_name_en")
        
        do {
            try db?.run(t.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name, unique: true)
                t.column(enName, unique: true)
            })
            return t
        } catch let e {
            print("Create table failed: \(e)")
        }
        return nil
    }
    
    
    /// 插入单条数据
    /// - Parameter object: 数据模型
    func insertRadio(_ object: LRRadio) -> Bool {
        guard let t = createRadio() else {
            return false
        }
        
        let id = Expression<Int64>("radio_id")
        let name = Expression<String?>("radio_name")
        let enName = Expression<String?>("radio_name_en")
        
        let insert = t.insert(or: .replace, id <- Int64(object.radioId!), name <- object.radioName, enName <- object.radioName?.transformToPinYin())
        do {
            let rowid = try Database.shared.db?.run(insert)
            print("Insert row success \(rowid.debugDescription)")
            return true
        } catch let e {
            print("Insert row failed: \(e)")
        }
        return false
    }
    
    //TODO: SQLite.swift不支持多行插入，for循环执行insert并不推荐
    /// 插入多条数据
    /// - Parameter objects: 数据模型数组
    func insertRadios(_ objects: [LRRadio]) -> Bool {
        guard let t = createRadio() else {
            return false
        }
        
        let id = Expression<Int64>("radio_id")
        let name = Expression<String?>("radio_name")
        let enName = Expression<String?>("radio_name_en")
        
        var inserts: [Insert] = []
        for object in objects {
            let insert = t.insert(or: .replace, id <- Int64(object.radioId!), name <- object.radioName, enName <- object.radioName?.transformToPinYin())
            inserts.append(insert)
        }
        do {
            for insert in inserts {
                let rowid = try Database.shared.db?.run(insert)
                print("Insert row success \(rowid.debugDescription)")
            }
            return true
        } catch let e {
            print("Insert row failed: \(e)")
        }
        return false
    }
    
}

