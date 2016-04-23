//
//  WLevelSnapshot.h
//  Benchmark
//
//  Created by lixin on 3/13/15.
//  Copyright (c) 2015 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WLevelDb.h"

@interface WLevelSnapshot : NSObject

- (id)initWithDB:(WLevelDb*)db;
- (id)objectForKey:(id)key;
- (BOOL)objectExistsForKey:(id)key;
- (void)iterateWithPrefixKey:(id)prefixKey iterBlock:(LevelDbIterBlock)iterBlock;

@end
