//
//  ViewController.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 16/4/14.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    deinit {
        print("\(NSStringFromClass(self.classForCoder)) deinit")
    }
    
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
        inView.addSubview(childController.view)
        childController.view.frame = inView.bounds
    }
    
    func addChildViewControllers(childControllers: [UIViewController], inView: UIView) {
        for i in 0..<childControllers.count {
            let controller = childControllers[i]
            addChildViewController(controller)
            inView.addSubview(controller.view)
            controller.view.frame = CGRectMake(Device.width()*CGFloat(i), 0, inView.bounds.width, inView.bounds.height)
        }
    }

}

