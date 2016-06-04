//
//  AppDelegate.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/14.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        prepareUMeng()
        
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
        
        let controller = MainViewController()
        let homeNavC = NavigationController(rootViewController: controller)
        window?.rootViewController = homeNavC
        window?.makeKeyAndVisible()
    }
    
    func preparePlayer() {
        PlayerView.instance.prepare()
        PlayerViewController.playerController.prepare()
        
        MusicManager.sharedManager.loadLastPlaylist()
    }
    
    func setupRemoteControl() {
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
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if let e = event {
            if e.type == .RemoteControl {
                switch e.subtype {
                case .RemoteControlPause:
                    print("RemoteControlPause")
                    MusicManager.sharedManager.pauseItem()
                    break;
                case .RemoteControlStop:
                    print("RemoteControlPause")
                    break;
                case .RemoteControlPlay:
                    print("RemoteControlPlay")
                    MusicManager.sharedManager.playItem()
                    break;
                case .RemoteControlTogglePlayPause:
                    print("RemoteControlTogglePlayPause")
                    break;
                case .RemoteControlNextTrack:
                    print("RemoteControlNextTrack")
                    MusicManager.sharedManager.playNext()
                    break;
                case .RemoteControlPreviousTrack:
                    print("RemoteControlPreviousTrack")
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

}

