//
//  WLevelDb.h
//  Benchmark
//
//  Created by lixin on 3/13/15.
//  Copyright (c) 2015 lxtap. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SliceFromString(_string_) leveldb::Slice((char *)[_string_ UTF8String], [_string_ lengthOfBytesUsingEncoding:NSUTF8StringEncoding])
#define SliceFromData(_data_) leveldb::Slice((char *)[_data_ bytes], [_data_ length])
#define StringFromSlice(_slice_) [[NSString alloc] initWithBytes:_slice_.data() length:_slice_.size() encoding:NSUTF8StringEncoding]
#define DataFromSlice(_slice_) [NSData dataWithBytes:_slice_.data() length:_slice_.size()]
#define KeyFromStringOrData(_key_) ([_key_ isKindOfClass:[NSString class]]) ? SliceFromString(_key_):SliceFromData(_key_)
#define GenericKeyFromSlice(_slice_) (LevelDBKey) { .data = _slice_.data(), .length = _slice_.size() }

typedef struct {
    const char * data;
    NSUInteger   length;
} LevelDBKey;

typedef NSData * (^LevelDBEncoderBlock) (LevelDBKey * key, id object);
typedef id       (^LevelDBDecoderBlock) (LevelDBKey * key, id data);
typedef void (^LevelDbIterBlock) (LevelDBKey *key, id(^valueGetter)(), BOOL *stop); //return NO to stop iterate

@class WLevelSnapshot, WLevelWriteBatch;

@interface WLevelDb : NSObject

+ (instancetype)sharedDb;

- (id)initWithName:(NSString*)name;

- (NSArray*)allKeys;

- (void)setObject:(id)value forKey:(id)key;

- (id)objectForKey:(id)key;

- (BOOL)objectExistsForKey:(id)key;

- (void)removeObjectForKey:(id)key;

- (void)removeObjectsWithPrefixKey:(id)prefixKey;

- (void)removeAllObjects;

- (void)iterateAllIterBlock:(LevelDbIterBlock)iterBlock;

- (void)iterateWithPrefixKey:(id)prefixKey iterBlock:(LevelDbIterBlock)iterBlock;

- (WLevelWriteBatch*)newWriteBatchWithThreadSafe:(BOOL)isThreadSafe;

- (WLevelSnapshot*)newSnapshot;

- (void*)_leveldb;

/**
 The data encoding block.
 */
@property (nonatomic, copy) LevelDBEncoderBlock encoder;

/**
 The data decoding block.
 */
@property (nonatomic, copy) LevelDBDecoderBlock decoder;

@end
