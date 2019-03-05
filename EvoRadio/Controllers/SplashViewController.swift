//
//  SplashViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 2018/8/9.
//  Copyright © 2018 JQTech. All rights reserved.
//

import UIKit

class SplashViewController: ViewController {
    let InvitationCodes = ["522008", "869796", "576284"]
    
    @IBOutlet weak var splashImageView: UIImageView!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // 监听点击背景
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tap)
        
        // 监听键盘
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        guard let code = codeTextField.text else {
            print("[Error] Invitation code is empty!")
            return
        }
        
        if !InvitationCodes.contains(code) {
            HudManager.showText("邀请码错误", position: .top)
            codeTextField.textColor = UIColor(netHex: 0xFF5E5E)
            print("[Error] Invitation code do not matching!")
            return
        }
        
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
        let kbRect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (info?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double)
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
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return false
        }
        return true
    }
    
}

extension SplashViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        codeTextField.textColor = UIColor.white
        
        if let count = textField.text?.count, count+string.count > 6 {
            textField.text = textField.text?.substring(to: String.Index(encodedOffset: count))
            return false
        }
        return true
    }
}
