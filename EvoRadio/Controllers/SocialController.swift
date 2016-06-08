//
//  SocialController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 6/6/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import SnapKit

class SocialController: UIViewController {
    
    let socials = ["WechatSession",
                   "WechatTimeline",
                   "QQ",
                   "SinaWeibo",
                   "Facebook",
                   "Twitter",
                   "Google+",
                   "Tumblr"]
    
    var shareTitle: String?
    var shareText: String?
    var shareImage: UIImage?
    var shareUrl: String?
    var music: Song?
    var shareAudio: Bool = true
    
    var successedClosure: (() -> Void)?
    var failedClosure: ((NSError) -> Void)?
    var cancelClosure: (() -> Void)?
    
    //MARK: Life cycle
    convenience init(music: Song, shareImage: UIImage, shareText: String) {
        self.init()
        
        self.music = music
        self.shareImage = shareImage
        self.shareText = shareText
    }
    
    convenience init(shareTitle: String, shareText: String, shareImage: UIImage, shareUrl: String) {
        
        self.init()
        
        self.shareTitle = shareTitle
        self.shareText = shareText
        self.shareImage = shareImage
        self.shareUrl = shareUrl
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.modalPresentationStyle = .OverCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()

        let emptyButton = UIButton()
        view.addSubview(emptyButton)
        emptyButton.backgroundColor = UIColor(white: 0, alpha: 0.2)
        emptyButton.addTarget(self, action: #selector(SocialController.emptyButtonPressed(_:)), forControlEvents: .TouchUpInside)
        emptyButton.snp_makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        prepareIconSheetView()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    //MARK: prepare ui
    // Support WechatTimeline, WechatSession, QQ, SinaWeibo in china
    // Support Facebook, Twitter, Google+, Tumblr in foreign
    func prepareIconSheetView() {
        let iconHeight:CGFloat = Device.width() / 4
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.snp_makeConstraints { (make) in
            make.height.equalTo(iconHeight)
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(view.snp_bottom)
        }

        let snsButton0 = generateSnsButton("WechatSession", icon: UIImage(named:"UMS_wechat_session_icon")!, index: 0)
        contentView.addSubview(snsButton0)
        
        let snsButton1 = generateSnsButton("WechatTimeline", icon: UIImage(named:"UMS_wechat_timeline_icon")!, index: 1)
        contentView.addSubview(snsButton1)
        
        let snsButton2 = generateSnsButton("QQ", icon: UIImage(named:"UMS_qq_icon")!, index: 2)
        contentView.addSubview(snsButton2)
        
        let snsButton3 = generateSnsButton("SinaWeibo", icon: UIImage(named:"UMS_sina_icon")!, index: 3)
        contentView.addSubview(snsButton3)
        
        
        snsButton0.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(iconHeight, iconHeight))
            make.left.equalTo(contentView.snp_left)
            make.bottom.equalTo(contentView.snp_bottom)
        }
        
        snsButton1.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(iconHeight, iconHeight))
            make.left.equalTo(snsButton0.snp_right)
            make.bottom.equalTo(contentView.snp_bottom)
        }
        
        snsButton2.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(iconHeight, iconHeight))
            make.left.equalTo(snsButton1.snp_right)
            make.bottom.equalTo(contentView.snp_bottom)
        }
        
        snsButton3.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(iconHeight, iconHeight))
            make.left.equalTo(snsButton2.snp_right)
            make.bottom.equalTo(contentView.snp_bottom)
        }
    }
    
    func generateSnsButton(title: String, icon: UIImage, index: Int) -> UIButton{
        let button = UIButton()
        button.setImage(icon, forState: .Normal)
        button.layer.borderColor = UIColor.grayColor8().CGColor
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(SocialController.snsButtonPressed(_:)), forControlEvents: .TouchUpInside)
        button.tag = index
        
        return button
    }
    
    
    //MARK: events
    func emptyButtonPressed(button: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func snsButtonPressed(button: UIButton) {
        
        switch button.tag {
        case 0:
            shareToWechat(WXSceneSession)
            break
        case 1:
            shareToWechat(WXSceneTimeline)
            break
        case 2:
            shareToQZone()
            break
        case 3:
            shareToWeibo()
            break
        default: break
        }
    }
    
    func shareToWechat(scene: WXScene) {
        let message = WXMediaMessage()
        
        if shareAudio {
            message.title = music?.songName
            message.description = music?.artistsName!.stringByAppendingString(" - ").stringByAppendingString((music?.salbumsName)!)
            message.setThumbImage(shareImage)
            
            let musicObject = WXMusicObject()
            musicObject.musicUrl = DOMAIN
            musicObject.musicDataUrl = music?.audioURL
            musicObject.musicLowBandUrl = musicObject.musicUrl
            message.mediaObject = musicObject
        }else {
            message.title = shareTitle
            message.description = shareText
            message.setThumbImage(shareImage)
            
            let imageObject = WXImageObject()
            imageObject.imageData = UIImageJPEGRepresentation(shareImage!, 0.9)
            message.mediaObject = imageObject
        }
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        WXApi.sendReq(req)
    }
    
    func shareToQZone() {
        
        if shareAudio {
            let title = music?.songName
            let description = music?.artistsName!.stringByAppendingString(" - ").stringByAppendingString((music?.salbumsName)!)
            let previewImageUrl = NSURL(string: (music?.picURL)!)
            let audioUrl = NSURL(string:  (music?.audioURL)!)

            let audioObject = QQApiAudioObject.objectWithURL(audioUrl, title: title, description: description, previewImageURL: previewImageUrl)
            let req = SendMessageToQQReq(content: audioObject as! QQApiAudioObject)
            QQApiInterface.sendReq(req)
        }else {
            let imageData = UIImageJPEGRepresentation(shareImage!, 0.9)
            let previewData = UIImageJPEGRepresentation(shareImage!, 0.5)
            let imageObject = QQApiImageObject.objectWithData(imageData, previewImageData: previewData, title: title, description: description)
            let req = SendMessageToQQReq(content: imageObject as! QQApiImageObject)
            QQApiInterface.sendReq(req)
        }
        
        
    }
    
    func shareToWeibo() {
        let message = WBMessageObject()
        
        if shareAudio {
            let title =  music?.songName
            let text = "推荐一首好听的歌：".stringByAppendingString((music?.songName)!).stringByAppendingString("\n").stringByAppendingString((music?.artistsName)!).stringByAppendingString(" - ").stringByAppendingString(music!.salbumsName!)
            let description = music?.songName!.stringByAppendingString("\n").stringByAppendingString((music?.artistsName)!).stringByAppendingString("\n").stringByAppendingString(music!.salbumsName!)
            let resizeImage = shareImage?.resizeImage(CGSizeMake(100, 100))
            let compressedImage = resizeImage?.compressImageToLessThan(32)
            message.text = text

            let audioObject = WBMusicObject()
            audioObject.objectID = title
            audioObject.title = title
            audioObject.description = description
            audioObject.thumbnailData = UIImageJPEGRepresentation(compressedImage!, 0.9)
            audioObject.musicUrl = music?.audioURL
            audioObject.musicLowBandUrl = music?.audioURL
            audioObject.musicStreamUrl = music?.audioURL
            audioObject.musicLowBandStreamUrl = music?.audioURL
            message.mediaObject = audioObject
        }else {
            message.text = shareText
            
            let imageObject = WBImageObject()
            imageObject.imageData = UIImageJPEGRepresentation(shareImage!, 0.9)
            message.imageObject = imageObject
        }
        
        let request = WBSendMessageToWeiboRequest.requestWithMessage(message)
        WeiboSDK.sendRequest(request as! WBSendMessageToWeiboRequest)
    }
}
