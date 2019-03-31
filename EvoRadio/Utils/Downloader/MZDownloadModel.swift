//
//  MZDownloadModel.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 19/04/2016.
//  Copyright © 2016 ideamakerz. All rights reserved.
//

import UIKit

public enum TaskStatus: Int {
    case unknown, gettingInfo, downloading, paused, failed
    
    public func description() -> String {
        switch self {
        case .gettingInfo:
            return "GettingInfo"
        case .downloading:
            return "Downloading"
        case .paused:
            return "Paused"
        case .failed:
            return "Failed"
        default:
            return "Unknown"
        }
    }
}

public class MZDownloadModel: NSObject {
    
    public var fileName: String!
    public var fileURL: String!
    public var status: String = TaskStatus.gettingInfo.description()
    
    public var file: (size: Float, unit: String)?
    public var downloadedFile: (size: Float, unit: String)?
    
    public var remainingTime: (hours: Int, minutes: Int, seconds: Int)?
    
    public var speed: (speed: Float, unit: String)?
    
    public var progress: Float = 0
    
    public var task: URLSessionDownloadTask?
    
    public var startTime: Date?
    
    fileprivate(set) public var destinationPath: String = ""
    
    fileprivate convenience init(fileName: String, fileURL: String) {
        self.init()
        
        self.fileName = fileName
        self.fileURL = fileURL
    }
    
    convenience init(fileName: String, fileURL: String, destinationPath: String) {
        self.init(fileName: fileName, fileURL: fileURL)
        
        self.destinationPath = destinationPath
    }
}
