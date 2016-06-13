//
//  YWAudioService.h
//  YWFeedbackKit
//
//  Created by 慕桥(黄玉坤) on 15/12/23.
//  Copyright © 2015年 www.akkun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YWHybridWebViewFMWK/YWHybridEngine.h>

@interface YWAudioService : NSObject
+ (void)registerYWService:(YWHybridEngine *)engine withViewController:(UIViewController *)viewController;
@end
