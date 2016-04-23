//
//  WLevelSnapshot.m
//  Benchmark
//
//  Created by lixin on 3/13/15.
//  Copyright (c) 2015 lxtap. All rights reserved.
//

#import "WLevelSnapshot.h"
#import "WLevelDb.h"
#import <leveldb/db.h>
#import <leveldb/options.h>
#import <leveldb/cache.h>

@interface WLevelSnapshot()
{
    leveldb::ReadOptions options;
    leveldb::DB *ldb;
}
@property (nonatomic, weak) WLevelDb *db;
@end

@implementation WLevelSnapshot

- (id)initWithDB:(WLevelDb*)db {
    if (self = [super init]) {
        _db = db;
        ldb = (leveldb::DB *)[db _leveldb];
        options.snapshot = ldb->GetSnapshot();
    }
    return self;
}

- (void)dealloc {
    ldb->ReleaseSnapshot(options.snapshot);
    ldb = NULL;
}

- (id)objectForKey:(id)key {
    NSAssert(key != nil, @"");
    leveldb::Slice k = KeyFromStringOrData(key);
    std::string v_string;
    leveldb::Status status = ldb->Get(options, k, &v_string);
    if (!status.ok()) {
        if (!status.IsNotFound()) {
            NSLog(@"Problem retrieving value for key '%@' from database: %s", key, status.ToString().c_str());
        }
        return nil;
    }
    LevelDBKey lkey = GenericKeyFromSlice(k);
    
    return _db.decoder(&lkey, DataFromSlice(v_string));
}

- (BOOL)objectExistsForKey:(id)key {
    NSAssert(key != nil, @"");
    leveldb::Slice k = KeyFromStringOrData(key);
    std::string v_string;
    leveldb::Status status = ldb->Get(options, k, &v_string);
    if (!status.ok()) {
        if (status.IsNotFound()) {
            return NO;
        } else {
            NSLog(@"Problem retrieving value for key '%@' from database: %s", key, status.ToString().c_str());
            return NO;
        }
    } else {
        return YES;
    }
}

- (void)iterateWithPrefixKey:(id)prefixKey iterBlock:(LevelDbIterBlock)iterBlock {
    leveldb::Iterator *it = ldb->NewIterator(options);
    if (prefixKey) {
        leveldb::Slice sPrefixKey = KeyFromStringOrData(prefixKey);
        it->Seek(sPrefixKey);
    } else {
        it->SeekToFirst();
    }
    
    const char *prekey_bytes;
    NSInteger prekey_len;
    if ([prefixKey isKindOfClass:[NSString class]]) {
        prekey_bytes = [prefixKey UTF8String];
    } else if ([prefixKey isKindOfClass:[NSData class]]) {
        prekey_bytes = (const char*)[prefixKey bytes];
    } else {
        NSAssert(NO, @"key should be NSString or NSData");
    }
    prekey_len = [prefixKey length];
    for (; it->Valid(); it->Next()) {
        __block LevelDBKey lkey = GenericKeyFromSlice(it->key());
        leveldb::Slice value = it->value();
        
        if (lkey.length < prekey_len) {
            break;
        } else if (memcmp(prekey_bytes, lkey.data, prekey_len) != 0) {
            break;
        }
        id(^valueGetter)(void) = ^id() {
            NSData *d = DataFromSlice(value);
            return _db.decoder(&lkey, d);
        };
        BOOL stop = NO;
        iterBlock(&lkey, valueGetter, &stop);
        if (stop) {
            break;
        }
    }
    delete it;
}

@end