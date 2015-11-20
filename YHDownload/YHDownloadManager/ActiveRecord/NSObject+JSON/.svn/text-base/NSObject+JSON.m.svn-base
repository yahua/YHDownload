//
//  NSObject+JSON.m
//  ObjectToString
//
//  Created by wangshiwen on 15/9/1.
//  Copyright (c) 2015年 yahua. All rights reserved.
//

#import "NSObject+JSON.h"
#import "NSObject+TypeConversion.h"
#import "NSDictionary+Extension.h"
#import "YHTypeEncoding.h"
#import "JSONKit.h"

#import <objc/runtime.h>

@implementation NSObject (JSON)

- (NSString *)objectToString {
    
    return [self objectToStringUntilRootClass];
}

- (id)objectToDictionary
{
    return [self objectToDictionaryUntilRootClass];
}

- (id)objectToData {
    
    NSString *string = [self objectToString];
    if (!string) {
        return nil;
    }
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (id)objectFromString:(id)str {
    
    if (!str || ![str isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSError *error;
    NSObject *obj = [(NSString *)str objectFromJSONStringWithParseOptions:JKParseOptionValidFlags error:&error];
    if (!obj) {
        NSLog(@"%@", error);
        return nil;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)obj objectForClass:[self class]];
    }
    else if ( [obj isKindOfClass:[NSArray class]] )
    {
        return [self objectsFromArray:obj];
    }
    else if ( [YHTypeEncoding isAtomClass:[obj class]] )
    {
        return obj;
    }
    return nil;
}

+ (id)objectFromDictionary:(id)dict
{
    if ( nil == dict )
    {
        return nil;
    }
    
    if ( NO == [dict isKindOfClass:[NSDictionary class]] )
    {
        return nil;
    }
    
    return [(NSDictionary *)dict objectForClass:[self class]];
}

+ (id)objectsFromArray:(id)arr {
    
    if ( nil == arr )
        return nil;
    
    if ( NO == [arr isKindOfClass:[NSArray class]] )
        return nil;
    
    NSMutableArray * results = [NSMutableArray array];
    
    for ( NSObject * obj in (NSArray *)arr )
    {
        if ( [obj isKindOfClass:[NSDictionary class]] )
        {
            id newObj = [self objectFromDictionary:obj];
            if ( newObj )
            {
                [results addObject:newObj];
            }
        }else if ([obj isKindOfClass:[NSArray class]]) {
            id newObj = [self objectsFromArray:obj];
            if ( newObj )
            {
                [results addObject:newObj];
            }
        }else
        {
            [results addObject:obj];
        }
    }
    
    return results;
}

+ (id)objectFromData:(id)data
{
    if ( nil == data )
    {
        return nil;
    }
    
    if ( NO == [data isKindOfClass:[NSData class]] )
    {
        return nil;
    }
    
    NSObject * obj = [(NSData *)data objectFromJSONData];
    if ( obj )
    {
        if ( [obj isKindOfClass:[NSDictionary class]] )
        {
            return [(NSDictionary *)obj objectForClass:[self class]];
        }
        else if ( [obj isKindOfClass:[NSArray class]] )
        {
            return [self objectsFromArray:obj];
        }
    }
    
    return nil;
}

#pragma mark - Private

#pragma mark Write

- (id)objectToStringUntilRootClass {
    
    NSString *json;
    NSUInteger selfType = [YHTypeEncoding typeOfObject:self];
    
    switch (selfType) {
        case YHNSNUMBER:
        case YHNSSTRING:
        {
            json = [self asNSString];
        }
            break;
        case YHNSARRAY:
        {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
            for (NSObject *elem in (NSArray *)self) {
                NSDictionary *dic = [elem objectToDictionaryUntilRootClass];
                if (dic) {
                    [array addObject:dic];
                }else {
                    if ([YHTypeEncoding isAtomClass:[elem class]]) {
                        [array addObject:elem];
                    }
                }
            }
            json = [array JSONString];
        }
            break;
        case YHNSDICTIONARY:
        case YHOBJECT:
        {
            NSDictionary *dic = [self objectToDictionaryUntilRootClass];
            if (dic) {
                json = [dic JSONString];
            }
        }
            break;
        case YHNSDATE:
        {
            json = [self description];
        }
            break;
        default:
            break;
    }
    if (!json || json.length == 0) {
        return nil;
    }
    return [NSMutableString stringWithString:json];
}

- (id)objectToDictionaryUntilRootClass
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    if ( [self isKindOfClass:[NSDictionary class]] )
    {
        NSDictionary * dict = (NSDictionary *)self;
        
        for ( NSString * key in dict.allKeys )
        {
            NSObject * obj = [dict objectForKey:key];
            if ( obj )
            {
                NSUInteger propertyType = [YHTypeEncoding typeOfObject:obj];
                if ( YHNSNUMBER == propertyType )
                {
                    [result setObject:obj forKey:key];
                }
                else if ( YHNSSTRING == propertyType )
                {
                    [result setObject:obj forKey:key];
                }
                else if ( YHNSARRAY == propertyType )
                {
                    NSMutableArray * array = [NSMutableArray array];
                    
                    for ( NSObject * elem in (NSArray *)obj )
                    {
                        NSDictionary * dict = [elem objectToDictionaryUntilRootClass];
                        if ( dict )
                        {
                            [array addObject:dict];
                        }
                        else
                        {
                            if ( [YHTypeEncoding isAtomClass:[elem class]] )
                            {
                                [array addObject:elem];
                            }
                        }
                    }
                    
                    [result setObject:array forKey:key];
                }
                else if ( YHNSDICTIONARY == propertyType )
                {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                    
                    for ( NSString * key in ((NSDictionary *)obj).allKeys )
                    {
                        NSObject * val = [(NSDictionary *)obj objectForKey:key];
                        if ( val )
                        {
                            NSDictionary * subresult = [val objectToDictionaryUntilRootClass];
                            if ( subresult )
                            {
                                [dict setObject:subresult forKey:key];
                            }
                            else
                            {
                                if ( [YHTypeEncoding isAtomClass:[val class]] )
                                {
                                    [dict setObject:val forKey:key];
                                }
                            }
                        }
                    }
                    
                    [result setObject:dict forKey:key];
                }
                else if ( YHNSDATE == propertyType )
                {
                    [result setObject:[obj description] forKey:key];
                }
                else
                {
                    obj = [obj objectToDictionaryUntilRootClass];
                    if ( obj )
                    {
                        [result setObject:obj forKey:key];
                    }
                    else
                    {
                        [result setObject:[NSDictionary dictionary] forKey:key];
                    }
                }
            }
        }
    }
    else
    {
        for ( Class clazzType = [self class];; )
        {
            
            if ( [YHTypeEncoding isAtomClass:clazzType] )
                break;
            
            unsigned int		propertyCount = 0;
            objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
            
            for ( NSUInteger i = 0; i < propertyCount; i++ )
            {
                const char *	name = property_getName(properties[i]);
                const char *	attr = property_getAttributes(properties[i]);
                
                NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                NSUInteger		propertyType = [YHTypeEncoding typeOfAttribute:attr];
                
                NSObject * obj = [self valueForKey:propertyName];
                if ( obj )
                {
                    if (YHNSNUMBER == propertyType ||
                        YHNSSTRING == propertyType)
                    {
                        [result setObject:obj forKey:propertyName];
                    }
                    else if ( YHNSARRAY == propertyType )
                    {
                        NSMutableArray * array = [NSMutableArray array];
                        
                        for ( NSObject * elem in (NSArray *)obj )
                        {
                            NSUInteger elemType = [YHTypeEncoding typeOfObject:elem];
                            
                            if (YHNSNUMBER == elemType ||
                                YHNSSTRING == elemType)
                            {
                                [array addObject:elem];
                            }
                            else
                            {
                                NSDictionary * dict = [elem objectToDictionaryUntilRootClass];
                                if ( dict )
                                {
                                    [array addObject:dict];
                                }
                                else
                                {
                                    if ( [YHTypeEncoding isAtomClass:[elem class]] )
                                    {
                                        [array addObject:elem];
                                    }
                                }
                            }
                        }
                        
                        [result setObject:array forKey:propertyName];
                    }
                    else if ( YHNSDICTIONARY == propertyType )
                    {
                        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                        
                        for ( NSString * key in ((NSDictionary *)obj).allKeys )
                        {
                            NSObject * val = [(NSDictionary *)obj objectForKey:key];
                            if ( val )
                            {
                                NSDictionary * subresult = [val objectToDictionaryUntilRootClass];
                                if ( subresult )
                                {
                                    [dict setObject:subresult forKey:key];
                                }
                                else
                                {
                                    if ( [YHTypeEncoding isAtomClass:[val class]] )
                                    {
                                        [dict setObject:val forKey:key];
                                    }
                                }
                            }
                        }
                        
                        [result setObject:dict forKey:propertyName];
                    }
                    else if ( YHNSDATE == propertyType )
                    {
                        [result setObject:[obj description] forKey:propertyName];
                    }
                    else
                    {
                        obj = [obj objectToDictionaryUntilRootClass];
                        if ( obj )
                        {
                            [result setObject:obj forKey:propertyName];
                        }
                        else
                        {
                            [result setObject:[NSDictionary dictionary] forKey:propertyName];
                        }
                    }
                }
            }
            
            free( properties );
            
            clazzType = class_getSuperclass( clazzType );
            if ( nil == clazzType )
                break;
        }
    }
    
    return result.count ? result : nil;
}

#pragma mark Read


@end
