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
        let dbFolderPath = rootURL.appendingPathComponent("db")
        rootURL.createFolder()
        dbFolderPath.createFolder()
        let dbPath = dbFolderPath.appendingPathComponent("lava.sqlite3")
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
        let channel_name_shengmu = Expression<String>("channel_name_shengmu")
        let english_name = Expression<String>("english_name")
        let channel_desc = Expression<String>("channel_desc")
        
        let radio_id = Expression<String>("radio_id")
        let radio_name = Expression<String>("radio_name")
        let program_num = Expression<String>("program_num")
        let program_fine = Expression<String>("program_fine")
        let pub_time = Expression<String>("pub_time")
        let sort_order = Expression<String>("sort_order")
        let pic_url = Expression<String>("pic_url")
        let status = Expression<String>("status")
        let recommend = Expression<String>("recommend")
        let rank = Expression<String>("rank")
        
        try! db.run(channel.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(channel_name_shengmu)
            t.column(english_name)
            t.column(channel_desc)
            t.column(radio_id)
            t.column(radio_name)
            t.column(program_num)
            t.column(program_fine)
            t.column(pub_time)
            t.column(sort_order)
            t.column(pic_url)
            t.column(status)
            t.column(recommend)
            t.column(rank)
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
        
        let program_desc = Expression<String>("program_desc")
        let pic_url = Expression<String>("pic_url")
        let create_time = Expression<String>("create_time")
        let modify_time = Expression<String>("modify_time")
        let pub_time = Expression<String>("pub_time")
        let apply_time = Expression<String>("apply_time")
        let subscribe_num = Expression<String>("subscribe_num")
        let song_num = Expression<String>("song_num")
        let play_num = Expression<String>("play_num")
        let share_num = Expression<String>("share_num")
        let collect_num = Expression<String>("collect_num")
        let ref_link = Expression<String>("ref_link")
        let vip_level = Expression<String>("vip_level")
        let audit_status = Expression<String>("audit_status")
        let sort_order = Expression<String>("sort_order")
        let status = Expression<String>("status")
//        let channels = Expression<Int>("channels")
//        let cover = Expression<Int>("cover")
//        let user = Expression<Int>("user")
        let uid = Expression<String>("uid")
        let lavadj = Expression<String>("lavadj")
        let recommend = Expression<String>("recommend")
        let sourceid = Expression<String>("sourceid")
        let duration = Expression<String>("duration")
        let comment = Expression<String>("comment")
        let sort_order_self = Expression<String>("sort_order_self")
        let play_order = Expression<String>("play_order")
        let reject_time = Expression<String>("reject_time")
        let genre = Expression<String>("genre")
        let genre_channel_id = Expression<String>("genre_channel_id")
        let key = Expression<String>("key")
        let full_tag = Expression<String>("full_tag")
        let b_public = Expression<String>("b_public")
        
        try! db.run(program.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(program_desc)
            t.column(pic_url)
            t.column(create_time)
            t.column(modify_time)
            t.column(pub_time)
            t.column(apply_time)
            t.column(subscribe_num)
            t.column(song_num)
            t.column(play_num)
            t.column(share_num)
            t.column(collect_num)
            t.column(ref_link)
            t.column(vip_level)
            t.column(audit_status)
            t.column(sort_order)
            t.column(status)
//            t.column(channels)
//            t.column(cover)
//            t.column(user)
            t.column(uid)
            t.column(lavadj)
            t.column(recommend)
            t.column(sourceid)
            t.column(duration)
            t.column(comment)
            t.column(sort_order_self)
            t.column(play_order)
            t.column(reject_time)
            t.column(genre)
            t.column(key)
            t.column(full_tag)
            t.column(b_public)
            
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
        let jujing_id = Expression<String>("jujing_id")
        let program_id = Expression<String>("program_id")
        let artist_id = Expression<String>("artist_id")
        let salbum_id = Expression<String>("salbum_id")
        let salbums_name = Expression<String>("salbums_name")
        let artists_name = Expression<String>("artists_name")
        let play_num = Expression<String>("play_num")
        let share_num = Expression<String>("share_num")
        let audio_url = Expression<String>("audio_url")
        let pic_url = Expression<String>("pic_url")
        let status = Expression<String>("status")
        let tsid = Expression<String>("tsid")
        let copyright_status = Expression<String>("copyright_status")
        let artist_code = Expression<String>("artist_code")
        let albumAssetCode = Expression<String>("albumAssetCode")
        let size_128 = Expression<String>("size_128")
        let size_320 = Expression<String>("size_320")
        let remove_time = Expression<String>("remove_time")
        
        try! db.run(song.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(jujing_id)
            t.column(program_id)
            t.column(artist_id)
            t.column(artists_name)
            t.column(salbum_id)
            t.column(salbums_name)
            t.column(play_num)
            t.column(share_num)
            t.column(audio_url)
            t.column(pic_url)
            t.column(status)
            t.column(tsid)
            t.column(copyright_status)
            t.column(artist_code)
            t.column(albumAssetCode)
            t.column(size_128)
            t.column(size_320)
            t.column(remove_time)
        }))
    }
    
    
    func createUserTable() {
        guard let db = db else {
            print("Not found db")
            return
        }
        
        let user = Table("user")
        let id = Expression<Int>("uid")
        let name = Expression<String>("uName")
        let user_type = Expression<String>("user_type")
        let picURL = Expression<String>("picURL")
        let pri_audit_program = Expression<String>("pri_audit_program")
        let pri_create_program = Expression<String>("pri_create_program")
        let pri_item_edit = Expression<String>("pri_item_edit")
        let pri_item_view = Expression<String>("pri_item_view")
        let pri_lavahome_simple = Expression<String>("pri_lavahome_simple")
        let pri_login = Expression<String>("pri_login")
        let pri_cp = Expression<String>("pri_cp")
        let pri_qd = Expression<String>("pri_qd")
        let pri_sc = Expression<String>("pri_sc")
        let pri_vod = Expression<String>("pri_vod")
        let pri_timer = Expression<String>("pri_timer")
        let pri_user_page = Expression<String>("user_name")
        
        try! db.run(user.create(block: { (t) in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(user_type)
            t.column(picURL)
            t.column(pri_audit_program)
            t.column(pri_create_program)
            t.column(pri_item_edit)
            t.column(pri_item_view)
            t.column(pri_lavahome_simple)
            t.column(pri_login)
            t.column(pri_cp)
            t.column(pri_qd)
            t.column(pri_sc)
            t.column(pri_vod)
            t.column(pri_timer)
            t.column(pri_user_page)
        }))
    }

}
