//
//  YWFeedbackViewController.h
//  YWFeedbackKit
//
//  Created by 慕桥(黄玉坤) on 15/12/22.
//  Copyright © 2015年 www.akkun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define YWFeedbackViewController YWLightFeedbackViewController

@class YWHybridWebView;
@class YWFeedbackViewController;

/**
 *  打开某个url的回调block
 *  @param aURLString 某个url
 *  @param feedbackController 反馈界面，可作为打开的顶层控制器
 */
typedef void(^YWOpenURLBlock)(NSString *aURLString, YWFeedbackViewController *feedbackController);

@interface YWFeedbackViewController : UIViewController

- (id)initWithChatInfo:(NSDictionary *)chatInfo
         customUIPlist:(NSDictionary *)customUIPlist
               extInfo:(NSDictionary *)extInfo;

/// @brief 聊天界面Web容器
@property (nonatomic, strong, readonly) YWHybridWebView *contentView;

/// @brief 自定义聊天界面配置
@property (nonatomic, strong, readonly) NSDictionary *customUIPlist;

/// @brief 当前会话信息
@property (nonatomic, strong, readonly) NSDictionary *chatInfo;

/// @brief 业务方扩展反馈数据
@property (nonatomic, strong, readonly) NSDictionary *extInfo;

/// @brief 语音是否可用
@property (nonatomic, assign, readonly) BOOL audioEnable;

/// @brief 打开某个url的回调block
@property (nonatomic,   copy) YWOpenURLBlock openURLBlock;

- (id)init NS_UNAVAILABLE;
- (id)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
@end
