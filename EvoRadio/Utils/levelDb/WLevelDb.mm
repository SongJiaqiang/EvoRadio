//
//  WLevelDb.m
//  Benchmark
//
//  Created by lixin on 3/13/15.
//  Copyright (c) 2015 lxtap. All rights reserved.
//

#import "WLevelDb.h"
#import "WLevelSnapshot.h"
#import <leveldb/db.h>
#import <leveldb/options.h>
#import <leveldb/cache.h>
#import <leveldb/filter_policy.h>
#import <leveldb/write_batch.h>
#import "WLevelWriteBatch.h"

static NSString * getLibraryPath() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}


@interface WLevelDb()
{
    leveldb::DB* db;
    leveldb::ReadOptions readOptions;
    leveldb::WriteOptions writeOptions;
}
@end

@implementation WLevelDb

+ (instancetype)sharedDb {
    static dispatch_once_t onceToken;
    static WLevelDb *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[WLevelDb alloc] initWithName:@"socialdb"];
    });
    return _instance;
}

- (void)dealloc {
    if (db) {
        delete  db;
        db = NULL;
    }
}

- (id)initWithName:(NSString*)name {
    if (self = [super init]) {
        leveldb::Options options;
        options.create_if_missing = true;
        options.compression = leveldb::kNoCompression;
        NSString *path = [getLibraryPath() stringByAppendingPathComponent:name];
        leveldb::Status status = leveldb::DB::Open(options, [path UTF8String], &db);
        if (!status.ok()) {
            NSLog(@"Problem creating LevelDb :%s", status.ToString().c_str());
            NSAssert(NO, @"");
        }
        //set default encoder
        self.encoder = ^ NSData *(LevelDBKey *key, id object) {
            return [NSKeyedArchiver archivedDataWithRootObject:object];
        };
        self.decoder = ^ id (LevelDBKey *key, NSData *data) {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        };
    }
    return self;
}

- (NSArray*)allKeys {
    NSMutableArray *keys = [NSMutableArray array];
    [self iterateAllIterBlock:^void(LevelDBKey *key, id (^valueGetter)(), BOOL *stop) {
        [keys addObject:[[NSData alloc] initWithBytes:key->data length:key->length]];
    }];
    return keys;
}

- (void)setObject:(id)value forKey:(id)key {
    NSAssert(value != nil, @"");
    NSAssert(key != nil, @"");
    leveldb::Slice k = KeyFromStringOrData(key);
    LevelDBKey lkey = GenericKeyFromSlice(k);
    
    NSData *data = _encoder(&lkey, value);
    leveldb::Slice v = SliceFromData(data);
    
    leveldb::Status status = db->Put(writeOptions, k, v);
    
    if(!status.ok()) {
        NSLog(@"Problem storing key/value pair in database: %s", status.ToString().c_str());
    }
}

- (id)objectForKey:(id)key {
    NSAssert(key != nil, @"");
    leveldb::Slice k = KeyFromStringOrData(key);
    std::string v_string;
    leveldb::Status status = db->Get(readOptions, k, &v_string);
    if (!status.ok()) {
        if (!status.IsNotFound()) {
            NSLog(@"Problem retrieving value for key '%@' from database: %s", key, status.ToString().c_str());
        }
        return nil;
    }
    LevelDBKey lkey = GenericKeyFromSlice(k);
    
    return _decoder(&lkey, DataFromSlice(v_string));
}

- (BOOL)objectExistsForKey:(id)key {
    NSAssert(key != nil, @"");
    leveldb::Slice k = KeyFromStringOrData(key);
    std::string v_string;
    leveldb::Status status = db->Get(readOptions, k, &v_string);
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

- (void)removeObjectForKey:(id)key {
    NSAssert(key != nil, @"");
    leveldb::Slice k = KeyFromStringOrData(key);
    db->Delete(writeOptions, k);
}

- (void)removeObjectsWithPrefixKey:(id)prefixKey {
    if (prefixKey == nil) {
        return;
    }
    [self iterateWithPrefixKey:prefixKey iterBlock:^(LevelDBKey *key, id(^valueGetter)(), BOOL *stop) {
        if (key->length) {
            leveldb::Slice deletekey = leveldb::Slice((char *)key->data, key->length);
            db->Delete(writeOptions, deletekey);
        }
    }];
}

- (void)removeAllObjects {
    [self removeObjectsWithPrefixKey:nil];
}

- (void)iterateAllIterBlock:(LevelDbIterBlock)iterBlock {
    [self iterateWithPrefixKey:nil iterBlock:iterBlock];
}

- (void)iterateWithPrefixKey:(id)prefixKey iterBlock:(LevelDbIterBlock)iterBlock {
    leveldb::Iterator *it = db->NewIterator(readOptions);
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
            return _decoder(&lkey, d);
        };
        BOOL stop = NO;
        iterBlock(&lkey, valueGetter, &stop);
        if (stop) {
            break;
        }
    }
    delete it;
}

- (WLevelWriteBatch*)newWriteBatchWithThreadSafe:(BOOL)isThreadSafe {
    return [[WLevelWriteBatch alloc] initWithLevelDb:self threadSafe:isThreadSafe];
}

- (WLevelSnapshot*)newSnapshot {
    return [[WLevelSnapshot alloc] initWithDB:self];
}

- (void*)_leveldb {
    return db;
}

@end
