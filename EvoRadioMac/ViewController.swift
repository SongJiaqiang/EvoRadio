//
//  ViewController.swift
//  EvoRadioMac
//
//  Created by Jarvis on 2019/2/28.
//  Copyright © 2019 JQTech. All rights reserved.
//

import Cocoa
import Alamofire

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func onPressed(_ sender: NSButton) {
        
        Lava.fetch_all_radios({ (radios) in
            if let radio = radios.first {
                print(radio.radioId.debugDescription)
            }

        }) { (e) in
            print("fetch all radios failed: \(e)")
        }
        
        
        
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    func scanData() {
        
    }

}

