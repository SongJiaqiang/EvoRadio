//
//  ViewController.swift
//  Evo
//
//  Created by Jarvis on 2019/3/6.
//  Copyright © 2019 SongJiaqiang. All rights reserved.
//

import Cocoa
import Alamofire

let JQHDURL = URL(fileURLWithPath: "/Volumes/JQHD/", isDirectory: true)
let baseURL = JQHDURL
let rootURL = baseURL.appendingPathComponent("evo")

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
    
    var downloadStatus: Int = -1
    var isCache: Bool = false
    
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
        
    }
    
    @IBAction func start(_ sender: NSButton) {
        downloadStatus = 1
        self.download()
    }
    
    @IBAction func pause(_ sender: NSButton) {
        downloadStatus = 0

        cacheIndexes(rIndex: radioIndex, cIndex: channelIndex, pIndex: programIndex, sIndex: songIndex)
    }
    
    @IBAction func stop(_ sender: NSButton) {
        downloadStatus = -1
        
        cacheIndexes(rIndex: radioIndex, cIndex: channelIndex, pIndex: programIndex, sIndex: songIndex)
    }
    
    
    func download() {
        if downloadStatus <= 0 {
            print("状态：\(downloadStatus == 0 ? "暂停" : "停止")")
            return
        }
        
        loadRadios {[weak self] (radios) in
            self?.allRadios = radios
            self?.processRadios(radios)
        }
    }
    
    func increaseIndexes() {
        guard let songs = currentSongs, let programs = currentPrograms, let channels = currentChannels, let radios = allRadios else {
            print("数据错误")
            return
        }
        
        self.songIndex += 1
        if self.songIndex >= songs.count {
            self.songIndex = 0
            self.programIndex += 1
            if self.programIndex >= programs.count {
                self.songIndex = 0
                self.programIndex = 0
                self.channelIndex += 1
                if self.channelIndex >= channels.count {
                    self.songIndex = 0
                    self.programIndex = 0
                    self.channelIndex = 0
                    self.radioIndex += 1
                    if self.radioIndex >= radios.count {
                        self.songIndex = 0
                        self.programIndex = 0
                        self.channelIndex = 0
                        self.radioIndex = 0
                        print("Download finished.")
                    }
                }
            }
        }
    }
    
    func cacheIndexes(rIndex: Int, cIndex: Int, pIndex: Int, sIndex: Int) {
        if isCache {
            return
        }
        
        isCache = true
        let indexes = ["radio_index":rIndex,
                       "channel_index":cIndex,
                       "program_index":pIndex,
                       "song_index":sIndex,
                       ]
        let ud = UserDefaults.standard
        ud.set(indexes, forKey: "download_indexes")
        ud.synchronize()
        isCache = false
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

extension ViewController {
    
    func processSongs(_ songs: [Song], program: Program, channel: Channel, radio: Radio) {
        let programFolderUrl = programFolderURL(program, channel: channel, radio: radio)
        
        let song = songs[self.songIndex]
        if let audioURL = song.audioURL {
            let songFileName = String(format: "%@_%@", song.songId!, song.songName!)
//            let songFileUrl = programFolderUrl?.appendingPathComponent(songFileName).appendingPathExtension("mp3")
            let songFileUrl = rootURL.appendingPathComponent("songs").appendingPathComponent(songFileName).appendingPathExtension("mp3")
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (songFileUrl, [.removePreviousFile, .createIntermediateDirectories])
            }
            DispatchQueue.main.async {
                self.songLabel.stringValue = String(format: "歌曲：%@ (%d/%d)", songFileName, self.songIndex, songs.count)
            }
            
            if FileManager.default.fileExists(atPath: songFileUrl.path) {
                print("已下载，跳过")
                self.increaseIndexes()
                self.download()
            } else {
                print("下载MP3：\(audioURL)")
                Alamofire.download(audioURL, to: destination).response {[weak self] response in
                    if response.error == nil, let songPath = response.destinationURL?.path {
                        print("Download mp3 success: \(songPath)")
                    } else {
                        print("Download mp3 failed: \(audioURL)")
                    }
                    
                    self?.increaseIndexes()
                    self?.download()
                    
                    }.downloadProgress(closure: {[weak self] (progress) in
                        print("progress: \(progress)")
                        DispatchQueue.main.async {
                            self?.downloadProgress.doubleValue = progress.fractionCompleted
                        }
                    })
            }
        }
    }
    
    func processPrograms(_ programs: [Program], channel: Channel, radio: Radio) {
        let channelFolderUrl = channelFolderURL(channel, radio: radio)
        
        if programIndex > programs.count {
            programIndex = 0
        }
        let program = programs[programIndex]
        let programFolderName = String(format: "%@_%@", program.programId!, program.programName!)
        self.createFolder(programFolderName, baseUrl: channelFolderUrl!)
        DispatchQueue.main.async {
            self.programLabel.stringValue = String(format: "节目：%@ (%d/%d)", programFolderName, self.programIndex, programs.count)
        }
        
        
        if let songs = self.currentSongs, songs.count > 0 {
            processSongs(songs, program: program, channel: channel, radio: radio)
        } else {
            loadSongs(program, channel: channel, radio: radio) {[weak self] (songs) in
                self?.currentSongs = songs
                self?.processSongs(songs, program: program, channel: channel, radio: radio)
            }
        }
        
    }
    
    func processChannels(_ channels: [Channel], radio: Radio) {
        let radioFolderUrl = radioFolderURL(radio)
        if channelIndex > channels.count {
            channelIndex = 0
        }
        let channel = channels[channelIndex]
        let channelFolderName = String(format: "%@_%@", channel.channelId!, channel.channelName!)
        createFolder(channelFolderName, baseUrl: radioFolderUrl!)
        DispatchQueue.main.async {
            self.channelLabel.stringValue = String(format: "频道：%@ (%d/%d)", channelFolderName, self.channelIndex, channels.count)
        }
        
        if let programs = currentPrograms, programs.count > 0 {
            processPrograms(programs, channel: channel, radio: radio)
        } else {
            loadPrograms(channel: channel, radio: radio) {[weak self] (programs) in
                self?.currentPrograms = programs
                self?.processPrograms(programs, channel: channel, radio: radio)
            }
        }
    }
    
    func processRadios(_ radios: [Radio]) {
        // 创建radio文件夹
        if radioIndex > radios.count {
            radioIndex = 0
        }
        let radio = radios[radioIndex]
        let radioFolderName = String(format: "%d_%@", radio.radioId!, radio.radioName!)
        let radioFolderUrl = radioFolderURL(radio)
        createFolder(radioFolderName, baseUrl: rootURL)
        DispatchQueue.main.async {
            self.radioLabel.stringValue = String(format: "电台：%@ (%d/%d)", radioFolderName, self.radioIndex, radios.count)
        }
        
        if let channels = currentChannels, channels.count > 0 {
            self.processChannels(channels, radio: radio)
        } else {
            self.loadChannels(radio: radio, completion: {[weak self] (channels) in
                self?.currentChannels = channels
                self?.processChannels(channels, radio: radio)
            })
        }
    }
    
}


extension ViewController {
    func loadRadios(_ completion: @escaping (([Radio]) -> Void)) {
        let radiosJSONFile = rootURL.appendingPathComponent("radios.json")
        if FileManager.default.fileExists(atPath: radiosJSONFile.path) {
            do {
                let jsonData = try Data(contentsOf: radiosJSONFile)
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonData
                    , options: .allowFragments) as? [[String : Any]] {
                    let radios = Array<Radio>(JSONArray: jsonObject)
                    completion(radios)
                }
            } catch let error {
                print("error: \(error)")
            }
            
        } else {
            API.fetchAllRadios { (radios) in
                let radiosJSON = radios.toJSONString()
                try! radiosJSON?.write(to: radiosJSONFile, atomically: true, encoding: .utf8)
                
                completion(radios)
            }
        }
    }
    
    func loadChannels(radio: Radio, completion: @escaping (([Channel]) -> Void)) {
        let radioFolderUrl = radioFolderURL(radio)
        if let channelsJSONFile = radioFolderUrl?.appendingPathComponent("channels.json") {
            if FileManager.default.fileExists(atPath: channelsJSONFile.path) {
                do {
                    let jsonData = try Data(contentsOf: channelsJSONFile)
                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData
                        , options: .allowFragments) as? [[String : Any]] {
                        let channels = Array<Channel>(JSONArray: jsonObject)
                        completion(channels)
                    }
                } catch let error {
                    print("error: \(error)")
                }
            } else {
                if let channels = radio.channels {
                    let channelsJSON = channels.toJSONString()
                    try! channelsJSON?.write(to: channelsJSONFile, atomically: true, encoding: .utf8)
                    
                    completion(channels)
                }
            }
        }
    }
    
    func loadPrograms(channel: Channel, radio: Radio, completion: @escaping (([Program]) -> Void)) {
        let channelFolderUrl = channelFolderURL(channel, radio: radio)
        
        if let programsJSONFile = channelFolderUrl?.appendingPathComponent("programs.json") {
            if FileManager.default.fileExists(atPath: programsJSONFile.path) {
                do {
                    let jsonData = try Data(contentsOf: programsJSONFile)
                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData
                        , options: .allowFragments) as? [[String : Any]] {
                        let programs = Array<Program>(JSONArray: jsonObject)
                        completion(programs)
                    }
                } catch let error {
                    print("error: \(error)")
                }
            } else {
                API.fetchPrograms(channelId: channel.channelId!) { (programs) in
                    let programsJSON = programs.toJSONString()
                    try! programsJSON?.write(to: programsJSONFile, atomically: true, encoding: .utf8)
                    
                    completion(programs)
                }
            }
        }
    }
    
    func loadSongs(_ program: Program, channel: Channel, radio: Radio, completion: @escaping (([Song]) -> Void)) {
        let programFolderUrl = programFolderURL(program, channel: channel, radio: radio)
        if let songsJSONFile = programFolderUrl?.appendingPathComponent("songs.json") {
            if FileManager.default.fileExists(atPath: songsJSONFile.path) {
                do {
                    let jsonData = try Data(contentsOf: songsJSONFile)
                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData
                        , options: .allowFragments) as? [[String : Any]] {
                        let songs = Array<Song>(JSONArray: jsonObject)
                        completion(songs)
                    }
                } catch let error {
                    print("error: \(error)")
                }
            } else {
                API.fetchSongs(programId: program.programId!) { (songs) in
                    let songsJSON = songs.toJSONString()
                    try! songsJSON?.write(to: songsJSONFile, atomically: true, encoding: .utf8)
                    
                    completion(songs)
                }
            }
        }
    }
}


extension ViewController {
    func radioFolderURL(_ radio: Radio) -> URL? {
        guard let rid = radio.radioId, let name = radio.radioName else {
            return nil
        }
        let id = String(format: "%d", rid)
        
        let folderName = String(format: "%@_%@", id, name)
        let folderURL = rootURL.appendingPathComponent(folderName)
        return folderURL
    }
    
    func channelFolderURL(_ channel: Channel, radio: Radio) -> URL? {
        guard let id = channel.channelId, let name = channel.channelName else {
            return nil
        }
        
        if let baseURL = radioFolderURL(radio) {
            let folderName = String(format: "%@_%@", id, name)
            let folderURL = baseURL.appendingPathComponent(folderName)
            return folderURL
        }
        return nil
    }
    
    func programFolderURL(_ program: Program, channel: Channel, radio: Radio) -> URL? {
        guard let id = program.programId, let name = program.programName else {
            return nil
        }
        
        if let baseURL = channelFolderURL(channel, radio: radio) {
            let folderName = String(format: "%@_%@", id, name)
            let folderURL = baseURL.appendingPathComponent(folderName)
            return folderURL
        }
        return nil
    }
    
    func songFileURL(_ song: Song, program: Program, channel: Channel, radio: Radio) -> URL? {
        guard let id = song.songId, let name = song.songName else {
            return nil
        }

        if let baseURL = programFolderURL(program, channel: channel, radio: radio) {
            let newName = name.replacingOccurrences(of: "/", with: "--")
            let folderName = String(format: "%@_%@", id, newName)
            let folderURL = baseURL.appendingPathComponent(folderName)
            return folderURL
        }
        return nil
    }
    
}





