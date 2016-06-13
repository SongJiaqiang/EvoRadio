//
//  AudioPlayer.h
//  YWFeedbackKit
//
//  Created by 慕桥(黄玉坤) on 15/12/23.
//  Copyright © 2015年 www.akkun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YWAudioPlayer : NSObject
- (void)playData:(NSData *)playData;
- (void)playWithAmrUrl:(NSString *)url;
- (void)playWithLocalAmrFile:(NSString *)filePath;

- (void)stopPlay;
- (BOOL)isPlaying;

typedef void (^YWAudioPlayStopedBlock) ();
@property (nonatomic, copy) YWAudioPlayStopedBlock stopedBlock;
- (void)setStopedBlock:(YWAudioPlayStopedBlock)stopedBlock;

typedef void (^YWAudioPlayFailedBlock) (NSError *error);
@property (nonatomic, copy) YWAudioPlayFailedBlock failedBlock;
- (void)setFailedBlock:(YWAudioPlayFailedBlock)failedBlock;

typedef void (^YWAudioPlayFinishedBlock) ();
@property (nonatomic, copy) YWAudioPlayFinishedBlock finishedBlock;
- (void)setFinishedBlock:(YWAudioPlayFinishedBlock)finishedBlock;
@end
