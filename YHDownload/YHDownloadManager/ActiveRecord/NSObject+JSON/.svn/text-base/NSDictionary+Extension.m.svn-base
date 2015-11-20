//
//  NSDictionary+Extension.m
//  ObjectToString
//
//  Created by wangshiwen on 15/9/1.
//  Copyright (c) 2015年 yahua. All rights reserved.
//

#import "NSDictionary+Extension.h"
#import "YHTypeEncoding.h"
#import "NSObject+TypeConversion.h"
#import <objc/runtime.h>

@implementation NSDictionary (Extension)

- (id)objectForClass:(Class)clazz {
    
    id object = [[clazz alloc] init];
    if ( nil == object )
        return nil;
    
    for ( Class clazzType = clazz; clazzType != [NSObject class]; )
    {
        unsigned int		propertyCount = 0;
        objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ )
        {
            const char *	name = property_getName(properties[i]);
            NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            const char *	attr = property_getAttributes(properties[i]);
            NSUInteger		type = [YHTypeEncoding typeOfAttribute:attr];

            
            NSObject *	tempValue = [self objectForKey:propertyName];
            NSObject *	value = nil;
            
            if ( tempValue )
            {
                if ( YHNSNUMBER == type )
                {
                    value = [tempValue asNSNumber];
                }
                else if ( YHNSSTRING == type )
                {
                    value = [tempValue asNSString];
                }
                else if ( YHNSDATE == type )
                {
                    value = [tempValue asNSDate];
                }
                else if ( YHNSARRAY == type )
                {
                    if ( [tempValue isKindOfClass:[NSArray class]] )
                    {
                        SEL convertSelector = NSSelectorFromString( [NSString stringWithFormat:@"convertPropertyClassFor_%@", propertyName] );
                        if ( [clazz respondsToSelector:convertSelector] )
                        {
                            Class convertClass = [clazz performSelector:convertSelector];
                            if ( convertClass )
                            {
                                NSMutableArray * arrayTemp = [NSMutableArray array];
                                
                                for ( NSObject * tempObject in (NSArray *)tempValue )
                                {
                                    if ( [tempObject isKindOfClass:[NSDictionary class]] )
                                    {
                                        [arrayTemp addObject:[(NSDictionary *)tempObject objectForClass:convertClass]];
                                    }
                                }
                                
                                value = arrayTemp;
                            }
                            else
                            {
                                value = tempValue;
                            }
                        }
                        else
                        {
                            value = tempValue;
                        }
                    }
                }
                else if ( YHNSDICTIONARY == type )
                {
                    if ( [tempValue isKindOfClass:[NSDictionary class]] )
                    {
                        SEL convertSelector = NSSelectorFromString( [NSString stringWithFormat:@"convertPropertyClassFor_%@", propertyName] );
                        if ( [clazz respondsToSelector:convertSelector] )
                        {
                            Class convertClass = [clazz performSelector:convertSelector];
                            if ( convertClass )
                            {
                                value = [(NSDictionary *)tempValue objectForClass:convertClass];
                            }
                            else
                            {
                                value = tempValue;
                            }
                        }
                        else
                        {
                            value = tempValue;
                        }
                    }
                }
                else if ( YHOBJECT == type )
                {
                    NSString * className = [YHTypeEncoding classNameOfAttribute:attr];
                    if ( [tempValue isKindOfClass:NSClassFromString(className)] )
                    {
                        value = tempValue;
                    }
                    else if ( [tempValue isKindOfClass:[NSDictionary class]] )
                    {
                        value = [(NSDictionary *)tempValue objectForClass:NSClassFromString(className)];
                    }
                }
            }
            
            if ( nil != value )
            {
                [object setValue:value forKey:propertyName];
            }
        }
        
        free( properties );
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
    
    return object;
}

@end
