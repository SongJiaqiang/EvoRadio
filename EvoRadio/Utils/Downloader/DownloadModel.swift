//
//  DownloadModel.swift
//  EvoRadio
//
//  Created by Jarvis on 6/7/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

public enum TaskStatus: Int {
    case Unknown
    case GettingInfo
    case Downloading
    case Paused
    case Failed
    
    public func description() -> String {
        switch self {
        case .GettingInfo:
            return "GettingInfo"
        case .Downloading:
            return "Downloading"
        case .Paused:
            return "Paused"
        case .Failed:
            return "Failed"
        default:
            return "Unknown"
        }
    }
}

struct JQFile {
    var size: Float
    var unit: String
}

struct JQTime {
    var hours: Int
    var minutes: Int
    var seconds: Int
}

struct JQSpeed {
    var speed: Float
    var unit: String
}


class DownloadModel: NSObject {
    
    /**
        Designate a directory to store file, default store at Documents folder
        指定存储目录， 如果不指定，默认存储在Documents目录下
     */
    var designatedDirectory: String?
    var fileName: String!
    var fileURL: String!
    var status: String = TaskStatus.GettingInfo.description()
    
    var file: JQFile?
    var downloadedFile: JQFile?
    var remainingTime: JQTime?
    var speed: JQSpeed?
    
    var task: NSURLSessionDownloadTask?
    var startTime: NSDate?
    var progress: Float = 0

    // 用于UI展示
    var dispalyInfo: NSDictionary?
    
    convenience init(fileName: String, fileURL: String, designatedDirectory: String?, dispalyInfo: NSDictionary?) {
        self.init()
        
        self.fileName = fileName
        self.fileURL = fileURL
        self.designatedDirectory = designatedDirectory
        self.dispalyInfo = dispalyInfo
    }
    
}