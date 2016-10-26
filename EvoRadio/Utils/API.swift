//
//  API.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import Alamofire
import EVReflection

let api = API()

class API {
    let host = "http://www.lavaradio.com/"
    
    func commonEP(_ api:String) -> String{
        let url = "\(host)\(api)"
        debugPrint("request url--> \(url)")
        
        return url
    }
    
    /** 获取所有Radio以及其下的所有频道 */
    func fetch_all_channels(_ onSuccess: @escaping ([Radio]) -> Void, onFailed: ((Error) -> Void)?) {
        
        if let responseData = CoreDB.getAllChannels() {
            let items = [Radio](dictArray: responseData as [NSDictionary]?)
            onSuccess(items)
            return
        }
        
        let endpoint = commonEP("api/radio.listAllChannels.json")
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                do {
                    let dict = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                    if dict["err"] as! String == "hapn.ok" {
                        let responseData = dict["data"] as! [[String : AnyObject]]
                        CoreDB.saveAllChannels(responseData)
                        
                        let items = [Radio].init(dictArray: responseData as [NSDictionary]?)
                        
                        onSuccess(items)
                    }
                    
                } catch let error {
                    debugPrint("convert error:\(error)")
                    if let _ = onFailed {
                        onFailed!(error)
                    }
                }
            }
        }
        
    }
    
    /** 获取所有“时刻”频道 */
    func fetch_all_now_channels(_ onSuccess: @escaping ([[String : AnyObject]]) -> Void, onFailed: ((Error) -> Void)?) {
        
        if let responseData = CoreDB.getAllNowChannels() {
            onSuccess(responseData)
            return
        }
        
        let endpoint = commonEP("api/radio.listAllNowChannels.json")
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                do {
                    let dict = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                    
                    if dict["err"] as! String == "hapn.ok" {
                        let responseData = dict["data"] as! [[String : AnyObject]]
                        CoreDB.saveAllNowChannels(responseData)
                        
                        onSuccess(responseData)
                    }
                } catch {}
            }else {
                onFailed!(response.result.error!)
            }
        }
    }
    
    /** 获取精品节目单，分页 */
    func fetch_ground_programs(_ page: Page, onSuccess: @escaping ([EVObject]) -> Void, onFailed: ((Error) -> Void)?) {
        let _pn = (page.index+page.size-1) / page.size
        let endpoint = commonEP("api/radio.listGroundPrograms.json?_pn=\(_pn)&_sz=\(page.size)")
        
        if let responseData = CoreDB.getGroundPrograms(endpoint) {
            let items = [Program](dictArray: responseData as [NSDictionary]?)
            onSuccess(items)
        }
        
        Alamofire.request(endpoint).responseJSON { (response) in
            do {
                
                let dict = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                
                if dict["err"] as! String == "hapn.ok" {
                    let data = dict["data"]!["lists"] as? [[String : AnyObject]]
                    CoreDB.saveGroundPrograms(endpoint, responseData: data!)
                    
                    let items = [Program](dictArray: data as [NSDictionary]?)
                    onSuccess(items)
                }
                
                
            } catch let error {
                if let _ = onFailed {
                    onFailed!(error)
                }
            }
            
        }
    }
    
    /** 根据频道ID获取节目单，分页 */
    func fetch_programs(_ channelID:String, page: Page, onSuccess: @escaping ([EVObject]) -> Void, onFailed: ((Error) -> Void)?) {
        let _pn = (page.index+page.size-1) / page.size
        let endpoint = commonEP("api/radio.listChannelPrograms.json?channel_id=\(channelID)&_pn=\(_pn)&_sz=\(page.size)")
        
        if let responseData = CoreDB.getPrograms(endpoint) {
            let items = [Program](dictArray: responseData as [NSDictionary]?)
            onSuccess(items)
        }
        
        Alamofire.request(endpoint).responseJSON { (response) in
            do {
                
                let dict = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]

                if dict["err"] as! String == "hapn.ok" {
                    let data = dict["data"]!["lists"] as? [[String : AnyObject]]
                    CoreDB.savePrograms(endpoint, responseData: data!)
                    
                    let items = [Program](dictArray: data as [NSDictionary]?)
                    onSuccess(items)
                }
                
                
            } catch let error {
                if let _ = onFailed {
                    onFailed!(error)
                }
            }
            
        }
    }
    
    /** 根据节目单ID获取其下的所有音乐 */
    func fetch_songs(_ programID: String, isVIP: Bool,  onSuccess: @escaping ([EVObject]) -> Void, onFailed: ((Error) -> Void)?) {
        var endpoint = commonEP("api/play.playProgram.json?device=iPhone%20OS%209.3.2&luid=&program_id=\(programID)")
        if isVIP {
            endpoint = commonEP("api/play.sharePlayProgram.json?device=iPhone%20OS%209.3.2&luid=&isShare=1&program_id=\(programID)")
        }
        
        if let responseData = CoreDB.getSongs(endpoint) {
            let items = [Song](dictArray: responseData as [NSDictionary]?)
            onSuccess(items)
        }
        
        Alamofire.request(endpoint).responseJSON { (response) in
            do {
                let dict = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String:AnyObject]
                if dict["err"] as! String == "hapn.ok" {
                    let data = dict["data"]!["songs"] as? [[String: AnyObject]]
                    CoreDB.saveSongs(endpoint, responseData: data!)
                    
                    let items = [Song](dictArray: data! as [NSDictionary]?)
                    onSuccess(items)
                }
                
            } catch let error {
                if let _ = onFailed {
                    onFailed!(error)
                }
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
    
}

struct Page {
    var index: Int
    var size: Int
}
