//
//  ScrollView.swift
//  EvoRadio
//
//  Created by Jarvis on 1/3/17.
//  Copyright © 2017 JQTech. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    func reloadDataOnMainQueue(after: (() -> Void)?) {
        DispatchQueue.main.async {
            if self is UITableView {
                (self as! UITableView).reloadData()
            }
            else if self is UICollectionView {
                (self as! UICollectionView).reloadData()
            }
            else {
                print("self is not UITableView or UICollectionView")
            }
            
            if after != nil {
                after!()
            }
        }
    }
    
}
