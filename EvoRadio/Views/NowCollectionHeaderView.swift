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
    func headerView(headerView: NowCollectionHeaderView, didSelectedAtIndex index: Int);
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
        carousel.type = .Rotary
        carousel.dataSource = self
        carousel.delegate = self
        
        carousel.frame = bounds
    }
    
    func updateChannels(channels: [Channel]) {
        self.channels = channels
        
        carousel.reloadData()
    }
    
}


extension NowCollectionHeaderView: iCarouselDataSource, iCarouselDelegate {
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return channels.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        
        let itemView = ReflectionView()
        itemView.frame = CGRectMake(0, 0, 160, 160)
        
        itemView.reflectionAlpha = 0.25
        itemView.reflectionGap = 3.0
        itemView.reflectionScale = 0.15
        
        let coverImageView = UIImageView()
        itemView.addSubview(coverImageView)
        coverImageView.contentMode = .ScaleAspectFill
        coverImageView.frame = itemView.frame
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 4
        
        let channel = channels[index]
        if let picURL = channel.picURL {
            coverImageView.kf_setImageWithURL(NSURL(string: picURL)!, placeholderImage: UIImage.placeholder_cover())
        }
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .Spacing {
            return value * 1.2
        }
        return value
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
        if let _ = delegate {
            delegate?.headerView(self, didSelectedAtIndex: index)
        }
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        print("changing :\(carousel.currentItemIndex)")
    }
    
    func carouselDidEndScrollingAnimation(carousel: iCarousel) {
        print("end scroll :\(carousel.currentItemIndex)")
    }
    
}
