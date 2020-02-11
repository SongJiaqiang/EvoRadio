//
//  ViewController.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2019/2/28.
//  Copyright © 2019 JQTech. All rights reserved.
//

import Cocoa
import Alamofire

class ViewController: NSViewController {

    @IBOutlet weak var channelIdText: NSTextField!
    @IBOutlet weak var programIdText: NSTextField!
    @IBOutlet weak var loadSongProgress: NSTextField!
    
    var allChannels: [LRChannel] = []
    var allPrograms: [LRProgram] = []
    
    var channelQueue: [LRChannel] = []
    
    var programIdQueue: [Int64] = []
    var programCount: Int = 0
    
    var downloadSongQueue: [LRSong] = []
    var downloadedCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func onLoadRadioAndChannels(_ sender: NSButton) {
        
        Lava.fetch_all_radios({[weak self] (radios) in
            guard let wSelf = self else {return}
            
            print("result \(radios.count)")
            if radios.count > 0 {
                _ = Database.shared.insertRadios(radios)
                wSelf.allChannels.removeAll()
                for radio in radios {
                    if let channels = radio.channels {
                        wSelf.allChannels.append(contentsOf: channels)
                    }
                }
                _ = Database.shared.insertChannels(wSelf.allChannels)
                
                wSelf.channelQueue.removeAll()
                wSelf.channelQueue.append(contentsOf: wSelf.allChannels)
            }

        }) { (e) in
            print("fetch all radios failed: \(e)")
        }
        
    }
    
    @IBAction func onLoadPrograms(_ sender: NSButton) {
        loadPrograms()
    }
    
    func loadPrograms() {
        scanChannel(from: 1, to: 1000)
        return
        if channelQueue.count == 0 {
            print("channel queue finished ")
            return
        }
        // 一次性加载500行，
        let page = LRPage(index: 0, size: 500)
        if let currentChannel = channelQueue.last, let channelId = currentChannel.channelId {
            channelIdText.stringValue = channelId
            Lava.fetch_programs(channelId, page: page, onSuccess: {[weak self] (programs) in
                guard let wSelf = self else {return}
                
                if programs.count > 0 {
                    wSelf.allPrograms.append(contentsOf: programs)
                    if !Database.shared.insertPrograms(programs) {
                        print("insert programs failed")
                        return
                    }
                }
                
                wSelf.channelQueue.removeLast()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    wSelf.loadPrograms()
                }
            }) { (e) in
                print("fetch_programs error: \(e)")
            }
            
        }
        
        
    }
    
    var channelId: Int = 0
    
    func scanChannel(from: Int, to: Int) {
        if from >= to {
            print("finished")
            return
        }
        loop(channelId: from)
        
    }
    
    func loop(channelId: Int) {
        
        let endpoint = "http://lavaradio.com/api/radio.listChannelPrograms.json?channel_id=\(channelId)&_pn=1&_sz=1"
        // 从网络加载
        Alamofire.request(endpoint).responseJSON { (response) in
            if response.result.isFailure {
                print("| id:\(channelId) | rst:fail  | count:\(0) |")
            } else {
                if let responseValue = response.value as? [String : Any] {
                     if let data = responseValue["data"] as? [String : Any] {
                         if let totle = data["total"] as? Int {
                            print("| id:\(channelId) | rst:ok    | count:\(totle) |")
                         }
                     } else {
                        print("| id:\(channelId) | rst:fatal | count:\(0) |")
                    }
                 }
            }
            
            self.channelId += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scanChannel(from: self.channelId, to: 1000)
            }
        }
    }
    
    @IBAction func onLoadSongs(_ sender: NSButton) {
        
        /*
         1. 从数据库加载program，获取program_id
         2. 调用接口获取歌曲列表、编辑者信息，
         */

        if let programIds = Database.shared.queryAllProgramIds() {
            programIdQueue.append(contentsOf: programIds)
            programCount = programIds.count
            
//            loadSongs()
            addSongsToQueue()
        }
    }
    
    func loadSongs() {
        if programIdQueue.count == 0 {
            print("channel queue finished ")
            return
        }

        if let programId = programIdQueue.last {
            self.programIdText.stringValue = "\(programId)"
            Lava.fetch_songs("\(programId)", onSuccess: {[weak self] (songs) in
                guard let wSelf = self else {return}
                
                print("song count: \(songs.count)")
                if songs.count > 0 {
                    if !Database.shared.insertSongs(songs) {
                        print("insert songs failed")
                        return
                    }
                }
                
                let progress = 1.0 - (Float(wSelf.programIdQueue.count) / Float(wSelf.programCount))
                wSelf.loadSongProgress.stringValue = String(format: "%.1f%", progress * 100)
                wSelf.programIdQueue.removeLast()
                wSelf.loadSongs()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    wSelf.loadSongs()
//                }
                
            }) { (e) in
                print("fetch songs failed: \(e)")
            }
        }
        
    }
    
    func addSongsToQueue() {
        if programIdQueue.count == 0 {
            print("channel queue finished ")
            return
        }
        
        if let programId = programIdQueue.last {
            self.programIdText.stringValue = "\(programId)"
            Lava.fetch_songs("\(programId)", onSuccess: {[weak self] (songs) in
                guard let wSelf = self else {return}
                
                print("song count: \(songs.count)")
                if songs.count > 0 {
                    wSelf.downloadSongQueue.append(contentsOf: songs)
                    wSelf.downloadSong()
                }
                
            }) { (e) in
                print("fetch songs failed: \(e)")
            }
        }
    }
    
    func downloadSong() {
        if downloadSongQueue.count == 0 {
            print("Load next program ")
            let progress = 1.0 - (Float(programIdQueue.count) / Float(programCount))
            loadSongProgress.stringValue = String(format: "%.1f%", progress * 100)
            programIdQueue.removeLast()
            addSongsToQueue()
            return
        }

        if let song = downloadSongQueue.last,
            let url = song.audioURL,
            url.count > 0 {
            
            if fileDownloaded(id: song.songId) {
                print("This file was downloaded, skip it.")
                self.downloadSongQueue.removeLast()
                self.downloadSong()
                return
            }
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let supportDirectory = NSSearchPathForDirectoriesInDomains(
                    .applicationSupportDirectory, .userDomainMask, true
                ).first!
                
                let rootDirector = supportDirectory + "/" + Bundle.main.bundleIdentifier!
                let fileURL = URL(fileURLWithPath: rootDirector.appendingFormat("/%@.mp3", song.songId))
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download(url, to: destination).response {[weak self] response in
                guard let wSelf = self else {return}
                
                if response.error == nil, let rstFilePath = response.destinationURL?.path {
                    print("Download success: \(rstFilePath)")
                    wSelf.markDownloadResult(true, id: song.songId)
                } else {
                    wSelf.markDownloadResult(false, id: song.songId)
                }
                wSelf.downloadSongQueue.removeLast()
                wSelf.downloadSong()
            }
        }
    }
    
    func markDownloadResult(_ result: Bool, id: String) {
        let ud = UserDefaults.standard
        ud.set(result, forKey: id)
        ud.synchronize()
    }
    
    func fileDownloaded(id: String) -> Bool {
        if let resultValue = UserDefaults.standard.value(forKey: id) as? Bool {
            return resultValue
        }
        return false
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}
