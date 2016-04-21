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
    
    func downloadFile(fileURL: String) {
        let url = NSURL(string: fileURL)!
        if soundFileExitsWithURL(url) {
            print("File is exit")
            
            
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
                // play music
                MusicManager.sharedManager.addMusicToList(finalDirector.path!)
                MusicManager.sharedManager.playItem()
            }
        }.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            print("\(bytesRead)-\(totalBytesRead)-\(totalBytesExpectedToRead)")
            
            dispatch_async(dispatch_get_main_queue()) {
                // update ui
            }
        }
    }
    
    func soundFileExitsWithURL(fileURL: NSURL) -> Bool{
        let fileManager = NSFileManager.defaultManager()
        let directoryURLs = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let downloadDirector = directoryURLs[0].URLByAppendingPathComponent("download")
        
        if !fileManager.fileExistsAtPath(downloadDirector.path!) {
            return false
        }else {
            // Listing All Files In A Directory
            var contents: [NSURL]
            do {
                contents = try fileManager.contentsOfDirectoryAtURL(downloadDirector, includingPropertiesForKeys: [], options: .SkipsHiddenFiles)
                
                for url in contents {
                    if url.path!.containsString(fileURL.lastPathComponent!) {
                        return true
                    }
                }
            }catch let error as NSError {
                print("List contents of directory failed with error: \(error)")
            }
        }
        
        return false
    }
}