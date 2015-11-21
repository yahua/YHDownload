//
//  YHActiveRecord.m
//  Download
//
//  Created by wsw on 11/3/15.
//  Copyright © 2015 wsw. All rights reserved.
//

#import "YHActiveRecord.h"
#import "NSObject+JSON.h"
#import "RecordDBManager.h"

#import <objc/runtime.h>

@implementation YHActiveRecord

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[RecordDBManager shareInstance] createTable:[[self class] tableName]];
    }
    return self;
}

- (void)saveToDB {
    
    NSString *objectString = [self objectToString];
    [[RecordDBManager shareInstance] saveRecordString:objectString key:self.dbKey tableName:[[self class] tableName]];
}

- (void)deleteFromDB {
    
    [[RecordDBManager shareInstance] removeRecordStringWithKey:self.dbKey tableName:[[self class] tableName]];
}

+ (NSArray *)records {
    
    NSArray *activeRecord = [[RecordDBManager shareInstance] recordListWithTableName:[[self class] tableName]];
    NSMutableArray *downloadTaskInfoList = [NSMutableArray arrayWithCapacity:1];
    for (NSString *objectString in activeRecord) {
        [downloadTaskInfoList addObject:[self activeRecordFromString:objectString]];
    }
    return downloadTaskInfoList;
}

#pragma mark - Private

+ (id)activeRecordFromString:(NSString *)objectString {
    
    id record = [[self class] objectFromString:objectString];
    return record;
}

+ (NSString *)tableName
{
    return [NSString stringWithUTF8String:class_getName([self class])];
}

@end
