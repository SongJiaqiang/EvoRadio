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
    
    var allRadios = [Radio]()
    var currentChannels = [Channel]()
    var currentPrograms = [Program]()
    var currentSongs = [Song]()
    
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
            self?.allRadios.removeAll()
            self?.allRadios.append(contentsOf: radios)
            self?.processRadios(radios)
        }
    }
    
    func increaseIndexes() {
        songIndex += 1
        if songIndex >= currentSongs.count {
            programIndex += 1
            currentSongs.removeAll()
            songIndex = 0
            if programIndex >= currentPrograms.count {
                channelIndex += 1
                programIndex = 0
                songIndex = 0
                currentPrograms.removeAll()
                currentSongs.removeAll()
                if channelIndex >= currentChannels.count {
                    radioIndex += 1
                    channelIndex = 0
                    programIndex = 0
                    songIndex = 0
                    currentChannels.removeAll()
                    currentPrograms.removeAll()
                    currentSongs.removeAll()
                    if self.radioIndex >= allRadios.count {
                        print("Download finished.")
                    }
                }
            }
        }
        
        cacheIndexes(rIndex: radioIndex, cIndex: channelIndex, pIndex: programIndex, sIndex: radioIndex)
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
        
        let song = songs[self.songIndex]
        if let audioURL = song.audioURL {
            let songFileName = String(format: "%@_%@", song.songId!, song.songName!)
            let songFileUrl = songFileURL(song, program: program, channel: channel, radio: radio)
//            let songFileUrl = rootURL.appendingPathComponent("songs").appendingPathComponent(songFileName).appendingPathExtension("mp3")
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (songFileUrl!, [.removePreviousFile, .createIntermediateDirectories])
            }
            print("Song file name: \(songFileName)")
            DispatchQueue.main.async {
                self.songLabel.stringValue = String(format: "歌曲：%@ (%d/%d)", songFileName, self.songIndex, songs.count)
            }
            
            print("不下载，跳过")
            self.increaseIndexes()
            self.download()
            
//            if FileManager.default.fileExists(atPath: songFileUrl!.path) {
//                print("已下载，跳过")
//                self.increaseIndexes()
//                self.download()
//            } else {
//                print("下载MP3：\(audioURL)")
//                Alamofire.download(audioURL, to: destination).response {[weak self] response in
//                    if response.error == nil, let songPath = response.destinationURL?.path {
//                        print("Download mp3 success: \(songPath)")
//                    } else {
//                        print("Download mp3 failed: \(audioURL)")
//                    }
//
//                    self?.increaseIndexes()
//                    self?.download()
//
//                    }.downloadProgress(closure: {[weak self] (progress) in
//                        print("progress: \(progress)")
//                        DispatchQueue.main.async {
//                            self?.downloadProgress.doubleValue = progress.fractionCompleted
//                        }
//                    })
//            }
        }
    }
    
    func processPrograms(_ programs: [Program], channel: Channel, radio: Radio) {
        let channelFolderUrl = channelFolderURL(channel, radio: radio)
        let program = programs[programIndex]
        let programFolderName = String(format: "%@_%@", program.programId!, program.programName!)
        let _ = createFolder(programFolderName, baseUrl: channelFolderUrl!)
        print("Program folder name: \(programFolderName)")
        DispatchQueue.main.async {
            self.programLabel.stringValue = String(format: "节目：%@ (%d/%d)", programFolderName, self.programIndex, programs.count)
        }
        
        if currentSongs.count > 0 {
            processSongs(currentSongs, program: program, channel: channel, radio: radio)
        } else {
            loadSongs(program, channel: channel, radio: radio) {[weak self] (songs) in
                self?.currentSongs.removeAll()
                self?.currentSongs.append(contentsOf: songs)
                self?.processSongs(songs, program: program, channel: channel, radio: radio)
            }
        }
        
    }
    
    func processChannels(_ channels: [Channel], radio: Radio) {
        let radioFolderUrl = radioFolderURL(radio)
        let channel = channels[channelIndex]
        let channelFolderName = String(format: "%@_%@", channel.channelId!, channel.channelName!)
        let _ = createFolder(channelFolderName, baseUrl: radioFolderUrl!)
        print("Channel folder name: \(channelFolderName)")
        DispatchQueue.main.async {
            self.channelLabel.stringValue = String(format: "频道：%@ (%d/%d)", channelFolderName, self.channelIndex, channels.count)
        }
        
        if currentPrograms.count > 0 {
            processPrograms(currentPrograms, channel: channel, radio: radio)
        } else {
            loadPrograms(channel: channel, radio: radio) {[weak self] (programs) in
                self?.currentPrograms.removeAll()
                self?.currentPrograms.append(contentsOf: programs)
                self?.processPrograms(programs, channel: channel, radio: radio)
            }
        }
    }
    
    func processRadios(_ radios: [Radio]) {
        print("Process radio at index: \(radioIndex)")
        let radio = radios[radioIndex]
        let radioFolderName = String(format: "%d_%@", radio.radioId!, radio.radioName!)
        let _ = radioFolderURL(radio)
        let _ = createFolder(radioFolderName, baseUrl: rootURL)
        print("Radio folder name: \(radioFolderName)")
        DispatchQueue.main.async {
            self.radioLabel.stringValue = String(format: "电台：%@ (%d/%d)", radioFolderName, self.radioIndex, radios.count)
        }
        
        if currentChannels.count > 0 {
            self.processChannels(currentChannels, radio: radio)
        } else {
            self.loadChannels(radio: radio, completion: {[weak self] (channels) in
                self?.currentChannels.removeAll()
                self?.currentChannels.append(contentsOf: channels)
                self?.processChannels(channels, radio: radio)
            })
        }
    }
    
}


extension ViewController {
    func loadRadios(_ completion: @escaping (([Radio]) -> Void)) {
        print("Load radios")
        let radiosJSONFile = rootURL.appendingPathComponent("radios.json")
        if FileManager.default.fileExists(atPath: radiosJSONFile.path) {
            print("Load radios from json")
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
                print("Load radios from api")
                let radiosJSON = radios.toJSONString()
                try! radiosJSON?.write(to: radiosJSONFile, atomically: true, encoding: .utf8)
                
                completion(radios)
            }
        }
    }
    
    func loadChannels(radio: Radio, completion: @escaping (([Channel]) -> Void)) {
        print("Load channels with radio: \(radio.radioId),\(radio.radioName)")
        let radioFolderUrl = radioFolderURL(radio)
        if let channelsJSONFile = radioFolderUrl?.appendingPathComponent("channels.json") {
            if FileManager.default.fileExists(atPath: channelsJSONFile.path) {
                print("Load radios from json")
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
                    print("Load radios from radio.channels")
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

//        if let baseURL = programFolderURL(program, channel: channel, radio: radio) {
            let songsFolderURL = rootURL.appendingPathComponent("songs")
            let newName = name.replacingOccurrences(of: "/", with: "--")
            let fileName = String(format: "%@_%@.mp3", id, newName)
            let fileURL = songsFolderURL.appendingPathComponent(fileName)
            return fileURL
//        }
//        return nil
    }
    
}





