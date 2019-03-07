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
            let evoUrl = createFolder("evo", baseUrl: desktopDirectory)
            
            // 创建radio文件夹
            let radio = radios[radioIndex]
            let radioFolderName = String(format: "%d_%@", radio.radioId!, radio.radioName!)
            let radioFolderUrl = self.createFolder(radioFolderName, baseUrl: evoUrl!)
            
            let currentChannels = radio.channels
            if let channels = currentChannels {
                let channel = channels[channelIndex]
                let channelFolderName = String(format: "%@_%@", channel.channelId!, channel.channelName!)
                let channelFolderUrl = self.createFolder(channelFolderName, baseUrl: radioFolderUrl!)
                
                API.fetchPrograms(channelId: channel.channelId!) { (programs) in
                    self.currentPrograms = programs
                    let program = programs[self.programIndex]
                    let programFolderName = String(format: "%@_%@", program.programId!, program.programName!)
                    let programFolderUrl = self.createFolder(programFolderName, baseUrl: channelFolderUrl!)
                    
                    API.fetchSongs(programId: program.programId!, completion: { (songs) in
                        self.currentSongs = songs
                        let song = songs[self.songIndex]
                        if let audioUrl = song.audioUrl {
                            let songFileName = String(format: "%@_%@", song.songId!, song.songName!)
                            let songFileUrl = programFolderUrl?.appendingPathComponent(songFileName).appendingPathExtension("mp3")
                            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                                return (songFileUrl!, [.removePreviousFile, .createIntermediateDirectories])
                            }
                            Alamofire.download(audioUrl, to: destination).response { response in
//                                print(response)
                                
                                if response.error == nil, let songPath = response.destinationURL?.path {
                                    print("Download mp3 success: \(songPath)")
                                    
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
                                                if self.radioIndex == radios.count {
                                                    self.radioIndex = 0
                                                    print("Download finished.")
                                                }
                                            }
                                        }
                                    }
                                    self.download()
                                }
                                }.downloadProgress(closure: { (progress) in
                                    print("progress: \(progress)")
                                })
                            
                        }
                        
                        
                    })
                }
            }
        }
        
        
        
        
//
//
//        let url = urlForDocument[0]
//        createFile(name:"test.txt", fileBaseUrl: url)
        
        
        
    }
    
    func createFolder(_ folderName: String, baseUrl: URL) -> URL? {
        let manager = FileManager.default
        
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

class API {
    
    /// 
    /// https://www.lavaradio.com/api/radio.listAllChannels.json
    class func fetchAllRadios(completion: @escaping (([Radio]) -> Void)) {
        let url = "https://www.lavaradio.com/api/radio.listAllChannels.json"
        print("Request url: \(url)")
        Alamofire.request(url).responseJSON { (rsp) in
//            print("rsp => \(rsp)")
            if rsp.result.isSuccess {
                if let jsonValue = rsp.result.value as? [String: Any] {
                    if let data = jsonValue["data"] as? [[String: Any]] {
                        let radios = Radio.radios(data: data)
                        completion(radios)
                    }
                }
            }
        }
    }
    
    /// https://www.lavaradio.com/api/radio.listAllChannels.json
    class func fetchAllChannels(radioId: Int) {
        let url = "https://www.lavaradio.com/api/radio.listAllChannels.json"
        print("Request url: \(url)")
        Alamofire.request(url).responseJSON { (rsp) in
//            print("rsp => \(rsp)")
        }
    }
    
    /// https://www.lavaradio.com/api/radio.listChannelPrograms.json?channel_id=5&_pn=0&_sz=2
    class func fetchPrograms(channelId: String, pageSize: Int=300, pageNum: Int=0, completion: @escaping (([Program]) -> Void)) {
        let url = String(format: "https://www.lavaradio.com/api/radio.listChannelPrograms.json?channel_id=%@&_sz=%d&_pn=%d", channelId, pageSize, pageNum)
        print("Request url: \(url)")
        
        Alamofire.request(url).responseJSON { (rsp) in
//            print("rsp => \(rsp)")
            
            if rsp.result.isSuccess {
                if let jsonValue = rsp.result.value as? [String: Any] {
                    if let data = jsonValue["data"] as? [String: Any], let lists = data["lists"] as? [[String: Any]] {
                        let programs = Program.programs(data: lists)
                        completion(programs)
                    }
                }
            }
        }
    }
    
    /// https://www.lavaradio.com/api/play.playProgram.json?program_id=6938
    class func fetchSongs(programId: String, completion: @escaping (([Song]) -> Void)) {
        let url = String(format: "https://www.lavaradio.com/api/play.playProgram.json?program_id=%@", programId)
        print("Request url: \(url)")
        Alamofire.request(url).responseJSON { (rsp) in
//            print("rsp => \(rsp)")
            
            if rsp.result.isSuccess {
                if let jsonValue = rsp.result.value as? [String: Any] {
                    if let data = jsonValue["data"] as? [String: Any], let lists = data["songs"] as? [[String: Any]] {
                        let songs = Song.songs(data: lists)
                        completion(songs)
                    }
                }
            }
        }
    }
}


class Radio {
    var radioId: Int?
    var radioName: String?
    var channels: [Channel]?
    
    init(id: Int, name: String) {
        self.radioId = id
        self.radioName = name
    }
    
    class func radios(data: [[String:Any]]) -> [Radio] {
        return data.map { (d) -> Radio in
            if let id = d["radio_id"] as? Int, let name = d["radio_name"] as? String {
                let radio = Radio(id: id, name: name)
                if let channelsData = d["channels"] as? [[String:Any]] {
                    radio.channels = Channel.channels(data: channelsData)
                }
                return radio
            }
            return Radio(id: 0, name: "unknown")
        }
    }
}


class Channel {
    var channelId: String?
    var channelName: String?
    
    init(id: String, name: String) {
        self.channelId = id
        self.channelName = name
    }
    
    
    class func channels(data: [[String:Any]]) -> [Channel] {
        return data.map { (d) -> Channel in
            if let id = d["channel_id"] as? String, let name = d["channel_name"] as? String {
                return Channel(id: id, name: name)
            }
            return Channel(id: "0", name: "unknown")
        }
    }
}

class Program {
    var programId: String?
    var programName: String?
    
    init(id: String, name: String) {
        self.programId = id
        self.programName = name
    }
    
    
    class func programs(data: [[String:Any]]) -> [Program] {
        return data.map { (d) -> Program in
            if let id = d["program_id"] as? String, let name = d["program_name"] as? String {
                return Program(id: id, name: name)
            }
            return Program(id: "0", name: "unknown")
        }
    }
}

class Song {
    var songId: String?
    var songName: String?
    var audioUrl: String?
    
    init(id: String, name: String) {
        self.songId = id
        self.songName = name
    }
    
    
    class func songs(data: [[String:Any]]) -> [Song] {
        return data.map { (d) -> Song in
            if let id = d["song_id"] as? String, let name = d["song_name"] as? String {
                let song = Song(id: id, name: name)
                song.audioUrl = d["audio_url"] as? String
                return song
            }
            return Song(id: "0", name: "unknown")
        }
    }
}
