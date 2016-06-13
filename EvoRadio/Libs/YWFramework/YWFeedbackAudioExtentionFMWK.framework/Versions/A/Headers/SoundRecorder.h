//
//  SoundRecorder.h
//  Messenger
//
//  Created by admin on 14-8-6.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define SoundRecorderDelegate YWSoundRecorderDelegate

@protocol SoundRecorderDelegate <NSObject>
@optional
- (void)onRecordFinished;
- (void)onRecordData:(NSData *)data;
@end

#define SoundRecorder YWSoundRecorder

@interface SoundRecorder : NSObject
@property (nonatomic, weak) id<SoundRecorderDelegate> delegate;
@property (nonatomic, assign) BOOL enableOutputAmrData;                 //默认YES，可以通过getRecordingAmrFileData获取数据

//开始录音
- (void)startRecord;
//结束录音
- (void)stopRecord;
//取消录音
- (void)stopRecordWichCancle;
//录音总时长
- (float)getRecordTime;
//是否正在录音
- (BOOL)isRecording;
//获取Amr文件数据
- (NSData *)getRecordingAmrFileData;
//获取当前输入声音大小
- (float)averagePowerForChannel:(int)channelNumber;
@end

