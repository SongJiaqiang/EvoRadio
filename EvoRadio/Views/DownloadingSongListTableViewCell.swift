//
//  DownloadingSongListTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadingSongListTableViewCell: UITableViewCell {

    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    var progressBar = UIProgressView()
    var sizeLabel = UILabel()
    var deleteButton = UIButton()
    var separatorView = UIView()
    
    var song: Song?
    
    var paused: Bool? = false {
        willSet {
            if let value = newValue {
                subtitleLabel.isHidden = !value
                progressBar.isHidden = value
                sizeLabel.isHidden = value
            }
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let v = UIView()
        v.backgroundColor = UIColor.grayColor2()
        selectedBackgroundView = v
        backgroundColor = UIColor.clear
        
        prepareUI()
        paused = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //MARK: prepare ui
    func prepareUI() {
        
        contentView.addSubview(deleteButton)
        deleteButton.setImage(UIImage(named: "download_delete"), for: UIControlState())
        deleteButton.addTarget(self, action: #selector(DownloadingSongListTableViewCell.deleteButtonPressed(_:)), for: .touchUpInside)
        deleteButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.right.equalTo(snp.right).offset(-6)
            make.centerY.equalTo(snp.centerY)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.sizeOf14()
        titleLabel.textColor = UIColor.grayColor7()
        titleLabel.text = "Music Title"
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.left).offset(12)
            make.right.equalTo(deleteButton.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(-6)
        }
        
        contentView.addSubview(subtitleLabel)
        subtitleLabel.font = UIFont.sizeOf10()
        subtitleLabel.textColor = UIColor.grayColor6()
        subtitleLabel.text = "准备下载"
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.left).offset(12)
            make.right.equalTo(deleteButton.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(8)
        }
        subtitleLabel.isHidden = false
        
        contentView.addSubview(sizeLabel)
        sizeLabel.font = UIFont.sizeOf10()
        sizeLabel.textColor = UIColor.grayColor6()
        sizeLabel.textAlignment = .center
        sizeLabel.text = "0.0M/0.0M"
        sizeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.right.equalTo(deleteButton.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(8)
        }
        sizeLabel.isHidden = true
        
        contentView.addSubview(progressBar)
        progressBar.progressTintColor = UIColor.goldColor()
        progressBar.snp.makeConstraints { (make) in
            make.left.equalTo(snp.left).offset(12)
            make.right.equalTo(sizeLabel.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(8)
        }
        progressBar.isHidden = true
        
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor6()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
            make.bottom.equalTo(snp.bottom)
        }
    }
    
    func updateSongInfo(_ songModel: Song) {
        song = songModel
        
        titleLabel.text = song?.songName
    }
    
    func updateProgressBar(_ progress: Float, speed:(received: Float, total: Float)) {
        progressBar.progress = progress
        sizeLabel.text = NSString(format: "%.1fM/%.1fM", speed.received, speed.total) as String
    }
    
    func deleteButtonPressed(_ button: UIButton) {
        CoreDB.removeSongFromDownloadingList(song!)
    }
    
    
}

