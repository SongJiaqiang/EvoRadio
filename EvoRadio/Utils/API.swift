//
//  API.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/18.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import Alamofire


let api = API()

class API {
    let host = "http://www.lavaradio.com/"
    
    func commonEP(api:String) -> String{
        let url = "\(host)\(api)"
        print("request url--> \(url)")
        
        return url
    }
    
    func fetch_all_channels(onSuccess: [Reflect] -> Void, onFailed: (NSError -> Void)?) {
        
        if let responseData = CoreDB.getAllChannels() {
            let items = Radio.parses(arr: responseData)
            onSuccess(items)
            return
        }
        
        let endpoint = commonEP("api/radio.listAllChannels.json")
        Alamofire.request(.GET, endpoint).responseJSON { (response) in
            
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]
                if dict["err"] as! String == "hapn.ok" {
                    let responseData = dict["data"] as! [[String : AnyObject]]
                    CoreDB.saveAllChannels(responseData)
                    
                    let items = Radio.parses(arr: responseData)
                    onSuccess(items)
                }
                
            } catch let error as NSError {
                print("convert error:\(error)")
                if let _ = onFailed {
                    onFailed!(error)
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
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]
                if dict["err"] as! String == "hapn.ok" {
                    print("request is OK")
                    
                    let responseData = dict["data"] as! [[String : AnyObject]]
                    CoreDB.saveAllNowChannels(responseData)
                    
                    onSuccess(responseData)
                }
                
            } catch let error as NSError {
                print("convert error:\(error)")
                if let _ = onFailed {
                    onFailed!(error)
                }
            }
        }
    }
    
    func fetch_programs(channelID:String, page: Page, onSuccess: [Reflect] -> Void, onFailed: (NSError -> Void)?) {
        let _pn = (page.index+page.size-1) / page.size
        let endpoint = commonEP("api/radio.listChannelPrograms.json?channel_id=\(channelID)&_pn=\(_pn)&_sz=\(page.size)")
        
        Alamofire.request(.GET, endpoint).responseJSON { (response) in
            do {
                
                let dict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]

                if dict["err"] as! String == "hapn.ok" {
                    let items = Program.parses(arr: dict["data"]!["lists"] as! NSArray)
                    onSuccess(items)
                }
                
                
            } catch let error as NSError {
                print("convert error:\(error)")
                if let _ = onFailed {
                    onFailed!(error)
                }
            }
            
        }
    }
    
    func fetch_songs(programID: String,  onSuccess: [Reflect] -> Void, onFailed: (NSError -> Void)?) {
        let endpoint = commonEP("api/play.playProgram.json?program_id=\(programID)")
        
        Alamofire.request(.GET, endpoint).responseJSON { (response) in
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]
                if dict["err"] as! String == "hapn.ok" {
                    let items = Song.parses(arr: dict["data"]!["songs"] as! NSArray)
                    onSuccess(items)
                }
                
            } catch let error as NSError {
                print("convert error:\(error)")
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
                print("convert error:\(error)")
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