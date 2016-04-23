//
//  WLevelWriteBatch.m
//  Benchmark
//
//  Created by lixin on 3/13/15.
//  Copyright (c) 2015 lxtap. All rights reserved.
//

#import "WLevelWriteBatch.h"
#import <leveldb/db.h>
#import <leveldb/options.h>
#import <leveldb/cache.h>
#import <leveldb/filter_policy.h>
#import <leveldb/write_batch.h>
#import "WLevelDb.h"

@interface WLevelWriteBatch()
{
    dispatch_queue_t _serial_queue;
    BOOL needThreadSafe;
    
}

@property (nonatomic, weak) WLevelDb *db;
@property (nonatomic, assign) leveldb::WriteBatch batch;
@end

@implementation WLevelWriteBatch

- (id)initWithLevelDb:(WLevelDb*)db threadSafe:(BOOL)threadSafe {
    if (self = [super init]) {
        needThreadSafe = threadSafe;
        if (needThreadSafe) {
            _serial_queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
        } else {
            _serial_queue = NULL;
        }
        _db = db;
    }
    return self;
}

- (void)dealloc {
    _serial_queue = NULL;
    _db = nil;
}

- (void)setObject:(id)value forKey:(id)key {
    NSAssert(value != nil, @"");
    NSAssert(key != nil, @"");
    void (^b)() = ^{
        leveldb::Slice k = KeyFromStringOrData(key);
        LevelDBKey lkey = GenericKeyFromSlice(k);
        
        NSData *data = _db.encoder(&lkey, value);
        leveldb::Slice v = SliceFromData(data);
        _batch.Put(k, v);
    };
    if (_serial_queue) {
        dispatch_sync(_serial_queue, b);
    } else {
        b();
    }
}

- (void)removeObjectForKey:(id)key {
    NSAssert(key != nil, @"");
    void (^b)() = ^{
        leveldb::Slice k = KeyFromStringOrData(key);
        _batch.Delete(k);
    };
    if (_serial_queue) {
        dispatch_sync(_serial_queue, b);
    } else {
        b();
    }
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    NSAssert(keyArray != nil, @"");
    
    void (^deleteItem)(id key) = ^(id key){
        leveldb::Slice k = KeyFromStringOrData(key);
        _batch.Delete(k);
    };
    
    void (^b)() = ^ {
        [keyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            deleteItem(obj);
        }];
    };
    if (_serial_queue) {
        dispatch_sync(_serial_queue, b);
    } else {
        b();
    }
}

- (void)apply {
    leveldb::DB *ldb = (leveldb::DB *)[_db _leveldb];
    leveldb::Status status = ldb->Write(leveldb::WriteOptions(), &_batch);
    if(!status.ok()) {
        NSLog(@"Problem applying the write batch in database: %s", status.ToString().c_str());
    }
}

@end
