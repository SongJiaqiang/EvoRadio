//
//  SoundQueues.swift
//  EvoRadio
//
//  Created by Whisper-JQ on 6/12/16.
//  Copyright © 2016 JQTech. All rights reserved.
//

import Foundation
import AFSoundManager

// 已经直接修改AFSoundManager framework
// 因为pod库已被忽略，这里主要记录一下修改过的两处地方

extension AFSoundQueue {
    
    /**
     1. AFSoundManager这个库本身在AFSoundPlayback中有一个playAtSecond方法，用于定位播放进度，
     但是SoundQueue中却没有这个方法，顿时千万只草泥马从眼前飘过。
     于是想给SoundQueue写个扩展，但是player属性是私有的？！
     妈蛋的！！只能直接改AFSoundManager了。
     或者是，换一个库，最近发现Stream-Kit还不错
     // 直接修改源码是下面这样的 AFSoundQueue.m
     //    -(void)playAtSecond:(NSInteger)second {
     //        [_queuePlayer playAtSecond:second];
     //    }
     */
//    func playAtSecond(second: NSInteger) {
//        HudManager.showText("定位到\(second)秒的位置")
//    }
    

    /**
        2. 另外AFSoundItem类中的fetchMetadata也有问题，获取artwork错误，导致app crash
     */
    
//    -(void)fetchMetadata {
//    
//    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:_URL];
//    
//    NSArray *metadata = [playerItem.asset commonMetadata];
//    
//    for (AVMetadataItem *metadataItem in metadata) {
//    
//    [metadataItem loadValuesAsynchronouslyForKeys:@[AVMetadataKeySpaceCommon] completionHandler:^{
//    
//    if ([metadataItem.commonKey isEqualToString:@"title"]) {
//    
//    _title = (NSString *)metadataItem.value;
//    } else if ([metadataItem.commonKey isEqualToString:@"albumName"]) {
//    
//    _album = (NSString *)metadataItem.value;
//    } else if ([metadataItem.commonKey isEqualToString:@"artist"]) {
//    
//    _artist = (NSString *)metadataItem.value;
//    } else if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
//    _artwork = [UIImage imageWithData:[metadataItem.value copyWithZone:nil]];
//    //                if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
//    //
//    //                    _artwork = [UIImage imageWithData:[[metadataItem.value copyWithZone:nil] objectForKey:@"data"]];
//    //                } else if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
//    //
//    //                    _artwork = [UIImage imageWithData:[metadataItem.value copyWithZone:nil]];
//    //                }
//    }
//    }];
//    }
//    }
    
}