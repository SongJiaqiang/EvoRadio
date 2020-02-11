//
//  Lava.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2020/2/8.
//  Copyright © 2020 JQTech. All rights reserved.
//


import Foundation
import Alamofire
import ObjectMapper

class Lava: NSObject {
    static let host = "http://www.lavaradio.com/"
    
    static func commonEP(_ api:String) -> String{
        let url = "\(host)\(api)"
        debugPrint(">>> request url: \(url)")
        return url
    }
    
    /** 获取所有Radio以及其下的所有频道 */
    static func fetch_all_radios(_ onSuccess: @escaping ([LRRadio]) -> Void, onFailed: ((Error) -> Void)?) {
        let endpoint = commonEP("api/radio.listAllChannels.json")
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                if let responseValue = response.value as? [String : Any] {
                    if let jsonArray = responseValue["data"] as? [[String : Any]] {
                        let items = Mapper<LRRadio>().mapArray(JSONArray: jsonArray)
                        onSuccess(items)
                    }
                }
                
            }else {
                print("Request failed: \(endpoint)")
            }
        }
    }
    
    /** 获取所有“时刻”频道 */
    static func fetch_all_now_channels(_ onSuccess: @escaping ([LRNowChannel]) -> Void, onFailed: ((Error) -> Void)?) {
        let endpoint = commonEP("api/radio.listAllNowChannels.json")
        
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let jsonArray = responseValue["data"] as? [[String : Any]] {
                        
                        let items = Mapper<LRNowChannel>().mapArray(JSONArray: jsonArray)
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
    static func fetch_ground_programs(_ page: LRPage, onSuccess: @escaping ([LRProgram]) -> Void, onFailed: ((Error) -> Void)?) {
        let _pn = (page.index+page.size-1) / page.size
        let endpoint = commonEP("api/radio.listGroundPrograms.json?_pn=\(_pn)&_sz=\(page.size)")
        
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let data = responseValue["data"] as? [String : Any] {
                        if let jsonArray = data["lists"] as? [[String : Any]] {                            
                            let items = Mapper<LRProgram>().mapArray(JSONArray: jsonArray)
                            
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
    static func fetch_programs(_ channelId:String, page: LRPage, onSuccess: @escaping ([LRProgram]) -> Void, onFailed: ((Error) -> Void)?) {
        let _pn = (page.index+page.size-1) / page.size
        let endpoint = commonEP("api/radio.listChannelPrograms.json?channel_id=\(channelId)&_pn=\(_pn)&_sz=\(page.size)")
        
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let data = responseValue["data"] as? [String : Any] {
                        if let jsonArray = data["lists"] as? [[String : Any]] {
                            let items = Mapper<LRProgram>().mapArray(JSONArray: jsonArray)
                            
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
    static func fetch_songs(_ programId: String, isVIP: Bool = true,  onSuccess: @escaping ([LRSong]) -> Void, onFailed: ((Error) -> Void)?) {
        
        let endpoint = commonEP("api/play.sharePlayProgram.json?program_id=\(programId)&isShare=\(isVIP ? 1 : 0)")
        
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                
                if let responseValue = response.value as? [String : Any] {
                    if let data = responseValue["data"] as? [String : Any] {
                        if let jsonArray = data["songs"] as? [[String : Any]] {
                            let items = Mapper<LRSong>().mapArray(JSONArray: jsonArray)
                            
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
    static func fetch_userinfo(_ onSuccess: @escaping ([String : AnyObject]) -> Void, onFailed: ((Error) -> Void)?) {
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
    
}

struct LRPage {
    var index: Int
    var size: Int
}
