//
//  API.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

let api = API()

class API {
    let host = "http://www.lavaradio.com/"
    
    func commonEP(_ api:String) -> String{
        let url = "\(host)\(api)"
        debugPrint(">>> request url: \(url)")
        
        return url
    }
    
    /** 获取所有Radio以及其下的所有频道 */
    func fetch_all_channels(_ onSuccess: @escaping ([Radio]) -> Void, onFailed: ((Error) -> Void)?) {
        
        if let jsonArray = CoreDB.getAllChannels() {
            DispatchQueue.global(qos: .default).async {
                let items = Mapper<Radio>().mapArray(JSONArray: jsonArray)
                onSuccess(items)
            }
            return
        }
        
        let endpoint = commonEP("api/radio.listAllChannels.json")
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {

                if let responseValue = response.value as? [String : Any] {
                    if let jsonArray = responseValue["data"] as? [[String : Any]] {
                        CoreDB.saveAllChannels(jsonArray)
                        
                        let items = Mapper<Radio>().mapArray(JSONArray: jsonArray)
                        print("radios count: \(items.count)")

                        onSuccess(items)
                    }
                }
                
            }else {
                print("Request failed: \(endpoint)")
            }
        }
        
    }
    
    /** 获取所有“时刻”频道 */
    func fetch_all_now_channels(_ onSuccess: @escaping ([NowChannel]) -> Void, onFailed: ((Error) -> Void)?) {
        let endpoint = commonEP("api/radio.listAllNowChannels.json")
        
        // 从缓存加载
        if let jsonArray = CoreDB.getAllNowChannels() {
            let items = Mapper<NowChannel>().mapArray(JSONArray: jsonArray)
            onSuccess(items)
            return
        }
        
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let jsonArray = responseValue["data"] as? [[String : Any]] {
                        CoreDB.saveAllNowChannels(jsonArray)
                        
                        let items = Mapper<NowChannel>().mapArray(JSONArray: jsonArray)
                        print("nowChannels count: \(items.count)")
                        
                        onSuccess(items)
                    }
                }
                
            }else {
                print("Request failed: \(endpoint)")
            }
            
        }
    }
    
    /** 获取精品节目单，分页 */
    func fetch_ground_programs(_ page: Page, onSuccess: @escaping ([Program]) -> Void, onFailed: ((Error) -> Void)?) {
        let _pn = (page.index+page.size-1) / page.size
        let endpoint = commonEP("api/radio.listGroundPrograms.json?_pn=\(_pn)&_sz=\(page.size)")
        
        
        // 从缓存加载
        if let jsonArray = CoreDB.getGroundPrograms(endpoint) {
            DispatchQueue.global(qos: .default).async {
                let items = Mapper<Program>().mapArray(JSONArray: jsonArray)
                onSuccess(items)
            }
            return
        }
        
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let data = responseValue["data"] as? [String : Any] {
                        if let jsonArray = data["lists"] as? [[String : Any]] {
                            CoreDB.saveGroundPrograms(endpoint, jsonArray: jsonArray)
                            
                            let items = Mapper<Program>().mapArray(JSONArray: jsonArray)
                            print("ground programs count: \(items.count)")
                            
                            onSuccess(items)
                        }
                    }
                }
                
            }else {
                print("Request failed: \(endpoint)")
            }
            
        }
    }
    
    
    /** 根据频道ID获取节目单，分页 */
    func fetch_programs(_ channelID:String, page: Page, onSuccess: @escaping ([Program]) -> Void, onFailed: ((Error) -> Void)?) {
        let _pn = (page.index+page.size-1) / page.size
        let endpoint = commonEP("api/radio.listChannelPrograms.json?channel_id=\(channelID)&_pn=\(_pn)&_sz=\(page.size)")
        
        // 从缓存加载
        if let jsonArray = CoreDB.getPrograms(endpoint) {
            DispatchQueue.global(qos: .default).async {
                let items = Mapper<Program>().mapArray(JSONArray: jsonArray)
                onSuccess(items)
            }
            return
        }
        
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let data = responseValue["data"] as? [String : Any] {
                        if let jsonArray = data["lists"] as? [[String : Any]] {
                            CoreDB.savePrograms(endpoint, jsonArray: jsonArray)
                            
                            let items = Mapper<Program>().mapArray(JSONArray: jsonArray)
                            print("programs count: \(items.count)")
                            
                            onSuccess(items)
                        }
                    }
                }
                
            }else {
                print("Request failed: \(endpoint)")
            }
            
        }
    }

    /** 根据节目单ID获取其下的所有音乐 */
    func fetch_songs(_ programID: String, isVIP: Bool,  onSuccess: @escaping ([Song]) -> Void, onFailed: ((Error) -> Void)?) {
        var endpoint = commonEP("api/play.playProgram.json?device=iPhone%20OS%209.3.2&luid=&program_id=\(programID)")
        if isVIP {
            endpoint = commonEP("api/play.sharePlayProgram.json?device=iPhone%20OS%209.3.2&luid=&isShare=1&program_id=\(programID)")
        }

        // 从缓存加载
        if let jsonArray = CoreDB.getSongs(endpoint) {
            DispatchQueue.global(qos: .default).async {
                let items = Mapper<Song>().mapArray(JSONArray: jsonArray)
                onSuccess(items)
            }
        }
        
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let data = responseValue["data"] as? [String : Any] {
                        if let jsonArray = data["songs"] as? [[String : Any]] {
                            CoreDB.saveSongs(endpoint, jsonArray: jsonArray)
                            
                            let items = Mapper<Song>().mapArray(JSONArray: jsonArray)
                            print("songs count: \(items.count)")
                            
                            onSuccess(items)
                        }
                    }
                }
                
            }else {
                print("Request failed: \(endpoint)")
            }
        }
    }
    
    /** 获取当前登录用户的相关信息 */
    func fetch_userinfo(_ onSuccess: @escaping ([String : AnyObject]) -> Void, onFailed: ((Error) -> Void)?) {
        let endpoint = commonEP("api/user.getUserInfo")
        
        Alamofire.request(endpoint).responseJSON { (response) in
            do {
                let dict = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                if dict["err"] as! String == "hapn.ok" {
                    onSuccess(dict["data"] as! [String : AnyObject])
                }
                
            } catch let error {
                if let _ = onFailed {
                    onFailed!(error)
                }
            }
        }
    }
    
    //MARK: - Search music from baidu.com
    func search_songs_from_baidu(_ keyword: String,  onSuccess: @escaping ([SearchSongInfo]) -> Void, onFailed: ((Error) -> Void)?) {
        
        let endpoint = String(format: "http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.search.catalogSug&query=%@", keyword)
        let encodedEP = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        // 从网络加载
        Alamofire.request(encodedEP!).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let jsonArray = responseValue["song"] as? [[String : Any]] {
                        let items = Mapper<SearchSongInfo>().mapArray(JSONArray: jsonArray)
                        onSuccess(items)
                    }
                }
            }else {
                print("Request failed: \(endpoint)")
            }
        }
    }
    
    func fetch_song_info_from_baidu(_ songId: String,  onSuccess: @escaping (SearchedResult) -> Void, onFailed: ((Error) -> Void)?) {
    
        let endpoint = String(format: "http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.song.play&songid=%@", songId)
        
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let searchedResult = SearchedResult(JSON: responseValue) {
                        onSuccess(searchedResult)
                    }
                }
            }else {
                print("Request failed: \(endpoint)")
            }
        }
        
    }
    
    
}

struct Page {
    var index: Int
    var size: Int
}
