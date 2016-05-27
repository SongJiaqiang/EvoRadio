//
//  Downloader.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/21.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import Foundation
import Alamofire


class Downloader: NSObject {
    
    //MARK: instance
    class var downloader: Downloader {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: Downloader! = nil
        }
        dispatch_once(&Static.onceToken) { () -> Void in
            Static.instance = Downloader()
        }
        
        return Static.instance
    }
    
    func downloadFile(fileURL: String, complete: ((String) -> Void)?, progress:((Float, Float) -> Void)?) {
        let url = NSURL(string: fileURL)!
        if let exitUrl = soundFileExitsWithURL(url) {
            print("File is exit")
            if let _ = complete {
                complete!(exitUrl.path!)
            }
            
//            MusicManager.sharedManager.addMusicToList(exitUrl.path!)
//            if MusicManager.sharedManager.isPlaying() {
//                MusicManager.sharedManager.playNext()
//            }else {
//                MusicManager.sharedManager.playItem()
//            }
            
            return
        }
        
        
        let fileManager = NSFileManager.defaultManager()
        
        let directoryURLs = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let downloadDirector = directoryURLs[0].URLByAppendingPathComponent("download")
        
        if !fileManager.fileExistsAtPath(downloadDirector.path!) {
            do {
                try fileManager.createDirectoryAtURL(downloadDirector, withIntermediateDirectories: false, attributes: nil)
            }catch let error as NSError {
                print("create director failed with error: \(error)")
            }
        }

        let finalDirector = downloadDirector.URLByAppendingPathComponent(url.lastPathComponent!)
        
        Alamofire.download(.GET, fileURL, destination: { temporaryURL, response -> NSURL in
            
            return finalDirector
            
        }).response { (request, response, data, error) in
            if let error = error {
                print("download error: \(error)")
            }else {
                print("download finished")
                
                if let _ = complete {
                    complete!(finalDirector.path!)
                }
            }
        }.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            if let _ = progress {
                progress!(Float(bytesRead)/1000.0, (Float(totalBytesRead) / Float(totalBytesExpectedToRead)))
            }

        }
    }
    
    func soundFileExitsWithURL(fileURL: NSURL) -> NSURL?{
        let fileManager = NSFileManager.defaultManager()
        let directoryURLs = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let downloadDirector = directoryURLs[0].URLByAppendingPathComponent("download")
        
        if !fileManager.fileExistsAtPath(downloadDirector.path!) {
            return nil
        }else {
            // Listing All Files In A Directory
            var contents: [NSURL]
            do {
                contents = try fileManager.contentsOfDirectoryAtURL(downloadDirector, includingPropertiesForKeys: [], options: .SkipsHiddenFiles)
                
                for url in contents {
                    if url.path!.containsString(fileURL.lastPathComponent!) {
                        return url
                    }
                }
            }catch let error as NSError {
                print("List contents of directory failed with error: \(error)")
            }
        }
        
        return nil
    }
}