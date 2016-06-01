//
//  SongListTableViewCell.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 5/29/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

protocol SongListTableViewCellDelegate {
    func openToolPanelOfSong(song: Song)
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
        
//        selectionStyle = .None
        
        let v = UIView()
        v.backgroundColor = UIColor.grayColor2()
        selectedBackgroundView = v
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func prepareUI() {
        
        backgroundColor = UIColor.clearColor()
        
        contentView.addSubview(coverImageView)
        coverImageView.image = UIImage.placeholder_cover()
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 4
        coverImageView.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(30, 30))
            make.leftMargin.equalTo(6)
            make.centerY.equalTo(snp_centerY)
        }
        
        contentView.addSubview(moreButton)
        moreButton.setTitle("More", forState: .Normal)
        moreButton.titleLabel?.font = UIFont.sizeOf10()
        moreButton.setTitleColor(UIColor.grayColor7(), forState: .Normal)
        moreButton.clipsToBounds = true
        moreButton.layer.cornerRadius = 10
        moreButton.layer.borderColor = UIColor.grayColor7().CGColor
        moreButton.layer.borderWidth = 1
        moreButton.addTarget(self, action: #selector(SongListTableViewCell.moreButtonPressed(_:)), forControlEvents: .TouchUpInside)
        moreButton.snp_makeConstraints { (make) in
            make.size.equalTo(CGSizeMake(40, 20))
            make.rightMargin.equalTo(-6)
            make.centerY.equalTo(snp_centerY)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.sizeOf14()
        titleLabel.textColor = UIColor.grayColor7()
        titleLabel.text = "祝君好"
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp_right).offset(5)
            make.right.equalTo(moreButton.snp_left).offset(-5)
            make.centerY.equalTo(snp_centerY).offset(-6)
        }
        
        contentView.addSubview(subTitleLabel)
        subTitleLabel.font = UIFont.sizeOf10()
        subTitleLabel.textColor = UIColor.grayColor6()
        subTitleLabel.text = "高凯 - 粤语情话"
        subTitleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(coverImageView.snp_right).offset(6)
            make.right.equalTo(moreButton.snp_left).offset(-5)
            make.centerY.equalTo(snp_centerY).offset(8)
        }
        
        
        contentView.addSubview(separatorView)
        separatorView.backgroundColor = UIColor.grayColor6()
        separatorView.snp_makeConstraints { (make) in
            make.height.equalTo(1.0/Device.screenScale())
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.bottom.equalTo(contentView.snp_bottom)
        }
        
        if let _ = song {
            coverImageView.kf_setImageWithURL(NSURL(string: song!.picURL!)!, placeholderImage: UIImage.placeholder_cover())
            
            titleLabel.text = song?.songName
            
            subTitleLabel.text = song?.artistsName?.stringByAppendingString(" - ").stringByAppendingString(song!.salbumsName!)
        }
        
        
        
    }
    
    
    //MARK: events
    func moreButtonPressed(button: UIButton) {
        delegate?.openToolPanelOfSong(song!)
    }
    
    func updateSongInfo(songModel: Song) {
        song = songModel
        
        coverImageView.kf_setImageWithURL(NSURL(string: songModel.picURL!)!, placeholderImage: UIImage.placeholder_cover())
        
        titleLabel.text = songModel.songName
        
        subTitleLabel.text = songModel.artistsName?.stringByAppendingString(" - ").stringByAppendingString(songModel.salbumsName!)
        
    }
    

}

