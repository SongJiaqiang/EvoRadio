//
//  ViewController.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2019/2/28.
//  Copyright © 2019 JQTech. All rights reserved.
//

import Cocoa
import Alamofire
import Lava

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
        
        Lava.shared.fetchAllRadios({[weak self] (radios) in
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
            print("fetch all radios failed: \(String(describing: e))")
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
        let page = LRPage(index: 0)
        if let currentChannel = channelQueue.last, let channelId = currentChannel.channelId {
            channelIdText.stringValue = channelId
            Lava.shared.fetchPrograms(channelId, page: page, onSuccess: {[weak self] (programs) in
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
                print("fetch_programs error: \(String(describing: e))")
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
            programIdQueue.removeAll()
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
            Lava.shared.fetchSongs("\(programId)", onSuccess: {[weak self] (songs) in
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
                
            }) {[weak self] (e) in
                guard let wSelf = self else {return}
                
                print("fetch songs failed: \(String(describing: e))")
                wSelf.loadNextProgram()
            }
        }
        
    }
    
    func addSongsToQueue() {
        if programIdQueue.count == 0 {
            print("channel queue finished ")
            return
        }
        
        if let programId = programIdQueue.last {
            if programFilesDownloaded(id: String(format: "%d", programId)) {
                print("This program was downloaded, skip it")
                loadNextProgram()
                return;
            }
            self.programIdText.stringValue = "\(programId)"
            Lava.shared.fetchSongs("\(programId)", onSuccess: {[weak self] (songs) in
                guard let wSelf = self else {return}
                
                print("song count: \(songs.count)")
                if songs.count > 0 {
                    wSelf.downloadSongQueue.append(contentsOf: songs)
                    wSelf.downloadSong()
                }
                
            }) { (e) in
                print("fetch songs failed: \(String(describing: e))")
            }
        }
    }
    
    func downloadSong() {
        if downloadSongQueue.count == 0 {
            print("Load next program ")
            let progress = 1.0 - (Float(programIdQueue.count) / Float(programCount))
            loadSongProgress.stringValue = String(format: "%.2f %%", progress * 100)

            let programId = String(format: "%d", programIdQueue.last!)
            markProgramDownloadResult(true, id: programId)
            loadNextProgram()
            return
        }

        if let song = downloadSongQueue.last {
            
            if fileDownloaded(id: song.songId) {
                print("This file was downloaded, skip it.")
                downloadNextSong()
                return
            }
            
            if let url = song.audioURL, url.count > 0 {

                let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                    let supportDirectory = NSSearchPathForDirectoriesInDomains(
                        .applicationSupportDirectory, .userDomainMask, true
                    ).first!
                    
                    let rootDirector = supportDirectory + "/" + Bundle.main.bundleIdentifier!
                    let fileURL = URL(fileURLWithPath: rootDirector.appendingFormat("/%@.mp3", song.songId))
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                print("download song from url: \(url)")
                Alamofire.download(url, to: destination).response {[weak self] response in
                    guard let wSelf = self else {return}
                    
                    if response.error == nil, let rstFilePath = response.destinationURL?.path {
                        print("Download success: \(rstFilePath)")
                        wSelf.markDownloadResult(true, id: song.songId)
                    } else {
                        print("Download falied: \(song.songId!), \(song.programId!)")
                        wSelf.recordDownlaodFailedSong(Int64(song.songId!)!, programId: Int64(song.programId!)!)
                        wSelf.markDownloadResult(false, id: song.songId)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        wSelf.downloadNextSong()
                    }
                }
            } else {
                print("Audio url is empty, skip it.")
                self.markDownloadResult(false, id: song.songId)
                self.downloadSongQueue.removeLast()
                self.downloadSong()
            }
        }
    }
    
    func downloadNextSong() {
        if downloadSongQueue.count > 0 {
            downloadSongQueue.removeLast()
            downloadSong()
        } else {
            loadNextProgram()
        }
    }
    
    func loadNextProgram() {
        if programIdQueue.count > 0{
            programIdQueue.removeLast()
        }
        downloadSongQueue.removeAll()
        addSongsToQueue()
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
    
    func markProgramDownloadResult(_ result: Bool, id: String) {
        let ud = UserDefaults.standard
        ud.set(result, forKey: id)
        ud.synchronize()
    }
    
    func programFilesDownloaded(id: String) -> Bool {
        if let resultValue = UserDefaults.standard.value(forKey: id) as? Bool {
            return resultValue
        }
        return false
    }
    
    func recordDownlaodFailedSong(_ songId: Int64, programId: Int64) {
        let ud = UserDefaults.standard
        let key = String(format: "%d", songId)
        let value = String(format: "%d", programId)
        ud.set(value, forKey: key)
        ud.synchronize()
    }
    
    private func removeProgramCache(_ id: String) {
        UserDefaults.standard.removeObject(forKey: id)
        UserDefaults.standard.synchronize()
    }
}
