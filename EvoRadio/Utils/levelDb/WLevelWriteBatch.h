//
//  WLevelWriteBatch.h
//  Benchmark
//
//  Created by lixin on 3/13/15.
//  Copyright (c) 2015 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLevelDb;

@interface WLevelWriteBatch : NSObject

- (id)initWithLevelDb:(WLevelDb*)db threadSafe:(BOOL)threadSafe;

- (void)setObject:(id)value forKey:(id)key;

- (void)removeObjectForKey:(id)key;

- (void)removeObjectsForKeys:(NSArray *)keyArray;

- (void)apply;

@end
