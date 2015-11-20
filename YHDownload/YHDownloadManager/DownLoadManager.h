//
//  DownLoadManager.h
//  Download
//
//  Created by wsw on 10/20/15.
//  Copyright © 2015 wsw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadTaskInfo.h"

@class DownloadCondition;
@interface DownLoadManager : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *finishList;
@property (nonatomic, strong, readonly) NSMutableArray *downloadingList;

+ (instancetype)shareInstance;

- (void)addDownloadTaskWithCondition:(DownloadCondition *)condition;

- (void)pauseDownloadTaskWithKey:(NSString *)downloadKey;

- (void)resumeDownloadTaskWithKey:(NSString *)downloadKey;

- (void)deleteDownloadTaskWithKey:(NSString *)downloadKey;


- (void)pauseAllDownloadTask;

- (void)resumeAllDownloadTask;

- (DownloadTaskInfo *)downloadTaskInfoWithKey:(NSString *)downloadKey;
/*
 获取已下载大小
 */
- (long long)downloadTaskSizeInByte;

@end

#pragma mark - 通知

extern NSString * const kDownloadAdd;               //添加一个下载任务
extern NSString * const kDownloadDelete;            //删除一个下载任务
extern NSString * const kDownloading;               //正在下载某个任务
extern NSString * const kDownloadComplete;          //某个下载完成
extern NSString * const kDownloadFail;              //某个下载失败
extern NSString * const kDownloadLowStorage;        //磁盘空间不足

///下载条件
@interface DownloadCondition : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *downloadKey;
@property (nonatomic, copy) NSString *script;

- (instancetype)initWithDownloadKey:(NSString *)downloadKey
                                url:(NSString *)url
                             script:(NSString *)script;

- (instancetype)initWithDownloadKey:(NSString *)downloadKey
                                url:(NSString *)url;

@end

