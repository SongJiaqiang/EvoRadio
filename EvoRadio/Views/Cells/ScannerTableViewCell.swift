//
//  ScannerTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 2019/3/24.
//  Copyright © 2019 JQTech. All rights reserved.
//

import UIKit

class ScannerTableViewCell: UITableViewCell {

    var titleLabel: UILabel!
    var moreButton: UIButton!
    var indexLabel: UILabel!
    
    var delegate: SongListTableViewCellDelegate?
    var scanItem: ScanItem?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let v = UIView()
        v.backgroundColor = UIColor.grayColor1C()
        selectedBackgroundView = v
        backgroundColor = UIColor.clear
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: prepare ui
    func prepareUI() {
        
        indexLabel = UILabel()
        contentView.addSubview(indexLabel)
        indexLabel.textColor = UIColor.gray
        indexLabel.font = UIFont.systemFont(ofSize: 20)
        indexLabel.text = "0"
        indexLabel.textAlignment = .center
        indexLabel.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(40)
            make.left.equalTo(contentView.snp.left)
            make.centerY.equalTo(snp.centerY)
        }
        
        moreButton = UIButton()
        contentView.addSubview(moreButton)
        moreButton.setImage(UIImage(named: "cell_more"), for: .normal)
        moreButton.clipsToBounds = true
        moreButton.layer.cornerRadius = 10
        moreButton.layer.borderColor = UIColor.grayColorBF().cgColor
        moreButton.layer.borderWidth = 1
        moreButton.addTarget(self, action: #selector(DownloadedTableViewCell.moreButtonPressed(_:)), for: .touchUpInside)
        moreButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 20))
            make.rightMargin.equalTo(-6)
            make.centerY.equalTo(snp.centerY)
        }
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.size14()
        titleLabel.textColor = UIColor.grayColorBF()
        titleLabel.text = "Music Name"
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(indexLabel.snp.right).offset(5)
            make.right.equalTo(moreButton.snp.left).offset(-5)
            make.centerY.equalTo(snp.centerY)
        }
        
        let separatorView = UIView()
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor41()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(indexLabel.snp.right)
            make.right.equalTo(moreButton.snp.left)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
    }
    
    //MARK: events
    @objc func moreButtonPressed(_ button: UIButton) {
//        if let _ = item {
//            delegate?.openToolPanelOfSong(song!)
//        }
    }
    
    func updateItem(_ item: ScanItem, atIndex: Int) {
        self.scanItem = item
        
        indexLabel.text = "\(atIndex + 1)"
        titleLabel.text = String(format: "%@-%@", item.id!, item.name!)
        
    }
    
}
