//
//  ViewController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/14.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    deinit {
        debugPrint("\(NSStringFromClass(self.classForCoder)) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.grayColor3()
        
//        insertGradientLayer()
        
        navigationController?.navigationBar.barTintColor = UIColor.grayColor1()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 友盟统计 － 进入页面
        MobClick.beginLogPageView(NSStringFromClass(self.classForCoder))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 友盟统计 － 退出页面
        MobClick.endLogPageView(NSStringFromClass(self.classForCoder))
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func insertGradientLayer() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.grayColor3().CGColor,UIColor.grayColor5().CGColor]
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

    func setupBackButton() {
        let backItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .Plain, target: self, action: #selector(ViewController.goBack))
        navigationItem.leftBarButtonItem = backItem
    }
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
}

