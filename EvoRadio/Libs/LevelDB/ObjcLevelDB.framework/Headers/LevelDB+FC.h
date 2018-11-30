//
//  LevelDB+FC.h
//  ObjcLevelDB
//
//  Created by Jarvis on 20/08/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

#import "LevelDB.h"

@interface LevelDB (FC)

- (void)fc_setObject:(id)value forKey:(id)key;

- (id)fc_objectForKey:(id)key;

- (void)fc_enumerateKeysBackward:(BOOL)backward
                   startingAtKey:(id)key
             filteredByPredicate:(NSPredicate *)predicate
                       andPrefix:(id)prefix
                      usingBlock:(LevelDBKeyBlock)block;

- (void)fc_enumerateKeysAndObjectsBackward:(BOOL)backward
                                    lazily:(BOOL)lazily
                             startingAtKey:(id)key
                       filteredByPredicate:(NSPredicate *)predicate
                                 andPrefix:(id)prefix
                                usingBlock:(id)block;

@end
