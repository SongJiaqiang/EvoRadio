//
//  AudioNotification.h
//  WXSoundTransformView
//
//  Created by admin on 14-8-18.
//  Copyright (c) 2014年 alibaba. All rights reserved.
//

#ifndef WXSoundTransformView_AudioNotification_h
#define WXSoundTransformView_AudioNotification_h

#import <Foundation/Foundation.h>
#import "AudioToolbox/AudioSession.h"

#define YWAudioSessionInterruptionListener WXAudioSessionInterruptionListener
#define YWAudioSessionInitialize WXAudioSessionInitialize

#define kYWAudioInterruptionNotification kWXAudioInterruptionNotification
#define kYWAudioInterruptionNotificationState kWXAudioInterruptionNotificationState

//全局注册函数

//Audio被打断
void WXAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState);


//初始化Audio, 确保有回调通知
OSStatus WXAudioSessionInitialize();



#define kWXAudioInterruptionNotification          @"kWXAudioInterruptionNotification" //Audio被打断回调
#define kWXAudioInterruptionNotificationState     @"state"                            //int kAudioSessionBeginInterruption,
                                                                                      //    kAudioSessionEndInterruption
#endif