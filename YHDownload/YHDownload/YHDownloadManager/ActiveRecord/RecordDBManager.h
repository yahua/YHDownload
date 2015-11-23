//
//  RecordDBManager.h
//  YCZZ
//
//  Created by wangshiwen on 15/8/31.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordDBManager : NSObject

+ (instancetype)shareInstance;

- (void)createTable:(NSString *)tableName;

- (BOOL)saveRecordString:(NSString *)string key:(NSString *)key tableName:(NSString *)tableName;

- (NSString *)recordStringWithKey:(NSString *)key tableName:(NSString *)tableName;

- (BOOL)removeRecordStringWithKey:(NSString *)key tableName:(NSString *)tableName;

- (NSArray *)recordListWithTableName:(NSString *)tableName;

@end
