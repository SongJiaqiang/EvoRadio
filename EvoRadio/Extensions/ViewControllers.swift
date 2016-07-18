//
//  ViewControllers.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addChildController(childController: UIViewController, toView: UIView?) {
        
        addChildViewController(childController)
        
        if let _ = toView {
            toView?.addSubview(childController.view)
            childController.view.frame = (toView?.bounds)!
            
//            childController.viewsnp_makeConstraints(closure: { (make) in
//                make.size.equalTo((toView?.snp_size)!)
//                make.center.equalTo((toView?.snp_center)!)
//            })
        }else {
            view.addSubview(childController.view)
            childController.view.frame = view.bounds
//            childController.view.snp_makeConstraints(closure: { (make) in
//                make.size.equalTo(view.snp_size)
//                make.center.equalTo(view.snp_center)
//            })
        }
        
    }
}

