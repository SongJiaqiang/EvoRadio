//
//  Database.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2020/2/9.
//  Copyright © 2020 JQTech. All rights reserved.
//

import Foundation
import SQLite

enum SQLiteStatus {
    case idle, connected, failed, closed
}

class Database {
    static let shared = Database()
    
    var db: Connection?
    
    var status: SQLiteStatus = .idle
    
    init() {
        _ = connect()
    }
    
    
    /// 生成sql文件并连接数据库
    func connect() -> Bool {
        let supportDirectory = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        ).first!
        let rootDirector = supportDirectory + "/" + Bundle.main.bundleIdentifier!
        // create parent directory iff it doesn’t exist
        try! FileManager.default.createDirectory(
            atPath: rootDirector, withIntermediateDirectories: true, attributes: nil
        )
        let dbFilePath = rootDirector + "/" + "lava.sqlite3"
        
        do {
            db = try Connection(dbFilePath)
            status = .connected
            print("Connect sqlite3 success: \(dbFilePath)")
            return true
        } catch let e {
            print("Connect sqlite3 failed: \(e)")
            status = .failed
        }

        return false
    }
}

//MARK: Test
extension Database {
    
    /// 创建数据表
    func t_createTable() -> Bool {
        let t = Table("test")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String?>("email")
        do {
            try db?.run(t.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name, unique: true)
                t.column(email, unique: true)
            })
            return true
        } catch let e {
            print("Create table failed: \(e)")
        }
        return false
    }
    
    
    /// 插入数据行
    func t_insert() -> Bool {
        let t = Table("test")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String?>("email")
        
        let insert = t.insert(or: .replace, id <- 1, name <- "活动电台", email <- "aa@aa.com")
        do {
            let rowid = try db?.run(insert)
            print("Insert row success \(rowid.debugDescription)")
            return true
        } catch let e {
            print("Insert row failed: \(e)")
        }
        return false
    }
    
    /// 查询数据
    func t_query() -> Any? {
        let t = Table("test")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String?>("email")
        
        do {
            if let rows = try db?.prepare(t) {
                for row in rows {
                    print("id: \(row[id]), name: \(String(describing: row[name]))")
                }
                return rows
            }
        } catch let e {
            print("Insert row failed: \(e)")
        }
        return nil
    }
}


