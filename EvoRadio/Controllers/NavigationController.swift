//
//  NavigationController.swift
//  EvoRadio
//
//  Created by Jarvis on 16/4/17.
//  Copyright © 2016年 JQTech. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    var isAnimated: Bool = false
    var popQueue = [PopItem]()
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactivePopGestureRecognizer?.delegate = self;
        delegate = self
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        if isAnimated {
            enqueueViewController(nil, animated: animated)
            return nil
        }else {
            return super.popViewController(animated: animated)
        }
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        
        if isAnimated {
            enqueueViewController(viewController, animated: animated)
            return nil
        }else {
            return super.popToViewController(viewController, animated: animated)
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        interactivePopGestureRecognizer?.isEnabled = false
        
        if isAnimated || hasPopViewController() {
            return
        }
        
        isAnimated = true
        
        super.pushViewController(viewController, animated: animated)
    }
    
    
    /** Insert view controller to queue */
    func enqueueViewController(_ viewController: UIViewController?, animated: Bool) {
        let item = PopItem(controller: viewController, animated: animated)
        popQueue.append(item)
        
    }
    
    /** Pop view controller from queue */
    func dequeueViewController(_ navigationController: UINavigationController) {
        if popQueue.count > 0 {
            let item = popQueue.first
            popQueue.remove(at: 0)
            if let controller = item?.controller {
                navigationController.popToViewController(controller, animated: (item?.animated)!)
            }else {
                navigationController.popViewController(animated: (item?.animated)!)
            }
        }
    }
    
    func hasPopViewController() -> Bool {
        return popQueue.count > 0
    }
    
}


//MARK: navigation controller delegates
extension NavigationController: UINavigationControllerDelegate, UINavigationBarDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        isAnimated = false
        interactivePopGestureRecognizer?.isEnabled = true
        
        // pop next view controller in queue
        dequeueViewController(navigationController)
    }
    
}

//MARK: gesuture recognizer delegate
extension NavigationController: UIGestureRecognizerDelegate {
    // if navigation controller's sub view controller more than 1, enable pan gesture to pop itself
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewControllers.count > 1 {
            return true
        }
        return false
    }
}

struct PopItem {
    var controller: UIViewController?
    var animated: Bool
}
