//
//  ViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/14.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        insertGradientLayer()
        
        navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("内存警告")
    }
    

    func insertGradientLayer() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blackColor3().CGColor,UIColor.blackColor5().CGColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 1)
        gradientLayer.frame = view.frame
        view.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func addChildViewController(childController: UIViewController, inView: UIView) {
        
        addChildViewController(childController)
        childController.view.frame = inView.bounds
        inView.addSubview(childController.view)
        
    }

}

