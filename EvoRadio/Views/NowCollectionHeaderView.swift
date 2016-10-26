//
//  NowCollectionHeaderView.swift
//  EvoRadio
//
//  Created by Jarvis on 9/2/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import UIKit
import iCarousel
import ReflectionView

protocol NowCollectionHeaderViewDelegate: NSObjectProtocol {
    func headerView(_ headerView: NowCollectionHeaderView, didSelectedAtIndex index: Int);
}

class NowCollectionHeaderView: UICollectionReusableView {
    
    var carousel: iCarousel!
    var channels = [Channel]()
    var delegate: NowCollectionHeaderViewDelegate?
    
    convenience init(channels: [Channel]) {
        self.init()
        
        self.channels = channels
        
        prepareCarousel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareCarousel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func prepareCarousel() {
        carousel = iCarousel()
        addSubview(carousel)
        carousel.type = .rotary
        carousel.dataSource = self
        carousel.delegate = self
        
        carousel.frame = bounds
    }
    
    func updateChannels(_ channels: [Channel]) {
        self.channels = channels
        
        carousel.reloadData()
    }
    
}


extension NowCollectionHeaderView: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return channels.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let itemWidth: CGFloat = 160
        
        let itemView = ReflectionView()
        itemView.frame = CGRect(x: 0, y: 0, width: itemWidth, height: itemWidth)
        
        itemView.reflectionAlpha = 0.25
        itemView.reflectionGap = 3.0
        itemView.reflectionScale = 0.15
        
        let coverImageView = UIImageView()
        itemView.addSubview(coverImageView)
        coverImageView.frame = itemView.frame
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
//        coverImageView.layer.cornerRadius = 4
        
        let nameLabel = UILabel()
        itemView.addSubview(nameLabel)
        nameLabel.frame = CGRect(x: 10, y: itemWidth-30, width: itemWidth-20, height: 30)
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = UIColor.white
        
        let channel = channels[index]
        if let picURL = channel.picURL {
            coverImageView.kf.setImage(with: URL(string: picURL)!, placeholder: UIImage.placeholder_cover())
        }
        nameLabel.text = channel.channelName
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .spacing {
            return value * 1.2
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        if let _ = delegate {
            delegate?.headerView(self, didSelectedAtIndex: index)
        }
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        print("changing :\(carousel.currentItemIndex)")
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        print("end scroll :\(carousel.currentItemIndex)")
    }
    
}
