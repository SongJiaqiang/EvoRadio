//
//  API.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import Alamofire
import EVReflection

let api = API()

class API {
    let host = "http://www.lavaradio.com/"
    
    func commonEP(api:String) -> String{
        let url = "\(host)\(api)"
        debugPrint("request url--> \(url)")
        
        return url
    }
    
    func fetch_all_channels(onSuccess: [EVObject] -> Void, onFailed: (NSError -> Void)?) {
        
        if let responseData = CoreDB.getAllChannels() {
            let items = [Radio](dictArray: responseData)
            onSuccess(items)
            return
        }
        
        let endpoint = commonEP("api/radio.listAllChannels.json")
        Alamofire.request(.GET, endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                do {
                    let dict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]
                    if dict["err"] as! String == "hapn.ok" {
                        let responseData = dict["data"] as! [[String : AnyObject]]
                        CoreDB.saveAllChannels(responseData)
                        
                        let items = [Radio].init(dictArray: responseData)
                        
                        onSuccess(items)
                    }
                    
                } catch let error as NSError {
                    debugPrint("convert error:\(error)")
                    if let _ = onFailed {
                        onFailed!(error)
                    }
                }
            }
        }
        
    }
    
    func fetch_all_now_channels(onSuccess: [[String : AnyObject]] -> Void, onFailed: (NSError -> Void)?) {
        
        if let responseData = CoreDB.getAllNowChannels() {
            onSuccess(responseData)
            return
        }
        
        let endpoint = commonEP("api/radio.listAllNowChannels.json")
        Alamofire.request(.GET, endpoint).responseJSON { (response) in
            if response.result.isSuccess {
                do {
                    let dict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]
                    
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
    
    func fetch_programs(channelID:String, page: Page, onSuccess: [EVObject] -> Void, onFailed: (NSError -> Void)?) {
        let _pn = (page.index+page.size-1) / page.size
        let endpoint = commonEP("api/radio.listChannelPrograms.json?channel_id=\(channelID)&_pn=\(_pn)&_sz=\(page.size)")
        
        if let responseData = CoreDB.getPrograms(endpoint) {
            let items = [Program](dictArray: responseData)
            onSuccess(items)
        }
        
        Alamofire.request(.GET, endpoint).responseJSON { (response) in
            do {
                
                let dict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]

                if dict["err"] as! String == "hapn.ok" {
                    let data = dict["data"]!["lists"] as? [[String : AnyObject]]
                    CoreDB.savePrograms(endpoint, responseData: data!)
                    
                    let items = [Program](dictArray: data)
                    onSuccess(items)
                }
                
                
            } catch let error as NSError {
                if let _ = onFailed {
                    onFailed!(error)
                }
            }
            
        }
    }
    
    func fetch_songs(programID: String, isVIP: Bool,  onSuccess: [EVObject] -> Void, onFailed: (NSError -> Void)?) {
        var endpoint = commonEP("api/play.playProgram.json?device=iPhone%20OS%209.3.2&luid=&program_id=\(programID)")
        if isVIP {
            endpoint = commonEP("api/play.sharePlayProgram.json?device=iPhone%20OS%209.3.2&luid=&isShare=1&program_id=\(programID)")
        }
        
        if let responseData = CoreDB.getSongs(endpoint) {
            let items = [Song](dictArray: responseData)
            onSuccess(items)
        }
        
        Alamofire.request(.GET, endpoint).responseJSON { (response) in
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]
                if dict["err"] as! String == "hapn.ok" {
                    let data = dict["data"]!["songs"] as? [[String: AnyObject]]
                    CoreDB.saveSongs(endpoint, responseData: data!)
                    
                    let items = [Song](dictArray: data!)
                    onSuccess(items)
                }
                
            } catch let error as NSError {
                if let _ = onFailed {
                    onFailed!(error)
                }
            }
            
        }
    }
    
    func fetch_userinfo(onSuccess: [String : AnyObject] -> Void, onFailed: (NSError -> Void)?) {
        let endpoint = commonEP("api/user.getUserInfo")
        
        Alamofire.request(.GET, endpoint).responseJSON { (response) in
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]
                if dict["err"] as! String == "hapn.ok" {
                    onSuccess(dict["data"] as! [String : AnyObject])
                }
                
            } catch let error as NSError {
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