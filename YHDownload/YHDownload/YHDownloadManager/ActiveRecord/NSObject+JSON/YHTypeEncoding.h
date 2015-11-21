//
//  YHTypeEncoding.h
//  ObjectToString
//
//  Created by wangshiwen on 15/9/1.
//  Copyright (c) 2015年 yahua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TypeObject) {
    YHUNKNOWN,
    YHOBJECT,
    YHNSNUMBER,
    YHNSSTRING,
    YHNSARRAY,
    YHNSDICTIONARY,
    YHNSDATE
};

@interface YHTypeEncoding : NSObject

+ (NSUInteger)typeOfAttribute:(const char *)attr;
+ (TypeObject)typeOfObject:(id)object;

+ (NSString *)classNameOf:(const char *)attr;
+ (NSString *)classNameOfAttribute:(const char *)attr;

+ (BOOL)isAtomClass:(Class)clazz;

@end
