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
        
        let v = UIView()
        v.backgroundColor = UIColor.grayColor2()
        selectedBackgroundView = v
        backgroundColor = UIColor.clear
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func prepareUI() {
        
        contentView.addSubview(coverImageView)
        coverImageView.image = UIImage.placeholder_cover()
        coverImageView.clipsToBounds = true
//        coverImageView.layer.cornerRadius = 4
        coverImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.leftMargin.equalTo(6)
            make.centerY.equalTo(snp.centerY)
        }
        
        contentView.addSubview(moreButton)
        moreButton.setImage(UIImage(named: "cell_more"), for: UIControlState())
        moreButton.clipsToBounds = true
        moreButton.layer.cornerRadius = 10
        moreButton.layer.borderColor = UIColor.grayColor7().cgColor
        moreButton.layer.borderWidth = 1
        moreButton.addTarget(self, action: #selector(SongListTableViewCell.moreButtonPressed(_:)), for: .touchUpInside)
        moreButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 40, height: 20))
            make.rightMargin.equalTo(-6)
            make.centerY.equalTo(snp.centerY)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.sizeOf14()
        titleLabel.textColor = UIColor.grayColor7()
        titleLabel.text = "祝君好"
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp.right).offset(5)
            make.right.equalTo(moreButton.snp.left).offset(-5)
            make.centerY.equalTo(snp.centerY).offset(-6)
        }
        
        contentView.addSubview(subTitleLabel)
        subTitleLabel.font = UIFont.sizeOf10()
        subTitleLabel.textColor = UIColor.grayColor6()
        subTitleLabel.text = "高凯 - 粤语情话"
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp.right).offset(6)
            make.right.equalTo(moreButton.snp.left).offset(-5)
            make.centerY.equalTo(snp.centerY).offset(8)
        }
        
        
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor6()
        separatorView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
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
        
        if let picURL = URL(string: songModel.picURL!) {
            coverImageView.kf.setImage(with: picURL, placeholder: UIImage.placeholder_cover())
        }
        
        titleLabel.text = songModel.songName
        
        subTitleLabel.text = ((songModel.artistsName)! + " - ") + songModel.salbumsName!
        
    }
    

}

