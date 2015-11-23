//
//  YHActiveRecord.h
//  Download
//
//  Created by wsw on 11/3/15.
//  Copyright © 2015 wsw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHActiveRecord : NSObject

@property (nonatomic, copy) NSString *dbKey;   //数据库查询key

- (void)saveToDB;

- (void)deleteFromDB;

+ (NSArray *)records;

@end
