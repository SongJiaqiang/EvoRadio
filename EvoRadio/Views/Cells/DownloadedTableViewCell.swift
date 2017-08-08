//
//  DownloadedTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 26/10/2016.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

class DownloadedTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var moreButton: UIButton!
    var indexLabel: UILabel!
    
    var delegate: SongListTableViewCellDelegate?
    
    var song: Song?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let v = UIView()
        v.backgroundColor = UIColor.grayColor2()
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
        moreButton.setImage(UIImage(named: "cell_more"), for: UIControlState())
        moreButton.clipsToBounds = true
        moreButton.layer.cornerRadius = 10
        moreButton.layer.borderColor = UIColor.grayColor7().cgColor
        moreButton.layer.borderWidth = 1
        moreButton.addTarget(self, action: #selector(DownloadedTableViewCell.moreButtonPressed(_:)), for: .touchUpInside)
        moreButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 20))
            make.rightMargin.equalTo(-6)
            make.centerY.equalTo(snp.centerY)
        }
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.sizeOf14()
        titleLabel.textColor = UIColor.grayColor7()
        titleLabel.text = "Music Name"
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(indexLabel.snp.right).offset(5)
            make.right.equalTo(moreButton.snp.left).offset(-5)
            make.centerY.equalTo(snp.centerY).offset(-8)
        }
        
        subtitleLabel = UILabel()
        contentView.addSubview(subtitleLabel)
        subtitleLabel.font = UIFont.sizeOf10()
        subtitleLabel.textColor = UIColor.grayColor6()
        subtitleLabel.text = "Artist - AlbumName"
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(indexLabel.snp.right).offset(6)
            make.right.equalTo(moreButton.snp.left).offset(-5)
            make.centerY.equalTo(snp.centerY).offset(8)
        }
        
        let separatorView = UIView()
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor5()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(indexLabel.snp.right)
            make.right.equalTo(moreButton.snp.left)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
    }
    
    //MARK: events
    func moreButtonPressed(_ button: UIButton) {
        if let _ = song {
            delegate?.openToolPanelOfSong(song!)
        }
    }
    
    func updateMusicInfo(_ musicInfo: Song, atIndex: Int) {
        song = musicInfo
        
        indexLabel.text = "\(atIndex + 1)"
        
        titleLabel.text = musicInfo.songName
        
        subtitleLabel.text = musicInfo.artistsName?.appending(" - ").appending(musicInfo.salbumsName!)
        
        
    }

}
