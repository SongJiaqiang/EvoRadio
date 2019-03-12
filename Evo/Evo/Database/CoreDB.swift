//
//  CoreDB.swift
//  Evo
//
//  Created by Jarvis on 2019/3/11.
//  Copyright © 2019 SongJiaqiang. All rights reserved.
//

import Foundation
//import SQLite



//class CoreDB {
//    var db: Connection?
//
//    init() {
//        let dbPath = JQHDURL.appendingPathComponent("evo").appendingPathComponent("db").appendingPathComponent("db.sqlite3")
//        self.db = try! Connection(dbPath.path)
//    }
//
//    func createRadioTable() {
//        guard let db = db else {
//            print("Not found db")
//            return
//        }
//
//        let radio = Table("radio")
//        let id = Expression<Int>("radio_id")
//        let name = Expression<String>("radio_name")
//
//        try! db.run(radio.create(block: { (t) in
//            t.column(id, primaryKey: true)
//            t.column(name)
//        }))
//    }
//
//}
