//
//  DownloadManager.swift
//  EvoRadio
//
//  Created by Jarvis on 6/7/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation

protocol DownloadManagerDelegate {
    /** 下载进度更新 */
    func downloadRequestDidUpdateProgress(downloadModel: DownloadModel, index: Int)
    /** 下载任务完成 */
    func downloadRequestFinished(downloadModel: DownloadModel, index: Int)
    /** 下载任务被打断 */
    func downloadRequestDidPopulatedInterruptedTasks(downloadModels: [DownloadModel])
    /** 下载失败 */
    func downloadRequestDidFailedWithError(error: NSError, downloadModel: DownloadModel, index: Int)
    /** 下载任务开始 */
    func downloadRequestStarted(downloadModel: DownloadModel, index: Int)
    /** 下载任务暂停 */
    func downloadRequestDidPaused(downloadModel: DownloadModel, index: Int)
    /** 下载任务重新开始 */
    func downloadRequestDidResumed(downloadModel: DownloadModel, index: Int)
    /** 下载任务失败后重试 */
    func downloadRequestDidRetry(downloadModel: DownloadModel, index: Int)
    /** 下载任务取消 */
    func downloadRequestCanceled(downloadModel: DownloadModel, index: Int)
}

class DownloadManager: NSObject {
    
    var sessionManager: NSURLSession!
    var downloadingArray = [DownloadModel]()
    var delegate: DownloadManagerDelegate?
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    convenience init(session sessionIdentifer: String, delegate: DownloadManagerDelegate?, completion: (() -> Void)?) {
        self.init()
        
        self.sessionManager = backgroundSession(sessionIdentifer)
        self.delegate = delegate
        self.backgroundSessionCompletionHandler = completion
    }
    
    func backgroundSession(sessionIdentifer: String) -> NSURLSession {
        struct sessionStruct {
            static var onceToken: dispatch_once_t = 0
            static var session: NSURLSession? = nil
        }
        
        dispatch_once(&sessionStruct.onceToken, {() -> Void in
            let sessionConfiguration: NSURLSessionConfiguration
            sessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(sessionIdentifer)
            sessionStruct.session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        })
        return sessionStruct.session!
    }
}

//MARK: Private helper functions
extension DownloadManager {
    private func downloadTasks() -> NSArray {
        return tasksForKeyPath("downloadTasks")
    }
    
    private func tasksForKeyPath(keyPath: String) -> NSArray {
        var tasks = []
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        sessionManager.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if keyPath == "downloadTasks" {
                if let pendingTasks: NSArray = downloadTasks {
                    tasks = pendingTasks
                    debugPrint("Pending tasks \(tasks)")
                }
            }
            dispatch_semaphore_signal(semaphore)
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return tasks
    }
    
    /**
     
     */
    private func populateOtherDownloadTasks() {
        let downloadTasks = self.downloadTasks()
        for item in downloadTasks {
            let task = item as! NSURLSessionDownloadTask
            let taskDescComponents: [String] = task.taskDescription!.componentsSeparatedByString(",")
            let fileName = taskDescComponents[0]
            let fileURL = taskDescComponents[1]
            let designatedDirectory = taskDescComponents[2]
            
            let downloadModel = DownloadModel(fileName: fileName, fileURL: fileURL, designatedDirectory: designatedDirectory, dispalyInfo: nil)
            downloadModel.task = task
            downloadModel.startTime = NSDate()
            
            if task.state == .Running {
                downloadModel.status = TaskStatus.Downloading.description()
                downloadingArray.append(downloadModel)
            }else if task.state == .Suspended {
                downloadModel.status = TaskStatus.Paused.description()
                downloadingArray.append(downloadModel)
            }else {
                downloadModel.status = TaskStatus.Failed.description()
            }
        }
    }
    
    
    private func isValidResumeData(resumeData: NSData?) -> Bool {
        guard resumeData != nil || resumeData?.length > 0 else {
            return false
        }
        
        do {
            let resumeDict: AnyObject = try NSPropertyListSerialization.propertyListWithData(resumeData!, options: .Immutable, format: nil)
            var localFilePath = resumeDict.objectForKey("NSURLSessionResumeInfoLocalPath") as! String
            if localFilePath.isEmpty {
                localFilePath = NSTemporaryDirectory().stringByAppendingString(resumeDict["NSURLSessionResumeInfoTempFileName"] as! String)
            }
            
            let fileManager = NSFileManager.defaultManager()
            debugPrint("resume data file exists: \(fileManager.fileExistsAtPath(localFilePath as String))")
            return fileManager.fileExistsAtPath(localFilePath as String)
        }catch let error as NSError {
            debugPrint("Resume data is nil: \(error)")
            return false
        }
    }
    
}

extension DownloadManager: NSURLSessionDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        for (index, downloadModel) in downloadingArray.enumerate() {
            if downloadTask.isEqual(downloadModel.task) {
                dispatch_async(dispatch_get_main_queue(), { 
                    let receivedBytesCount = Double(downloadTask.countOfBytesReceived)
                    let totalBytesCount = Double(downloadTask.countOfBytesExpectedToReceive)
                    let progress = Float(receivedBytesCount / totalBytesCount)
                    
                    let taskStartedDate = downloadModel.startTime
                    let timeInterval = taskStartedDate?.timeIntervalSinceNow
                    let downloadTime = NSTimeInterval(-1 * timeInterval!)
                    let speed = Float(totalBytesWritten) / Float(downloadTime)
                    
                    let remainingCountentLength = totalBytesExpectedToWrite - totalBytesWritten
                    
                    let remainingTime = remainingCountentLength / Int64(speed)
                    let hours = Int(remainingTime) / 3600
                    let minutes = (Int(remainingTime) - hours * 3600) / 60
                    let seconds = Int(remainingTime) - hours * 3600 - minutes * 60
                    
                    let totalFileSize = DownloadUtility.calculateFileSizeInUnit(totalBytesExpectedToWrite)
                    let totalFileSizeUnit = DownloadUtility.calculateUnit(totalBytesExpectedToWrite)
                    
                    let downloadedFileSize = DownloadUtility.calculateFileSizeInUnit(totalBytesWritten)
                    let downloadedFileSizeUnit = DownloadUtility.calculateUnit(totalBytesWritten)
                    
                    let speedSize = DownloadUtility.calculateFileSizeInUnit(Int64(speed))
                    let speedUnit = DownloadUtility.calculateUnit(Int64(speed))
                    
                    downloadModel.remainingTime = JQTime(hours: hours, minutes: minutes, seconds: seconds)
                    downloadModel.file = JQFile(size: totalFileSize, unit: totalFileSizeUnit)
                    downloadModel.downloadedFile = JQFile(size: downloadedFileSize, unit: downloadedFileSizeUnit)
                    downloadModel.speed = JQSpeed(speed: speedSize, unit: speedUnit)
                    downloadModel.progress = progress
                    
                    self.downloadingArray[index] = downloadModel
                    
                    /*   delegate, notification, closure  */
                    self.delegate?.downloadRequestDidUpdateProgress(downloadModel, index: index)
                    
                })
                break
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        for (index, downloadModel) in downloadingArray.enumerate() {
            if downloadTask.isEqual(downloadModel.task) {
                let fileName = downloadModel.fileName
                var destinationPath: String
                let fileManager = NSFileManager.defaultManager()
                
                if let directory = downloadModel.designatedDirectory {
                    destinationPath = directory.stringByAppendingString("/").stringByAppendingString(fileName)
                    
                    if !fileManager.fileExistsAtPath(destinationPath) {
                        do {
                            try fileManager.createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
                        }catch let error as NSError {
                            debugPrint("Create new Directory failed with error: \(error)")
                            dispatch_async(dispatch_get_main_queue(), {
                                /*   delegate, notification, closure  */
                                self.delegate?.downloadRequestDidFailedWithError(error, downloadModel: downloadModel, index: index)
                            })
                        }
                    }
                }else {
                    destinationPath = DownloadUtility.baseFilePath.stringByAppendingString("/").stringByAppendingString(fileName)
                }
                
                let fileURL = NSURL(fileURLWithPath: destinationPath)
                debugPrint("Directory path is \(destinationPath)")
                
                do {
                    try fileManager.moveItemAtURL(location, toURL: fileURL)
                }catch let error as NSError {
                    debugPrint("Moving download file failed with error: \(error)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.delegate?.downloadRequestDidFailedWithError(error, downloadModel: downloadModel, index: index)
                    })
                }
                break
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        debugPrint("Task id: \(task.taskIdentifier)")
        if error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey]?.integerValue == NSURLErrorCancelledReasonUserForceQuitApplication || error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey]?.integerValue == NSURLErrorCancelledReasonBackgroundUpdatesDisabled {
            let downloadTask = task as! NSURLSessionDownloadTask
            let taskDescComponents = downloadTask.taskDescription?.componentsSeparatedByString(",")
            let fileName = taskDescComponents![0]
            let fileURL = taskDescComponents![1]
            let designatedDirectory = taskDescComponents![2]
            
            let downloadModel = DownloadModel(fileName: fileName, fileURL: fileURL, designatedDirectory: designatedDirectory, dispalyInfo: nil
            )
            downloadModel.status = TaskStatus.Failed.description()
            downloadModel.task = downloadTask
            
            let resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData] as! NSData
            
            dispatch_async(dispatch_get_main_queue(), { 
                var newTask = task
                if self.isValidResumeData(resumeData) {
                    newTask = self.sessionManager.downloadTaskWithResumeData(resumeData)
                }else {
                    newTask = self.sessionManager.downloadTaskWithURL(NSURL(string: fileURL)!)
                }
                
                newTask.taskDescription = task.taskDescription
                downloadModel.task = newTask as? NSURLSessionDownloadTask
                
                self.downloadingArray.append(downloadModel)
                
                self.delegate?.downloadRequestDidPopulatedInterruptedTasks(self.downloadingArray)
                
            })
        }else {
            for (index, downloadModel) in self.downloadingArray.enumerate() {
                if task.isEqual(downloadModel.task) {
                    if error?.code == NSURLErrorCancelled || error == nil {
                        dispatch_async(dispatch_get_main_queue(), { 
                            self.downloadingArray.removeAtIndex(index)
                            /*   delegate, notification, closure  */
                            if error == nil {
                                self.delegate?.downloadRequestFinished(downloadModel, index: index)
                            }else {
                                self.delegate?.downloadRequestCanceled(downloadModel, index: index)
                            }
                            
                        })
                    }else {
                        let resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData]
                        dispatch_async(dispatch_get_main_queue(), { 
                            var newTask = task
                            if resumeData != nil && self.isValidResumeData(resumeData as? NSData) {
                                newTask = self.sessionManager.downloadTaskWithResumeData(resumeData as! NSData)
                            }else {
                                newTask = self.sessionManager.downloadTaskWithURL(NSURL(string: downloadModel.fileURL)!)
                            }
                            
                            newTask.taskDescription = task.taskDescription
                            downloadModel.status = TaskStatus.Failed.description()
                            downloadModel.task = newTask as? NSURLSessionDownloadTask
                            
                            self.downloadingArray[index] = downloadModel
                            
                            if let _ = error {
                                self.delegate?.downloadRequestDidFailedWithError(error!, downloadModel: downloadModel, index: index)
                            }else {
                                let unknownError = NSError(domain: "DownloadManagerDomain", code: 2150, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred."])
                                self.delegate?.downloadRequestDidFailedWithError(unknownError, downloadModel: downloadModel, index: index)
                            }
                            
                        })
                    }
                    break
                }
            }
        }
        
        
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let completion = self.backgroundSessionCompletionHandler {
            dispatch_async(dispatch_get_main_queue(), { 
                completion()
            })
        }
        debugPrint("All tasks are finished")
    }
    
}

extension DownloadManager {
    /** 
        @desc 添加下载任务
        @params
            fileName: 文件名
            fileURL: 文件地址
            designatedDirectory: 指定存储目录
     */
    func addDownloadTask(fileName: String, fileURL: String, designatedDirectory: String, dispalyInfo: NSDictionary?) {
        
        let downloadModel = DownloadModel(fileName: fileName, fileURL: fileURL, designatedDirectory: designatedDirectory, dispalyInfo: dispalyInfo)
        downloadModel.startTime = NSDate()
        downloadModel.status = TaskStatus.Downloading.description()
        
        // 判断文件是否已存在
        if fileExistsWithName(fileName, atDirectory: designatedDirectory) {
            debugPrint("音乐已下载成功")
            self.delegate?.downloadRequestFinished(downloadModel, index: -1)
            return
        }
        
        // 判断是否已经开始在下载队列中
        for item in downloadingArray {
            if item.fileName == fileName && item.designatedDirectory == designatedDirectory {
                debugPrint("音乐正在下载中")
                return
            }
        }
        
        let url = NSURL(string: fileURL)
        let request = NSURLRequest(URL: url!)
        let downloadTask = sessionManager.downloadTaskWithRequest(request)
        downloadTask.taskDescription = [fileName, fileURL, designatedDirectory].joinWithSeparator(",")
        downloadTask.resume()
        downloadModel.task = downloadTask
        
        downloadingArray.append(downloadModel)
        self.delegate?.downloadRequestStarted(downloadModel, index: downloadingArray.count-1)
        
        debugPrint("Add task to session manager: \(downloadTask.taskDescription)")
    }
    
    func pauseDownloadTaskAtIndex(index: Int) {
        if index >= downloadingArray.count || index < 0 {
            return
        }
        
        let downloadModel = downloadingArray[index]
        guard downloadModel.status != TaskStatus.Paused.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        downloadTask?.suspend()
        downloadModel.status = TaskStatus.Paused.description()
        downloadModel.startTime = NSDate()
        
        downloadingArray[index] = downloadModel
        
        self.delegate?.downloadRequestDidPaused(downloadModel, index: index)
    }
    
    func resumeDownloadTaskAtIndex(index: Int) {
        if index >= downloadingArray.count || index < 0 {
            return
        }
        
        let downloadModel = downloadingArray[index]
        guard downloadModel.status != TaskStatus.Downloading.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        downloadTask?.resume()
        downloadModel.status = TaskStatus.Downloading.description()
        
        downloadingArray[index] = downloadModel
        
        self.delegate?.downloadRequestDidResumed(downloadModel, index: index)
    }
    
    func retryDownloadTaskAtIndex(index: Int) {
        if index >= downloadingArray.count || index < 0 {
            return
        }
        
        let downloadModel = downloadingArray[index]
        guard downloadModel.status != TaskStatus.Downloading.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        downloadTask?.resume()
        downloadModel.startTime = NSDate()
        downloadModel.status = TaskStatus.Downloading.description()
        
        downloadingArray[index] = downloadModel
        
        self.delegate?.downloadRequestDidRetry(downloadModel, index: index)
    }
    
    func cancelTaskAtIndex(index: Int) {
        if index >= downloadingArray.count || index < 0 {
            return
        }
        
        let downloadModel = downloadingArray[index]
        let downloadTask = downloadModel.task
        downloadTask?.cancel()
    }
    
    /** 后台下载 */
    func presentNotificationForDownload(notificationAction: String, notificationBody: String) {
        let appState = UIApplication.sharedApplication().applicationState
        
        if appState == .Background {
            let localNotification = UILocalNotification()
            localNotification.alertBody = notificationBody
            localNotification.alertAction = notificationAction
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.applicationIconBadgeNumber += 1
            
            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
        }
    }
 
    func fileExistsWithName(fileName: String, atDirectory: String) -> Bool{
        let filePath = atDirectory.appendPathComponent(fileName)
        return NSFileManager.defaultManager().fileExistsAtPath(filePath)
    }
}







