//
//  RecordDBManager.m
//  YCZZ
//
//  Created by wangshiwen on 15/8/31.
//  Copyright (c) 2015年 com.nd.hy. All rights reserved.
//

#import "RecordDBManager.h"
#import "FMDB.h"

#define KdataBaseName @"record.db"

@interface RecordDBManager ()

@property (nonatomic, strong) FMDatabaseQueue *zzDatabaseQueue;

@end

@implementation RecordDBManager

+ (instancetype)shareInstance {
    
    static RecordDBManager *dbManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        dbManager = [[RecordDBManager alloc] init];
    });
    return dbManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *file = [path stringByAppendingPathComponent:KdataBaseName];
        _zzDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:file flags:SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE];
    }
    return self;
}

#pragma mark - Public

- (void)createTable:(NSString *)tableName {
    
    if (!tableName ||
        [[tableName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return;
    }
    __block BOOL isOk = NO;
    [_zzDatabaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (record text, key text)", tableName];
        isOk = [db executeUpdate:sql];
    }];
}

- (BOOL)saveRecordString:(NSString *)string key:(NSString *)key tableName:(NSString *)tableName; {
    
    if (!string) {
        return NO;
    }
    __block BOOL isOk = NO;
    
    [self.zzDatabaseQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where key = ?", tableName];
        FMResultSet *result = [db executeQuery:sql, key];
        if ([result next]) {
            sql = [NSString stringWithFormat:@"update %@ set record = ? where key = ?", tableName];
            isOk = [db executeUpdate:sql, string, key];
        }else {
            sql = [NSString stringWithFormat:@"insert into %@(record, key) values(?, ?)", tableName];
            isOk = [db executeUpdate:sql, string, key];
        }
        [result close];
        
    }];
    return isOk;
}

- (NSString *)recordStringWithKey:(NSString *)key tableName:(NSString *)tableName {
    
    __block NSString *record;
    [self.zzDatabaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where key = ?", tableName];
        FMResultSet *result = [db executeQuery:sql, key];
        if ([result next]) {
            record = [result stringForColumn:@"record"];
        }
        [result close];
    }];
    return record;
}

- (NSArray *)recordListWithTableName:(NSString *)tableName {
    
    __block NSMutableArray *recordList = [NSMutableArray arrayWithCapacity:1];
    [self.zzDatabaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@", tableName];
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            [recordList addObject:[result stringForColumn:@"record"]];
        }
        [result close];
    }];
    return recordList;
}

- (BOOL)removeRecordStringWithKey:(NSString *)key tableName:(NSString *)tableName {
    
    __block BOOL isOk = NO;
    [self.zzDatabaseQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where key = ?", tableName];
        isOk = [db executeUpdate:sql, key];
    }];
    return isOk;
}

#pragma mark - Private


@end
