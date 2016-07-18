//
//  DownloadUtility.swift
//  EvoRadio
//
//  Created by Jarvis on 6/7/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

class DownloadUtility {
    
    static let DownloadCompletedNotification: String = {
        return "cn.songjiaqiang.download_completed_notification"
    }()
    
    static let baseFilePath: String = {
        let homeDir: String = NSHomeDirectory()
        return homeDir.stringByAppendingString("/").stringByAppendingString("Documents")
    }()
    
    /** 
        Get an unique filename, if file already exists, return a new filename append with "-<0..9>"
        获取一个唯一文件名，如果指定路径中的文件已经存在，则返回一个在尾部追加数字字符的文件名，例如：天空之城.mp3 -> 天空之城-1.mp3
     */
    class func getUniqueFileNameWithPath(filePath: NSString) -> String {
        let fullFileName: NSString = filePath.lastPathComponent
        let fileName: String = fullFileName.stringByDeletingPathExtension
        let fileExtension: String = fullFileName.pathExtension
        var suggestedFileName: String = fileName
        
        var isUnique: Bool = false
        var fileNumber: Int = 0
        
        repeat {
            var fileDocDirectorypath: String?
            
            if fileExtension.isEmpty {
                fileDocDirectorypath = "\(filePath.stringByDeletingLastPathComponent)/\(suggestedFileName)"
            }else {
                fileDocDirectorypath = "\(filePath.stringByDeletingLastPathComponent)/\(suggestedFileName).\(fileExtension)"
            }
            
            if NSFileManager.defaultManager().fileExistsAtPath(fileDocDirectorypath!) {
                fileNumber += 1
                suggestedFileName = "\(fileName)-\(fileNumber)"
            }else {
                isUnique = true
                if !fileExtension.isEmpty {
                    suggestedFileName = "\(suggestedFileName).\(fileExtension)"
                }
            }
        } while isUnique == false
        
        return suggestedFileName
    }
    
    /**
        计算单位量GB、MB、KB、Bytes
    */
    class func calculateFileSizeInUnit(contentLength: Int64) -> Float {
        let dataLength: Float64 = Float64(contentLength)
        let n:Float64 = 1024.0
        if dataLength >= (n*n*n) {
            return Float(dataLength/(n*n*n))
        }else if dataLength >= (n*n) {
            return Float(dataLength/(n*n))
        }else if dataLength >= n {
            return Float(dataLength/n)
        }else {
            return Float(dataLength)
        }
    }
    
    /**
        判断单位字符GB、MB、KB、Bytes
     */
    class func calculateUnit(contentlength: Int64) -> String {
        let n:Int64 = 1024
        if contentlength >= (n*n*n) {
            return "GB"
        }else if contentlength >= (n*n) {
            return "MB"
        }else if contentlength >= n {
            return "KB"
        }else {
            return "Bytes"
        }
    }
    
    /**
        文件尺寸格式化
     */
    class func formatFileSize(contentLength: Int64) -> JQFile{
        let dataLength: Float64 = Float64(contentLength)
        let n:Float64 = 1024.0
        if dataLength >= (n*n*n) {
            return JQFile(size: Float(dataLength/(n*n*n)), unit: "GB")
        }else if dataLength >= (n*n) {
            return JQFile(size: Float(dataLength/(n*n)), unit: "MB")
        }else if dataLength >= n {
            return JQFile(size: Float(dataLength/n), unit: "KB")
        }else {
            return JQFile(size: Float(dataLength), unit: "Bytes")
        }
    }
    
    /**
     
     */
    class func addSkipBackupAttributeToItemAtURL(docDirectoryPath: String) -> Bool {
        let url = NSURL(string: docDirectoryPath)
        if NSFileManager.defaultManager().fileExistsAtPath(docDirectoryPath) {
            do {
                try url?.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
                return true
            } catch let error as NSError {
                debugPrint("Set resource value failed with error: \(error)\nError excluding file: \(url?.lastPathComponent)")
                return false
            }
        }else {
            return false
        }
    }
    
    /**
        获取硬盘可用空间大小
     */
    class func getFreeDiskspace() -> Int64? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        do {
            let systemAttributes: AnyObject = try NSFileManager.defaultManager().attributesOfFileSystemForPath(documentDirectoryPath.last!)
            let freeSize = systemAttributes.objectForKey(NSFileSystemFreeSize)
            return freeSize?.longLongValue
        }catch let error as NSError {
            debugPrint("Obtaining system memory info failed with error: \(error)")
            return nil
        }
    }
    
    
}