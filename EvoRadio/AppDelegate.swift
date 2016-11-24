//
//  AppDelegate.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/14.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit
import AVFoundation


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        prepareSocial()
        
        // 清除选择时刻缓存
        CoreDB.clearSelectedIndexes()
        
        // 设置音乐远程控制（在iPhone控制面板和锁屏界面操作）
        setupRemoteControl()
        
        // 设置根控制器
        setupRootControllerAndVisible()
        
        // 准备播放界面
        preparePlayer()
        
        return true
    }
    
    func setupRootControllerAndVisible() {
        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.clipsToBounds = true
//        window?.layer.cornerRadius = 10
        
        let controller = MainViewController()
        let homeNavC = NavigationController(rootViewController: controller)
        window?.rootViewController = homeNavC
        
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
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
//        WeiboSDK.handleOpen(url, delegate: nil)
        return WXApi.handleOpen(url, delegate: nil)
    }
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//
//        WeiboSDK.handleOpen(url, delegate: nil)
//        return WXApi.handleOpen(url, delegate: nil)
//    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
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

//    func prepareUMeng() {
//        let config = UMAnalyticsConfig.sharedInstance()
//        config?.appKey = UM_KEY
//        config?.channelId = ""
//        
//        // 上报App版本
//        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
//        MobClick.setAppVersion(version as! String)
//        
//        // 设置加密
//        MobClick.setEncryptEnabled(true)
//        
//        // 开始统计
//        MobClick.start(withConfigure: config)
//        
//    }
    
    func prepareSocial()  {
//        WXApi.registerApp(WECHAT_APP_ID)
        
//        WeiboSDK.enableDebugMode(true)
//        WeiboSDK.registerApp(WEIBO_APP_KEY)
    }
    
    

}

