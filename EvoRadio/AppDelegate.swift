//
//  AppDelegate.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/14.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import AVFoundation
import FLEX

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // 清除选择时刻缓存
        CoreDB.clearSelectedIndexes()
        
        // 设置音乐远程控制（在iPhone控制面板和锁屏界面操作）
        setupRemoteControl()
        
        // 设置根控制器
        setupRootControllerAndVisible()
        
        // 准备播放界面
        preparePlayer()
        
        // 配置flex工具
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap.numberOfTouchesRequired = 2
        self.window?.addGestureRecognizer(tap)
        
        return true
    }
    
    func doubleTap() {
        FLEXManager.shared().showExplorer()
    }
    
    func setupRootControllerAndVisible() {
        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.clipsToBounds = true
//        window?.layer.cornerRadius = 10
        
        let rootVC = MainViewController()
        let navVC = NavigationController(rootViewController: rootVC)
        window?.rootViewController = navVC
        
//        let c = StreamingKitViewController()
//        window?.rootViewController = c
        
        window?.makeKeyAndVisible()
    }
    
    func preparePlayer() {
        PlayerView.main.prepareUI()
        PlayerViewController.mainController.prepare()
        
        MusicManager.shared.loadLastPlaylist()
    }
    
    func setupRemoteControl() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            debugPrint("set category error: \(error)")
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        becomeFirstResponder()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // 保存播放列表
        MusicManager.shared.saveLastPlaylist()
//        DownloadingSongListViewController.mainController.saveDownloadingList()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    
    /// 远程控制。耳机、蓝牙
    ///
    /// - Parameter event: 触发事件
    override func remoteControlReceived(with event: UIEvent?) {
        if let e = event {
            if e.type == .remoteControl {
                switch e.subtype {
                case .remoteControlPause:
                    debugPrint("RemoteControlPause")
                    MusicManager.shared.pause()
                    break;
                case .remoteControlStop:
                    debugPrint("RemoteControlPause")
                    break;
                case .remoteControlPlay:
                    debugPrint("RemoteControlPlay")
                    MusicManager.shared.play()
                    break;
                case .remoteControlTogglePlayPause:
                    debugPrint("RemoteControlTogglePlayPause")
                    break;
                case .remoteControlNextTrack:
                    debugPrint("RemoteControlNextTrack")
                    MusicManager.shared.playNext()
                    break;
                case .remoteControlPreviousTrack:
                    debugPrint("RemoteControlPreviousTrack")
                    MusicManager.shared.playPrev()
                    break;
                default:
                    break;
                }
            }
        }
    }

}

