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

class API {
    
    //MARK: - Search music from baidu.com
    static func search_songs_from_baidu(_ keyword: String,  onSuccess: @escaping ([SearchSongInfo]) -> Void, onFailed: ((Error) -> Void)?) {
        
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
    
    static func fetch_song_info_from_baidu(_ songId: String,  onSuccess: @escaping (SearchedResult) -> Void, onFailed: ((Error) -> Void)?) {
    
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
