//
//  RadioTableViewCell.swift
//  EvoRadio
//
//  Created by Jarvis on 9/3/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit

let itemMargin: CGFloat = 10

protocol RadioTableViewCellDelegate: NSObjectProtocol {
    func radioTableViewCell(cell: RadioTableViewCell, didSelectedItem channel: Channel)
    func radioTableViewCell(cell: RadioTableViewCell, showMoreChannelWithRadio radioId: Int)
}

class RadioTableViewCell: UITableViewCell {

    var itemWidth: CGFloat = 0
    var scrollView: UIScrollView!
    var containerView: UIView!
    
    var radio: Radio?
    
    var delegate: RadioTableViewCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clearColor()
        selectionStyle = .None
        
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareUI() {
        
        // 显示2.5个单位
        // | ** ** *|
        itemWidth = (Device.width() - itemMargin * 3) / 2.5
        
        
        
//        scrollView = UIScrollView()
//        contentView.addSubview(scrollView)
//        scrollView.frame = CGRectMake(0, 0, Device.width(), itemWidth+itemMargin*2)
        
        containerView = UIView()
        contentView.addSubview(containerView)
        containerView.frame = CGRectMake(0, 0, Device.width(), itemWidth+itemMargin*2)
        
        let moreButton = UIButton()
        contentView.addSubview(moreButton)
        moreButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        moreButton.setTitle("More", forState: .Normal)
        moreButton.titleLabel?.font = UIFont.sizeOf10()
        moreButton.frame = CGRectMake(Device.width()-itemWidth/2, 10, itemWidth/2, itemWidth)
        moreButton.setBackgroundImage(UIImage(named: "gradient_white"), forState: .Normal)
        moreButton.addTarget(self, action: #selector(RadioTableViewCell.moreButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
    }
    
    func setupChannels(radio: Radio) {
        self.radio = radio
        
        if let channels = radio.channels {
            let count: Int = channels.count < 3 ? channels.count : 3
            for i in 0..<count {
                
                let imageView = UIButton()
                containerView.addSubview(imageView)
                imageView.frame = CGRectMake(itemMargin+(itemWidth+itemMargin) * CGFloat(i), itemMargin, itemWidth, itemWidth)
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
                imageView.addTarget(self, action: #selector(RadioTableViewCell.selectItem(_:)), forControlEvents: .TouchUpInside)
                imageView.tag = i
                
                let nameLabel = UILabel()
                imageView.addSubview(nameLabel)
                nameLabel.frame = CGRectMake(10, itemWidth-30, itemWidth-20, 30)
                nameLabel.font = UIFont.systemFontOfSize(12)
                nameLabel.textColor = UIColor.whiteColor()
                
                let channel = channels[i]
                if let picURL = channel.picURL {
                    imageView.kf_setImageWithURL(NSURL(string: picURL)!, forState: .Normal, placeholderImage: UIImage.placeholder_cover())
                }
                nameLabel.text = channel.channelName
                
            }
        }
    }
    
    //MARK: events
    func moreButtonPressed(button: UIButton) {
        if let _ = delegate {
            if let radioId = radio!.radioID {
                delegate?.radioTableViewCell(self, showMoreChannelWithRadio: radioId.integerValue)
            }
        }
    }
    
    func selectItem(button: UIButton) {
        if let _ = delegate {
            if let channels = radio!.channels {
                delegate?.radioTableViewCell(self, didSelectedItem: channels[button.tag])
            }
        }
    }

}
