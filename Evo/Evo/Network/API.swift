//
//  API.swift
//  Evo
//
//  Created by Jarvis on 2019/3/8.
//  Copyright © 2019 SongJiaqiang. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class API {
    
    /// 获取电台列表
    /// http://www.lavaradio.com/api/radio.listAllChannels.json
    class func fetchAllRadios(completion: @escaping (([Radio]) -> Void)) {
        let url = "http://www.lavaradio.com/api/radio.listAllChannels.json"
        print("Request url: \(url)")
        Alamofire.request(url).responseJSON { (response) in
            //            print("rsp => \(rsp)")
            if response.result.isSuccess {
                if let responseValue = response.value as? [String : Any] {
                    if let jsonArray = responseValue["data"] as? [[String : Any]] {
                        let items = Mapper<Radio>().mapArray(JSONArray: jsonArray)
                        print("radios count: \(items.count)")
                        completion(items)
                    }
                }
            }else {
                print("Request failed: \(url)")
            }
        }
    }
    
    /// 根据电台Id获取频道列表
    /// http://www.lavaradio.com/api/radio.listAllChannels.json
    class func fetchAllChannels(radioId: Int, completion: @escaping (([Channel]) -> Void)) {
        let url = "http://www.lavaradio.com/api/radio.listAllChannels.json"
        print("Request url: \(url)")
        Alamofire.request(url).responseJSON { (response) in
//            print("rsp => \(rsp)")
            if response.result.isSuccess {
                if let responseValue = response.value as? [String : Any] {
                    if let jsonArray = responseValue["data"] as? [[String : Any]] {
                        let radios = Mapper<Radio>().mapArray(JSONArray: jsonArray)
                        for radio in radios {
                            if radio.radioId == radioId {
                                let items = radio.channels
                                print("radios count: \(items!.count)")
                                completion(items!)
                            }
                        }
                    }
                }
            }else {
                print("Request failed: \(url)")
            }
        }
    }
    
    /// 获取节目列表
    /// http://www.lavaradio.com/api/radio.listChannelPrograms.json?channel_id=5&_pn=0&_sz=2
    class func fetchPrograms(channelId: String, pageSize: Int=512, pageNum: Int=0, completion: @escaping (([Program]) -> Void)) {
        let url = String(format: "http://www.lavaradio.com/api/radio.listChannelPrograms.json?channel_id=%@&_sz=%d&_pn=%d", channelId, pageSize, pageNum)
        print("Request url: \(url)")
        
        Alamofire.request(url).responseJSON { (response) in
            //            print("rsp => \(rsp)")
            if response.result.isSuccess {
                if let responseValue = response.value as? [String : Any] {
                    if let data = responseValue["data"] as? [String : Any] {
                        if let jsonArray = data["lists"] as? [[String : Any]] {
                            let items = Mapper<Program>().mapArray(JSONArray: jsonArray)
                            print("programs count: \(items.count)")
                            completion(items)
                        }
                    }
                }
                
            }else {
                print("Request failed: \(url)")
            }
        }
    }
    
    /// 获取歌单列表
    /// http://www.lavaradio.com/api/play.playProgramNew.json?program_id=6938
    class func fetchSongs(programId: String, isVIP: Bool=false, completion: @escaping (([Song]) -> Void)) {
        let url = String(format: "http://www.lavaradio.com/api/play.playProgramNew.json?program_id=%@", programId)
        print("Request url: \(url)")
        Alamofire.request(url).responseJSON { (response) in
            //            print("rsp => \(rsp)")
            if response.result.isSuccess {
                if let responseValue = response.value as? [String : Any] {
                    if let data = responseValue["data"] as? [String : Any] {
                        if let jsonArray = data["songs"] as? [[String : Any]] {
                            let items = Mapper<Song>().mapArray(JSONArray: jsonArray)
                            print("songs count: \(items.count)")
                            completion(items)
                        }
                    }
                }
                
            }else {
                print("Request failed: \(url)")
            }
        }
    }
}
