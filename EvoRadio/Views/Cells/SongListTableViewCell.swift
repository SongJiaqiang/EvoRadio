//
//  SongListTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 5/29/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

protocol SongListTableViewCellDelegate {
    func openToolPanelOfSong(_ song: Song)
}

class SongListTableViewCell: UITableViewCell {

    var coverImageView = UIImageView()
    var titleLabel = UILabel()
    var subTitleLabel = UILabel()
    var moreButton = UIButton()
    var separatorView = UIView()

    var song: Song?
    
    var delegate: SongListTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        selectedBackgroundView = UIView(color: UIColor(netHex: 0x222222), andSize: CGSize(width: 1, height: 1))
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func prepareUI() {
        
        coverImageView.image = UIImage.placeholder_cover()
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 6
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 46, height: 46))
            make.left.equalTo(contentView.snp.left).offset(20)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        moreButton.setImage(UIImage(named: "cell_more"), for: UIControlState())
        moreButton.clipsToBounds = true
        moreButton.addTarget(self, action: #selector(SongListTableViewCell.moreButtonPressed(_:)), for: .touchUpInside)
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 20))
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        titleLabel.font = UIFont.size18()
        titleLabel.textColor = UIColor.grayColorBF()
        titleLabel.text = "歌曲名称"
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp.right).offset(15)
            make.right.equalTo(moreButton.snp.left).offset(-15)
            make.top.equalTo(coverImageView.snp.top).offset(4)
        }
        
        subTitleLabel.font = UIFont.size14()
        subTitleLabel.textColor = UIColor.grayColor97()
        subTitleLabel.text = "歌手 - 专辑名称"
        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp.right).offset(15)
            make.right.equalTo(moreButton.snp.left).offset(-15)
            make.bottom.equalTo(coverImageView.snp.bottom).offset(-4)
        }
        
        separatorView.backgroundColor = UIColor.grayColor66()
        contentView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        if let _ = song {
            titleLabel.text = song?.songName
            subTitleLabel.text = ((song?.artistsName)! + " - ") + (song?.salbumsName)!
            
            if let picURL = URL(string: (song?.picURL)!) {
                coverImageView.kf.setImage(with: picURL, placeholder: UIImage.placeholder_cover())
            }
        }
        
    }
    
    
    //MARK: events
    func moreButtonPressed(_ button: UIButton) {
        delegate?.openToolPanelOfSong(song!)
    }
    
    func updateSongInfo(_ songModel: Song) {
        song = songModel
        
        if let picURLString = songModel.picURL {
            if let picURL = URL(string: picURLString) {
                coverImageView.kf.setImage(with: picURL, placeholder: UIImage.placeholder_cover())
            }
        }else {
            if let albumImage = songModel.albumImage {
                coverImageView.image = albumImage
            }
        }
        
        titleLabel.text = songModel.songName
        
        
        var subTitle:String = "Unknown artist"
        if let artist = songModel.artistsName {
            subTitle = artist
            if let album = songModel.salbumsName {
                subTitle = subTitle.appending(" - ")
                subTitle = subTitle.appending(album)
            }
        }
        subTitleLabel.text = subTitle
    }
    

}

