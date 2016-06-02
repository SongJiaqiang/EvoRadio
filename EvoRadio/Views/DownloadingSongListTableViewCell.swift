//
//  DownloadingSongListTableViewCell.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 6/1/16.
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
                subtitleLabel.hidden = !value
                progressBar.hidden = value
                sizeLabel.hidden = value
            }
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let v = UIView()
        v.backgroundColor = UIColor.grayColor2()
        selectedBackgroundView = v
        backgroundColor = UIColor.clearColor()
        
        prepareUI()
        paused = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //MARK: prepare ui
    func prepareUI() {
        
        contentView.addSubview(deleteButton)
        deleteButton.setImage(UIImage(named: "download_delete"), forState: .Normal)
        deleteButton.addTarget(self, action: #selector(DownloadingSongListTableViewCell.deleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
        deleteButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.right.equalTo(snp_right).offset(-6)
            make.centerY.equalTo(snp_centerY)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.sizeOf14()
        titleLabel.textColor = UIColor.grayColor7()
        titleLabel.text = "Music Title"
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(snp_left).offset(12)
            make.right.equalTo(deleteButton.snp_left).offset(-6)
            make.centerY.equalTo(snp_centerY).offset(-6)
        }
        
        contentView.addSubview(subtitleLabel)
        subtitleLabel.font = UIFont.sizeOf10()
        subtitleLabel.textColor = UIColor.grayColor6()
        subtitleLabel.text = "准备下载"
        subtitleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(snp_left).offset(12)
            make.right.equalTo(deleteButton.snp_left).offset(-6)
            make.centerY.equalTo(snp_centerY).offset(8)
        }
        subtitleLabel.hidden = false
        
        contentView.addSubview(sizeLabel)
        sizeLabel.font = UIFont.sizeOf10()
        sizeLabel.textColor = UIColor.grayColor6()
        sizeLabel.textAlignment = .Center
        sizeLabel.text = "0.0M/0.0M"
        sizeLabel.snp_makeConstraints { (make) in
            make.width.equalTo(60)
            make.right.equalTo(deleteButton.snp_left).offset(-6)
            make.centerY.equalTo(snp_centerY).offset(8)
        }
        sizeLabel.hidden = true
        
        contentView.addSubview(progressBar)
        progressBar.progressTintColor = UIColor.goldColor()
        progressBar.snp_makeConstraints { (make) in
            make.left.equalTo(snp_left).offset(12)
            make.right.equalTo(sizeLabel.snp_left).offset(-6)
            make.centerY.equalTo(snp_centerY).offset(8)
        }
        progressBar.hidden = true
        
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor6()
        separatorView.snp_makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.bottom.equalTo(snp_bottom)
        }
    }
    
    func updateSongInfo(songModel: Song) {
        song = songModel
        
        titleLabel.text = song?.songName
    }
    
    func updateProgressBar(progress: Float, speed:(received: Float, total: Float)) {
        progressBar.progress = progress
        sizeLabel.text = NSString(format: "%.1fM/%.1fM", speed.received, speed.total) as String
    }
    
    func deleteButtonPressed(button: UIButton) {
        CoreDB.removeSongFromDownloadingList(song!)
    }
    
    
}

