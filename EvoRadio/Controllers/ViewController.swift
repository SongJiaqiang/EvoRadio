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
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 友盟统计 － 进入页面
//        MobClick.beginLogPageView(NSStringFromClass(self.classForCoder))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 友盟统计 － 退出页面
//        MobClick.endLogPageView(NSStringFromClass(self.classForCoder))
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    func insertGradientLayer() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.grayColor3().cgColor,UIColor.grayColor5().cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.frame
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addChildViewController(_ childController: UIViewController, inView: UIView) {
        addChildViewController(childController)
        inView.addSubview(childController.view)
        childController.view.frame = inView.bounds
    }
    
    func addChildViewControllers(_ childControllers: [UIViewController], inView: UIView) {
        for i in 0..<childControllers.count {
            let controller = childControllers[i]
            addChildViewController(controller)
            inView.addSubview(controller.view)
            controller.view.frame = CGRect(x: Device.width()*CGFloat(i), y: 0, width: inView.bounds.width, height: inView.bounds.height)
        }
    }

    func setupBackButton() {
        let backItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .plain, target: self, action: #selector(ViewController.goBack))
        navigationItem.leftBarButtonItem = backItem
    }
    
    func goBack() {
        _ = navigationController?.popViewController(animated: true)
    }
}

