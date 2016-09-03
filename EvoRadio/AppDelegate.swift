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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        prepareUMeng()
        prepareSocial()
        
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
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
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
        PlayerView.instance.prepare()
        PlayerViewController.playerController.prepare()
        
        MusicManager.sharedManager.loadLastPlaylist()
    }
    
    func setupRemoteControl() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            debugPrint("set category error: \(error)")
        }
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        becomeFirstResponder()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // 保存播放列表
        MusicManager.sharedManager.saveLastPlaylist()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        WeiboSDK.handleOpenURL(url, delegate: nil)
        return WXApi.handleOpenURL(url, delegate: nil)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        WeiboSDK.handleOpenURL(url, delegate: nil)
        return WXApi.handleOpenURL(url, delegate: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if let e = event {
            if e.type == .RemoteControl {
                switch e.subtype {
                case .RemoteControlPause:
                    debugPrint("RemoteControlPause")
                    MusicManager.sharedManager.pause()
                    break;
                case .RemoteControlStop:
                    debugPrint("RemoteControlPause")
                    break;
                case .RemoteControlPlay:
                    debugPrint("RemoteControlPlay")
                    MusicManager.sharedManager.play()
                    break;
                case .RemoteControlTogglePlayPause:
                    debugPrint("RemoteControlTogglePlayPause")
                    break;
                case .RemoteControlNextTrack:
                    debugPrint("RemoteControlNextTrack")
                    MusicManager.sharedManager.playNext()
                    break;
                case .RemoteControlPreviousTrack:
                    debugPrint("RemoteControlPreviousTrack")
                    MusicManager.sharedManager.playPrev()
                    break;
                default:
                    break;
                }
            }
        }
    }

    func prepareUMeng() {
        let config = UMAnalyticsConfig.sharedInstance()
        config.appKey = UM_KEY
        config.channelId = ""
        
        // 上报App版本
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        MobClick.setAppVersion(version as! String)
        
        // 设置加密
        MobClick.setEncryptEnabled(true)
        
        // 开始统计
        MobClick.startWithConfigure(config)
        
    }
    
    func prepareSocial()  {
        WXApi.registerApp(WECHAT_APP_ID)
        
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(WEIBO_APP_KEY)
    }
    
    

}

