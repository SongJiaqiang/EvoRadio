//
//  ViewControllers.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addChildController(_ childController: UIViewController, toView: UIView?) {
        
        addChildViewController(childController)
        
        if let _ = toView {
            toView?.addSubview(childController.view)
            childController.view.frame = (toView?.bounds)!
            
//            childController.viewsnp.makeConstraints(closure: { (make) in
//                make.size.equalTo((toView?.snp.size)!)
//                make.center.equalTo((toView?.snp.center)!)
//            })
        }else {
            view.addSubview(childController.view)
            childController.view.frame = view.bounds
//            childController.view.snp.makeConstraints(closure: { (make) in
//                make.size.equalTo(view.snp.size)
//                make.center.equalTo(view.snp.center)
//            })
        }
        
    }
    
    func showDestructiveAlert(title: String?,
                              message: String?,
                              DestructiveTitle: String?,
                              handler: ((UIAlertAction) -> Swift.Void)? = nil)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: DestructiveTitle, style: .destructive, handler: handler))
        
        self.present(alert, animated: true, completion: nil)
    }
}

