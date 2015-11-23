//
//  YHURLSessionManagerTaskDelegate.h
//  Download
//
//  Created by wsw on 10/19/15.
//  Copyright © 2015 wsw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHURLSessionManager.h"

typedef NSURL * (^YHURLSessionDownloadTaskDidFinishDownloadingBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);
typedef void (^YHURLSessionTaskLoadingBlock)(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, double progress);
typedef void (^YHURLSessionTaskCompletionHandler)(NSURLSessionTask *urlSessionTask, NSURL *localath, NSError *error);

//暂时只做下载功能
@interface YHURLSessionManagerTaskDelegate : NSObject <NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, copy)   NSURL *downloadFilePath;
@property (nonatomic, copy)   NSURL *tmpFilePath;    //下载完成后的filepath
@property (nonatomic, copy)   YHURLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
@property (nonatomic, copy)   YHURLSessionTaskLoadingBlock downloadTaskLoading;
@property (nonatomic, copy)   YHURLSessionTaskCompletionHandler completionHandler;

@end
