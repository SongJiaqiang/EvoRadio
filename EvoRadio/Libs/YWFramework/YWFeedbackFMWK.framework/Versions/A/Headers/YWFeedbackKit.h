//
//  YWFeedbackKit.h
//  YWFeedbackKit
//
//  Created by 慕桥(黄玉坤) on 15/12/21.
//  Copyright © 2015年 www.akkun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YWFeedbackViewController.h"

/**
 *  开发环境
 */
typedef enum {
    YWEnvironmentRelease = 1, // 开发者的线上环境
    YWEnvironmentPreRelease = 2, // 阿里巴巴内网预发环境
    YWEnvironmentDailyForTester = 3, // 阿里巴巴内网环境
}YWEnvironment;

@interface YWFeedbackKit : NSObject

/// 集成OpenIM SDK时注册的的AppKey
@property (nonatomic, strong, readonly) NSString *appKey;

/// 网络环境，可以通过这个属性，在登陆前之前设置网络环境的初始值
@property (nonatomic, assign, readwrite) YWEnvironment environment;

/// 自定义反馈页面配置，在创建反馈页面前设置
@property (nonatomic, strong, readwrite) NSDictionary *customUIPlist;

/// 业务方扩展反馈数据，在创建反馈页面前设置
@property (nonatomic, strong, readwrite) NSDictionary *extInfo;

/// 当前SDK版本号
+ (NSString *)version;

/// @brief 初始化函数，将会以游客身份登陆
/// @params anAppKey 集成OpenIM SDK时注册的的AppKey
/// @return YWFeedbackKit实例
- (id)initWithAppKey:(NSString *)anAppKey;

/// @brief 初始化函数，将登陆指定的云旺（OpenIM）帐号
/// @params aFreeUserId 云旺（OpenIM）帐号
/// @params password 云旺（OpenIM）帐号密码
/// @params anAppKey 集成OpenIM SDK时注册的的AppKey
/// @return YWFeedbackKit实例
- (id)initWithOpenIMUserId:(NSString *)aOpenIMUserId
                  password:(NSString *)aPassword
                    appKey:(NSString *)anAppKey;

/**
 *  @brief 准登陆并创建反馈页面回调Block，反馈页面相关接口见YWFeedbackViewController.h
 *  @param viewController 反馈页面
 *  @param error 调用失败返回错误
 */
typedef void (^YWMakeFeedbackViewControllerCompletionBlock) (YWFeedbackViewController * viewController, NSError *error);

/// @brief 登陆并创建反馈页面
- (void)makeFeedbackViewControllerWithCompletionBlock:(YWMakeFeedbackViewControllerCompletionBlock)completionBlock;

/**
 *  @brief 反馈未读消息数回调Block
 *  @param unreadCount 未读消息数
 *  @param error 调用失败返回错误
 */
typedef void (^YWGetUnreadCountCompletionBlock) (NSNumber *unreadCount, NSError *error);

/// @brief 请求反馈未读消息数
- (void)getUnreadCountWithCompletionBlock:(YWGetUnreadCountCompletionBlock)completionBlock;

- (id)init NS_UNAVAILABLE;
@end

/// 下面联系方式相关的属性需要在创建反馈页面前设置
@interface YWFeedbackKit(ContactInfo)
/// 设置反馈用户联系方式，用于反馈界面展示。
@property (nonatomic, strong) NSString *contactInfo;

/// 隐藏联系方式提醒条，默认显示。绑定客服账号后不再显示。
@property (nonatomic, assign) BOOL hideContactInfoView;
@end
