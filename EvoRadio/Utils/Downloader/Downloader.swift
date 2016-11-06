//
//  Downloader.swift
//  EvoRadio
//
//  Created by Jarvis on 10/29/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

/*
    MZDownloadManager不适合多任务的音乐下载，
    1. 没有任务数量控制
    2. 模型没有主键标记，不好同步列表和下载任务数据
    3. 不能自动去重
 */

import UIKit

class Downloader: NSObject {

//    static var downloadSongs: [DownloadSongInfo] = [DownloadSongInfo]()
    static var downloadingSongs: [DownloadSongInfo] = [DownloadSongInfo]()
    
    // 获取下载
    class func downloadingTaskCount() -> Int{
        var count: Int = 0
        for s in Downloader.downloadingSongs {
            if s.status == TaskStatus.downloading.rawValue as NSNumber {
                count += 1
            }
        }
        return count
    }
    
}
