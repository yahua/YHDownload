//
//  Public.m
//  YHDownload
//
//  Created by 王时温 on 15/11/19.
//  Copyright © 2015年 王时温. All rights reserved.
//

#import "Public.h"

#include <sys/mount.h>

@implementation Public

+ (BOOL)deleteFileWithFileName:(NSString *)fileName {
    
    if (!fileName) {
        return NO;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
        if (error) {
            NSLog(@"deleteFile failed:%@", [error localizedDescription]);
            return NO;
        }
        return YES;
    }
    
    return NO;
}

+ (long long)freeDiskSpaceInBytes {
    
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    long long space = (long long)300 * 1024 * 1024;
    return freespace - space;
}

@end
