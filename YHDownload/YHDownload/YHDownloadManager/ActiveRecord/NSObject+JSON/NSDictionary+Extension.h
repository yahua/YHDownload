//
//  NSDictionary+Extension.h
//  ObjectToString
//
//  Created by wangshiwen on 15/9/1.
//  Copyright (c) 2015年 yahua. All rights reserved.
//

#import <Foundation/Foundation.h>

#undef	CONVERT_PROPERTY_CLASS
#define	CONVERT_PROPERTY_CLASS( __name, __class ) \
+ (Class)convertPropertyClassFor_##__name \
{ \
return NSClassFromString( [NSString stringWithUTF8String:#__class] ); \
}

@interface NSDictionary (Extension)

- (id)objectForClass:(Class)clazz;

@end
