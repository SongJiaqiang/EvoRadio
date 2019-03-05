//
//  ItunesViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 17/09/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

import UIKit

class ItunesViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        selectedBackgroundView = UIView(color: UIColor(netHex: 0x222222), andSize: CGSize(width: 1, height: 1))
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func prepareUI() {
        
    }

}
