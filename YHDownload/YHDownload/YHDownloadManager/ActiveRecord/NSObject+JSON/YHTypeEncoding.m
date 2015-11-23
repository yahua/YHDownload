//
//  YHTypeEncoding.m
//  ObjectToString
//
//  Created by wangshiwen on 15/9/1.
//  Copyright (c) 2015年 yahua. All rights reserved.
//

#import "YHTypeEncoding.h"

@implementation YHTypeEncoding

+ (NSUInteger)typeOfAttribute:(const char *)attr {
    
    if ( attr[0] != 'T' )
        return YHUNKNOWN;
    
    const char * type = &attr[1];
    if ( type[0] == '@' )
    {
        if ( type[1] != '"' )
            return YHUNKNOWN;
        
        char typeClazz[128] = { 0 };
        
        const char * clazz = &type[2];
        const char * clazzEnd = strchr( clazz, '"' );
        
        if ( clazzEnd && clazz != clazzEnd )
        {
            unsigned int size = (unsigned int)(clazzEnd - clazz);
            strncpy( &typeClazz[0], clazz, size );
        }
        
        if ( 0 == strcmp((const char *)typeClazz, "NSNumber") )
        {
            return YHNSNUMBER;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSString") )
        {
            return YHNSSTRING;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSDate") )
        {
            return YHNSDATE;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSArray") )
        {
            return YHNSARRAY;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSDictionary") )
        {
            return YHNSDICTIONARY;
        }
        else
        {
            return YHOBJECT;
        }
    }
    
    return YHUNKNOWN;
}

+ (NSString *)classNameOf:(const char *)attr
{
    if ( attr[0] != 'T' )
        return nil;
    
    const char * type = &attr[1];
    if ( type[0] == '@' )
    {
        if ( type[1] != '"' )
            return nil;
        
        char typeClazz[128] = { 0 };
        
        const char * clazz = &type[2];
        const char * clazzEnd = strchr( clazz, '"' );
        
        if ( clazzEnd && clazz != clazzEnd )
        {
            unsigned int size = (unsigned int)(clazzEnd - clazz);
            strncpy( &typeClazz[0], clazz, size );
        }
        
        return [NSString stringWithUTF8String:typeClazz];
    }
    
    return nil;
}

+ (NSString *)classNameOfAttribute:(const char *)attr
{
    return [self classNameOf:attr];
}

+ (TypeObject)typeOfObject:(id)object {
    
    if (!object) {
        return YHUNKNOWN;
    }
    
    if ([object isKindOfClass:[NSNumber class]]) {
        return YHNSNUMBER;
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        return YHNSSTRING;
    }
    
    if ([object isKindOfClass:[NSArray  class]]) {
        return YHNSARRAY;
    }
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        return YHNSDICTIONARY;
    }
    
    if ([object isKindOfClass:[NSDate class]]) {
        return YHNSDATE;
    }
    
    if ([object isKindOfClass:[NSObject class]]) {
        return YHOBJECT;
    }
    
    return YHUNKNOWN;
}

+ (BOOL)isAtomClass:(Class)clazz
{
    if ( clazz == [NSArray class] || [[clazz description] isEqualToString:@"__NSCFArray"] )
        return YES;
    if ( clazz == [NSData class] )
        return YES;
    if ( clazz == [NSDate class] )
        return YES;
    if ( clazz == [NSDictionary class] )
        return YES;
    if ( clazz == [NSNull class] )
        return YES;
    if ( clazz == [NSNumber class] || [[clazz description] isEqualToString:@"__NSCFNumber"] )
        return YES;
    if ( clazz == [NSObject class] )
        return YES;
    if ( clazz == [NSString class] || [[clazz description] isEqualToString:@"__NSCFString"] || [[clazz description] isEqualToString:@"__NSConstantString"] )
        return YES;
    if ( clazz == [NSURL class] )
        return YES;
    if ( clazz == [NSValue class] )
        return YES;
    
    return NO;
}

@end
