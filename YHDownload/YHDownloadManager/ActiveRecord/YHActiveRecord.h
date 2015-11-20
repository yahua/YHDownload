//
//  YHActiveRecord.h
//  Download
//
//  Created by wsw on 11/3/15.
//  Copyright © 2015 wsw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHActiveRecord : NSObject

- (void)saveToDB:(NSString *)key;

- (void)deleteFromDB:(NSString *)key;

+ (NSArray *)records;

@end
