//
//  URLs.swift
//  Evo
//
//  Created by Jarvis on 2019/3/16.
//  Copyright © 2019 SongJiaqiang. All rights reserved.
//

import Foundation

extension URL {
    func createFolder() {
        let manager = FileManager.default
        var isDir: ObjCBool = true
        if manager.fileExists(atPath: self.path, isDirectory: &isDir) {
            print("Folder url is exists.")
            return
        }
        
        if !manager.fileExists(atPath: self.path, isDirectory: &isDir) {
            do {
                try manager.createDirectory(at: self, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
    }
    
    static func createFolder(_ folderName: String, baseUrl: URL) -> URL? {
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
}
