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
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        titleLabel.textColor = UIColor.grayColorBF()
        titleLabel.text = "Music Title"
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.left).offset(12)
            make.right.equalTo(deleteButton.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(-8)
        }
        
        subtitleLabel = UILabel()
        contentView.addSubview(subtitleLabel)
        subtitleLabel.font = UIFont.sizeOf10()
        subtitleLabel.textColor = UIColor.grayColor97()
        subtitleLabel.text = "waiting..."
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(snp.left).offset(12)
            make.right.equalTo(deleteButton.snp.left).offset(-6)
            make.centerY.equalTo(snp.centerY).offset(8)
        }
        
        sizeLabel = UILabel()
        contentView.addSubview(sizeLabel)
        sizeLabel.font = UIFont.sizeOf10()
        sizeLabel.textColor = UIColor.grayColor97()
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
        separatorView.backgroundColor = UIColor.grayColor41()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(titleLabel.snp.right)
            make.bottom.equalTo(contentView.snp.bottom)
        }
    }
    

    func setupSongInfo(_ songInfo: DownloadSongInfo) {
        downloadSong = songInfo
        
        titleLabel.text = downloadSong?.song?.songName
        subtitleLabel.text = getSubtitleText(status: (downloadSong?.status)!)
        
        subtitleLabel.isHidden = downloadSong?.status == TaskStatus.downloading.rawValue
        progressBar.isHidden = !subtitleLabel.isHidden
        sizeLabel.isHidden = !subtitleLabel.isHidden
    }
    
    func updateProgress(downloadModel: MZDownloadModel) {

        var fileSize = "0.0M"
        if let _ = downloadModel.file?.size {
            fileSize = String(format: "%.1f %@", (downloadModel.file?.size)!, (downloadModel.file?.unit)!)
        }
        
        var downloadedFileSize = "0.0M"
        if let _ = downloadModel.downloadedFile?.size {
            downloadedFileSize = String(format: "%.1f %@", (downloadModel.downloadedFile?.size)!, (downloadModel.downloadedFile?.unit)!)
        }
        
        progressBar.progress = downloadModel.progress
        sizeLabel.text = "\(downloadedFileSize)/\(fileSize)"
    }
    
    func updateProgressBar(_ progress: Float, speed:(received: Float, total: Float)) {
        progressBar.progress = progress
        sizeLabel.text = NSString(format: "%.1fM/%.1fM", speed.received, speed.total) as String
    }
    
    func deleteButtonPressed(_ button: UIButton) {
        CoreDB.removeSongFromDownloadingList(downloadSong!)
    }
    
    func getSubtitleText(status: Int) -> String {
        if status == TaskStatus.gettingInfo.rawValue {
            return "等待下载..."
        }else if status == TaskStatus.downloading.rawValue {
            return "正在下载..."
        }else if status == TaskStatus.paused.rawValue {
            return "已暂停，点击继续下载"
        }else if status == TaskStatus.failed.rawValue {
            return "下载失败，点击重试"
        }else {
            return "点击下载"
        }
    }
    
}

