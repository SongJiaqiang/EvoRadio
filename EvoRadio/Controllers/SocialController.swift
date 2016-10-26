//
//  SocialController.swift
//  EvoRadio
//
//  Created by Jarvis on 6/6/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import SnapKit

class SocialController: UIViewController {
    
    let socials = ["WechatSession",
                   "WechatTimeline",
                   "SinaWeibo",
                   "Facebook",
                   "Twitter",
                   "Tumblr"]
    
    var backgroundControl: UIButton!
    
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear

        prepareBackgroundControl()
        prepareIconSheetView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        backgroundControl.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {[weak self] in
            self?.backgroundControl.alpha = 1
        }) 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backgroundControl.alpha = 0
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    //MARK: prepare ui
    // Support WechatTimeline, WechatSession, QQ, SinaWeibo in china
    // Support Facebook, Twitter, Google+, Tumblr in foreign
    func prepareIconSheetView() {
        let iconHeight:CGFloat = Device.width() / 4
        
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.backgroundColor = UIColor.white
        contentView.snp.makeConstraints { (make) in
            make.height.equalTo(iconHeight)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.snp.bottom)
        }

        let snsButton0 = generateSnsButton("WechatSession", icon: UIImage(named:"UMS_wechat_session_icon")!, index: 0)
        contentView.addSubview(snsButton0)
        
        let snsButton1 = generateSnsButton("WechatTimeline", icon: UIImage(named:"UMS_wechat_timeline_icon")!, index: 1)
        contentView.addSubview(snsButton1)
        
        let snsButton2 = generateSnsButton("QQ", icon: UIImage(named:"UMS_qq_icon")!, index: 2)
        contentView.addSubview(snsButton2)
        
        let snsButton3 = generateSnsButton("SinaWeibo", icon: UIImage(named:"UMS_sina_icon")!, index: 3)
        contentView.addSubview(snsButton3)
        
        
        snsButton0.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: iconHeight, height: iconHeight))
            make.left.equalTo(contentView.snp.left)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        snsButton1.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: iconHeight, height: iconHeight))
            make.left.equalTo(snsButton0.snp.right)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        snsButton2.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: iconHeight, height: iconHeight))
            make.left.equalTo(snsButton1.snp.right)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        snsButton3.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: iconHeight, height: iconHeight))
            make.left.equalTo(snsButton2.snp.right)
            make.bottom.equalTo(contentView.snp.bottom)
        }
    }
    
    func generateSnsButton(_ title: String, icon: UIImage, index: Int) -> UIButton{
        let button = UIButton()
        button.setImage(icon, for: UIControlState())
        button.layer.borderColor = UIColor.grayColor8().cgColor
        button.layer.borderWidth = 0.5
        button.addTarget(self, action: #selector(SocialController.snsButtonPressed(_:)), for: .touchUpInside)
        button.tag = index
        
        return button
    }
    
    func prepareBackgroundControl() {
        backgroundControl = UIButton()
        view.addSubview(backgroundControl)
        backgroundControl.backgroundColor = UIColor(white: 0, alpha: 0.2)
        backgroundControl.alpha = 0
        backgroundControl.addTarget(self, action: #selector(SocialController.backgroundControlPressed(_:)), for: .touchUpInside)
        backgroundControl.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
    }
    
    
    //MARK: events
    func backgroundControlPressed(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func snsButtonPressed(_ button: UIButton) {
        
        switch button.tag {
        case 0:
            shareToWechat(WXSceneSession)
            break
        case 1:
            shareToWechat(WXSceneTimeline)
            break
        case 2:
            
            break
        case 3:
            shareToWeibo()
            break
        default: break
        }
    }
    
    func shareToWechat(_ scene: WXScene) {
        let message = WXMediaMessage()
        
        if shareAudio {
            message.title = music?.songName
            message.description = ((music?.artistsName!)! + " - ") + (music?.salbumsName)!
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
        WXApi.send(req)
    }
    
    func shareToWeibo() {
//        let message = WBMessageObject()
//        
//        if shareAudio {
//            let title =  music?.songName
//            let text = (((("推荐一首好听的歌：" + (music?.songName)!) + "\n") + (music?.artistsName)!) + " - ") + music!.salbumsName!
//            
//            let description = music?.songName?.appending("\n").appending((music?.artistsName)!).appending(" - ").appending((music?.salbumsName)!)
//            
//            let resizeImage = shareImage?.resizeImage(CGSize(width: 100, height: 100))
//            let compressedImage = resizeImage?.compressImageToLessThan(32)
//            message.text = text
//
//            let audioObject = WBMusicObject()
//            audioObject.objectID = title
//            audioObject.title = title
//            audioObject.description = description
//            audioObject.thumbnailData = UIImageJPEGRepresentation(compressedImage!, 0.9)
//            audioObject.musicUrl = music?.audioURL
//            audioObject.musicLowBandUrl = music?.audioURL
//            audioObject.musicStreamUrl = music?.audioURL
//            audioObject.musicLowBandStreamUrl = music?.audioURL
//            message.mediaObject = audioObject
//        }else {
//            message.text = shareText
//            
//            let imageObject = WBImageObject()
//            imageObject.imageData = UIImageJPEGRepresentation(shareImage!, 0.9)
//            message.imageObject = imageObject
//        }
//        
//        let request = WBSendMessageToWeiboRequest.request(withMessage: message)
//        WeiboSDK.send(request as! WBSendMessageToWeiboRequest)
    }
}
