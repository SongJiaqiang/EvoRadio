//
//  DownloadingTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 6/1/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadingTableViewCell: UITableViewCell {

    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var progressBar: UIProgressView!
    var sizeLabel: UILabel!
    var deleteButton: UIButton!
    
    var downloadSong: DownloadSongInfo?
    
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
        
        deleteButton = UIButton()
        contentView.addSubview(deleteButton)
        deleteButton.setImage(UIImage(named: "download_delete"), for: UIControlState())
        deleteButton.addTarget(self, action: #selector(DownloadingTableViewCell.deleteButtonPressed(_:)), for: .touchUpInside)
        deleteButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.right.equalTo(snp.right).offset(-6)
            make.centerY.equalTo(snp.centerY)
        }
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.sizeOf14()
        titleLabel.textColor = UIColor.grayColor7()
        titleLabel.text = "Music Title"
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.left).offset(12)
            make.right.equalTo(deleteButton.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(-8)
        }
        
        subtitleLabel = UILabel()
        contentView.addSubview(subtitleLabel)
        subtitleLabel.font = UIFont.sizeOf10()
        subtitleLabel.textColor = UIColor.grayColor6()
        subtitleLabel.text = "waiting..."
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.left).offset(12)
            make.right.equalTo(deleteButton.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(8)
        }
        
        sizeLabel = UILabel()
        contentView.addSubview(sizeLabel)
        sizeLabel.font = UIFont.sizeOf10()
        sizeLabel.textColor = UIColor.grayColor6()
        sizeLabel.textAlignment = .right
        sizeLabel.text = "0.0M/0.0M"
        sizeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.right.equalTo(deleteButton.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(8)
        }
        sizeLabel.isHidden = true
        
        progressBar = UIProgressView()
        contentView.addSubview(progressBar)
        progressBar.progressTintColor = UIColor.goldColor()
        progressBar.snp.makeConstraints { (make) in
            make.left.equalTo(snp.left).offset(12)
            make.right.equalTo(sizeLabel.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(8)
        }
        progressBar.isHidden = true
        
        let separatorView = UIView()
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor5()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(titleLabel.snp.right)
            make.bottom.equalTo(contentView.snp.bottom)
        }
    }
    
    func setupSongInfo(_ songModel: DownloadSongInfo) {
        downloadSong = songModel
        
        titleLabel.text = downloadSong?.song.songName
    }
    
    func updateProgress(downloadModel: MZDownloadModel) {

        var fileSize = "Getting information..."
        if let _ = downloadModel.file?.size {
            fileSize = String(format: "%.1f %@", (downloadModel.file?.size)!, (downloadModel.file?.unit)!)
        }
        
        var downloadedFileSize = "Calculating..."
        if let _ = downloadModel.downloadedFile?.size {
            downloadedFileSize = String(format: "%.1f %@", (downloadModel.downloadedFile?.size)!, (downloadModel.downloadedFile?.unit)!)
        }
        
        progressBar.progress = downloadModel.progress
        sizeLabel.text = "\(downloadedFileSize)/\(fileSize)"
        subtitleLabel.text = downloadModel.status
    }
    
    func updateProgressBar(_ progress: Float, speed:(received: Float, total: Float)) {
        progressBar.progress = progress
        sizeLabel.text = NSString(format: "%.1fM/%.1fM", speed.received, speed.total) as String
    }
    
    func deleteButtonPressed(_ button: UIButton) {
        CoreDB.removeSongFromDownloadingList((downloadSong?.song)!)
    }
    
    
}

