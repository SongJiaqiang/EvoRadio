//
//  SplashViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 2018/8/9.
//  Copyright © 2018 JQTech. All rights reserved.
//

import UIKit

class SplashViewController: ViewController {

    
    @IBOutlet weak var splashImageView: UIImageView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // 监听点击背景
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tap)
        
        // 监听键盘
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardFrameChanged(_:)), name: .UIKeyboardWillChangeFrame, object: nil)

    }
    
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        let ud = UserDefaults.standard
        ud.set(1, forKey: "kEnterInvitationCode")
        ud.synchronize()
        
        let rootVC = MainViewController()
        let navVC = NavigationController(rootViewController: rootVC)
        
        UIApplication.shared.keyWindow?.rootViewController = navVC
        
        preparePlayer()
    }
    
    @objc func onTap(_ gesture: UIGestureRecognizer) {
        
        codeTextField.endEditing(true)
        
    }
    
    @objc func onKeyboardFrameChanged(_ notification: Notification) {
        let info = notification.userInfo
        let kbRect = (info?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (info?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        let offsetY = kbRect.origin.y - UIScreen.main.bounds.height

        print(">> offsetY:\(offsetY), duration:\(duration)")
        UIView.animate(withDuration: duration) {
            self.codeTextField.transform = CGAffineTransform(translationX: 0, y: offsetY)
            self.enterButton.transform = CGAffineTransform(translationX: 0, y: offsetY)   
        }
    }
    
    func preparePlayer() {
        PlayerView.main.prepareUI()
        PlayerViewController.mainController.prepare()
        
        MusicManager.shared.loadLastPlaylist()
    }
    
    
    

}
