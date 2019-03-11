//
//  ViewController.swift
//  Evo
//
//  Created by Jarvis on 2019/3/6.
//  Copyright © 2019 SongJiaqiang. All rights reserved.
//

import Cocoa
import Alamofire

class ViewController: NSViewController {

    @IBOutlet weak var logTextView: NSTextView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var radioLabel: NSTextField!
    @IBOutlet weak var channelLabel: NSTextField!
    @IBOutlet weak var programLabel: NSTextField!
    @IBOutlet weak var songLabel: NSTextField!
    @IBOutlet weak var downloadProgress: NSProgressIndicator!
    
    var allRadios: [Radio]?
    var currentChannels:[Channel]?
    var currentPrograms:[Program]?
    var currentSongs:[Song]?
    
    var radioIndex: Int = 0
    var channelIndex: Int = 0
    var programIndex: Int = 0
    var songIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Downloader"
        
        let (rIndex, cIndex, pIndex, sIndex) = fetchIndexesCache()
        radioIndex = rIndex
        channelIndex = cIndex
        programIndex = pIndex
        songIndex = sIndex
        
//        radioIndex = 1
//        channelIndex = 11
//        programIndex = 0
//        songIndex = 0
        
        API.fetchAllRadios { (radios) in
            self.allRadios = radios

            self.download()
        }
        
    }

    func download() {
        guard let radios = allRadios else {
            return
        }
        // 创建基础目录
        let manager = FileManager.default
        if let desktopDirectory = manager.urls(for: .desktopDirectory, in:.userDomainMask).first {
            var baseUrl = desktopDirectory
            baseUrl = URL(fileURLWithPath: "/Volumes/JQHD/", isDirectory: true)
            let evoUrl = createFolder("evo", baseUrl: baseUrl)
            
            if let radiosJSONFile = evoUrl?.appendingPathComponent("radios.json") {
                if !FileManager.default.fileExists(atPath: radiosJSONFile.path) {
                    let radiosJSON = radios.toJSONString()
                    try! radiosJSON?.write(to: radiosJSONFile, atomically: true, encoding: .utf8)
                }
            }
            
            // 创建radio文件夹
            let radio = radios[radioIndex]
            let radioFolderName = String(format: "%d_%@", radio.radioId!, radio.radioName!)
            let radioFolderUrl = self.createFolder(radioFolderName, baseUrl: evoUrl!)
            radioLabel.stringValue = String(format: "电台：%@ (%d/%d)", radioFolderName, radioIndex, radios.count)
            
            func processChannels(_ channels: [Channel]) {
                let channel = channels[self.channelIndex]
                let channelFolderName = String(format: "%@_%@", channel.channelId!, channel.channelName!)
                let channelFolderUrl = self.createFolder(channelFolderName, baseUrl: radioFolderUrl!)
                channelLabel.stringValue = String(format: "频道：%@ (%d/%d)", channelFolderName, self.channelIndex, channels.count)
                
                if let channelsJSONFile = radioFolderUrl?.appendingPathComponent("channels.json") {
                    if !FileManager.default.fileExists(atPath: channelsJSONFile.path) {
                        let newChannels = channels
                        let channelsJSON = newChannels.toJSONString()
                        try! channelsJSON?.write(to: channelsJSONFile, atomically: true, encoding: .utf8)
                    }
                }
                
                func processPrograms(_ programs: [Program]) {
                    
                    let program = programs[self.programIndex]
                    let programFolderName = String(format: "%@_%@", program.programId!, program.programName!)
                    let programFolderUrl = self.createFolder(programFolderName, baseUrl: channelFolderUrl!)
                    self.programLabel.stringValue = String(format: "节目：%@ (%d/%d)", programFolderName, self.programIndex, programs.count)
                    
                    if let programsJSONFile = channelFolderUrl?.appendingPathComponent("programs.json") {
                        if !FileManager.default.fileExists(atPath: programsJSONFile.path) {
                            let newPrograms = programs
                            let programsJSON = newPrograms.toJSONString()
                            try! programsJSON?.write(to: programsJSONFile, atomically: true, encoding: .utf8)
                        }
                    }
                    
                    func processSongs(_ songs: [Song]) {
                        let song = songs[self.songIndex]
                        if let audioURL = song.audioURL {
                            let songFileName = String(format: "%@_%@", song.songId!, song.songName!)
                            let songFileUrl = programFolderUrl?.appendingPathComponent(songFileName).appendingPathExtension("mp3")
                            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                                return (songFileUrl!, [.removePreviousFile, .createIntermediateDirectories])
                            }
                            self.songLabel.stringValue = String(format: "歌曲：%@ (%d/%d)", songFileName, self.songIndex, songs.count)
                            
                            if let songsJSONFile = programFolderUrl?.appendingPathComponent("songs.json") {
                                if !FileManager.default.fileExists(atPath: songsJSONFile.path) {
                                    let newSongs = songs
                                    let songsJSON = newSongs.toJSONString()
                                    try! songsJSON?.write(to: songsJSONFile, atomically: true, encoding: .utf8)
                                }
                            }
                            
                            if FileManager.default.fileExists(atPath: (songFileUrl?.path)!) {
                                print("已下载，跳过")
                                self.increaseIndexes()
                                self.download()
                            } else {
                                print("下载MP3：\(audioURL)")
                                Alamofire.download(audioURL, to: destination).response { response in
                                    if response.error == nil, let songPath = response.destinationURL?.path {
                                        print("Download mp3 success: \(songPath)")
                                    } else {
                                        print("Download mp3 failed: \(audioURL)")
                                    }
                                    
                                    self.increaseIndexes()
                                    self.download()
                                    
                                    }.downloadProgress(closure: { (progress) in
                                        print("progress: \(progress)")
                                        self.downloadProgress.doubleValue = progress.fractionCompleted
                                    })
                            }
                        }
                    }
                    
                    if let songs = self.currentSongs, songs.count > 0 {
                        processSongs(songs)
                    } else {
                        API.fetchSongs(programId: program.programId!, completion: { (songs) in
                            self.currentSongs = songs
                            processSongs(songs)
                        })
                    }
                    
                    
                }
                
                if let programs = self.currentPrograms, programs.count > 0 {
                    processPrograms(programs)
                } else {
                    API.fetchPrograms(channelId: channel.channelId!) { (programs) in
                        self.currentPrograms = programs
                        processPrograms(programs)
                    }
                }
            }
            
            if let channels = self.currentChannels, channels.count > 0 {
                processChannels(channels)
                
            } else {
                if let channels = radio.channels {
                    self.currentChannels = channels
                    processChannels(channels)
                }
            }
        }
    }
    
    
    
//    func logInfo(text: String) {
//        let attrString = logTextView.attributedString()
//        let logText = attrString.string
//        let mutableAttrString = NSMutableAttributedString(attributedString: attrString)
//        let newString = NSAttributedString(string: text)
//        mutableAttrString.append(newString)
//
//
//    }
    
    func increaseIndexes() {
        self.songIndex += 1
        if self.songIndex == self.currentSongs?.count {
            self.songIndex = 0
            self.programIndex += 1
            if self.programIndex == self.currentPrograms?.count {
                self.programIndex = 0
                self.channelIndex += 1
                if self.channelIndex == self.currentChannels?.count {
                    self.channelIndex = 0
                    self.radioIndex += 1
                    if self.radioIndex == self.allRadios?.count {
                        self.radioIndex = 0
                        print("Download finished.")
                    }
                }
            }
        }
        
        cacheIndexes(rIndex: radioIndex, cIndex: channelIndex, pIndex: programIndex, sIndex: songIndex)
    }
    
    func cacheIndexes(rIndex: Int, cIndex: Int, pIndex: Int, sIndex: Int) {
        let indexes = ["radio_index":rIndex,
                       "channel_index":cIndex,
                       "program_index":pIndex,
                       "song_index":sIndex,
                       ]
        let ud = UserDefaults.standard
        ud.set(indexes, forKey: "download_indexes")
        ud.synchronize()
    }
    
    func fetchIndexesCache() -> (Int, Int, Int, Int) {
        let ud = UserDefaults.standard
        if let indexCache = ud.object(forKey: "download_indexes") as? [String:Int] {
            let rIndex = indexCache["radio_index"]
            let cIndex = indexCache["channel_index"]
            let pIndex = indexCache["program_index"]
            let sIndex = indexCache["song_index"]
            return (rIndex!, cIndex!, pIndex!, sIndex!)
        }
        return (0,0,0,0)
    }
    
    func createFolder(_ folderName: String, baseUrl: URL) -> URL? {
        let manager = FileManager.default
        var isDir: ObjCBool = true
        guard manager.fileExists(atPath: baseUrl.path, isDirectory: &isDir) else {
            print("base url is not exists.")
            return nil
        }
        
        
        // 创建evo文件夹
        let folderUrl = baseUrl.appendingPathComponent(folderName, isDirectory: true)
        var isDirectory: ObjCBool = true
        if !manager.fileExists(atPath: folderUrl.path, isDirectory: &isDirectory) {
            try! manager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
            return folderUrl
        }
        
        return folderUrl
    }
    
    //根据文件名和路径创建文件
    func createFile(name:String, fileBaseUrl:URL){
        let manager = FileManager.default
        
        let file = fileBaseUrl.appendingPathComponent(name)
        print("文件: \(file)")
        let exist = manager.fileExists(atPath: file.path)
        if !exist {
            //在文件中随便写入一些内容
            let data = Data(base64Encoded:"aGVsbG8gd29ybGQ=" ,options:.ignoreUnknownCharacters)
            let createSuccess = manager.createFile(atPath: file.path,contents:data,attributes:nil)
            print("文件创建结果: \(createSuccess)")
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}







