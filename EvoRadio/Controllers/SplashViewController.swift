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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func preparePlayer() {
        PlayerView.main.prepareUI()
        PlayerViewController.mainController.prepare()
        
        MusicManager.shared.loadLastPlaylist()
    }
    

}
