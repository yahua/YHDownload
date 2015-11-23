//
//  Public.h
//  YHDownload
//
//  Created by 王时温 on 15/11/19.
//  Copyright © 2015年 王时温. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Public : NSObject

///file
+ (BOOL)deleteFileWithFileName:(NSString *)fileName;



+ (long long)freeDiskSpaceInBytes;

@end
