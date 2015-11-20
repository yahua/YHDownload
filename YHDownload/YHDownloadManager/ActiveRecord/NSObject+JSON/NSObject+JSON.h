//
//  NSObject+JSON.h
//  ObjectToString
//
//  Created by wangshiwen on 15/9/1.
//  Copyright (c) 2015年 yahua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSON)

+ (id)objectFromString:(id)str;

+ (id)objectFromDictionary:(id)dict;

+ (id)objectsFromArray:(id)arr;




- (NSString *)objectToString;

- (id)objectToDictionary;

- (id)objectToData;


@end
