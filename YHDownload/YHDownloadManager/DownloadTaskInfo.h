//
//  DownloadTaskInfo.h
//  Download
//
//  Created by wsw on 10/20/15.
//  Copyright © 2015 wsw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHActiveRecord.h"

typedef NS_ENUM(NSInteger, Download_status) {
    Download_status_waiting=0,
    Download_status_downloading,
    Download_status_completed,
    Download_status_pause,
    Download_status_Error,
};

@interface DownloadTaskInfoRecord : YHActiveRecord

@property (nonatomic, copy)         NSString *downloadKey;
@property (nonatomic, copy)         NSString *url;
@property (nonatomic, copy)         NSString *localPath;        //下载完后存放地址

@property (nonatomic, strong)       NSNumber *fileSize;
@property (nonatomic, strong)       NSNumber *downSize;
@property (nonatomic, strong)       NSNumber *status;
@property (nonatomic, copy)         NSString *script;           //下载任务描述

@end



@interface DownloadTaskInfo : NSObject

@property (nonatomic, copy)         NSString *downloadKey;
@property (nonatomic, copy)         NSString *url;
@property (nonatomic, copy)         NSString *localPath;        //下载完后存放地址
@property (nonatomic, assign)       long long fileSize;
@property (nonatomic, assign)       long long downSize;
@property (nonatomic, assign)       Download_status status;
@property (nonatomic, copy)         NSString *script;

@property (nonatomic, strong)       NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong)       DownloadTaskInfoRecord *downloadTaskInfoRecord;  //用于保存数据库

+ (instancetype)infoWithRecord:(DownloadTaskInfoRecord *)record;

- (NSURL *)downloadFilePath;

- (void)deleteResourceDownInfo;

//文件是否存在
- (BOOL)checkResouceIsDown;

- (void)saveResumeData:(NSData *)resumeData;

- (NSData *)resumeData;

@end
