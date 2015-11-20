//
//  DownLoadManager.m
//  Download
//
//  Created by wsw on 10/20/15.
//  Copyright © 2015 wsw. All rights reserved.
//

#import "DownLoadManager.h"
#import "Public.h"

#import "YHURLSessionManager.h"
#import "YHNetworkActivityIndicatorManager.h"

#define MaxConcurrentOperationCount  3

NSString * const kDownloadAdd = @"kDownloadAdd";
NSString * const kDownloadDelete = @"kDownloadDelete";
NSString * const kDownloading = @"kDownloading";
NSString * const kDownloadComplete = @"kDownloadComplete";
NSString * const kDownloadFail = @"kDownloadFail";
NSString * const kDownloadLowStorage = @"kDownloadLowStorage";

@interface DownLoadManager ()

@property (nonatomic, strong) YHURLSessionManager *urlSessionManager;

@property (nonatomic, strong) NSMutableArray *finishList;
@property (nonatomic, strong) NSMutableArray *downloadingList;
@property (nonatomic, strong) NSMutableArray *curDownloadList;

@end

@implementation DownLoadManager

+ (instancetype)shareInstance {
    
    static DownLoadManager *downloadManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [DownLoadManager new];
    });
    return downloadManager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [YHNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
        _urlSessionManager = [[YHURLSessionManager alloc] init];
        _finishList = [NSMutableArray arrayWithCapacity:1];
        _downloadingList = [NSMutableArray arrayWithCapacity:1];
        _curDownloadList = [NSMutableArray arrayWithCapacity:MaxConcurrentOperationCount];
    
        [self loadDataFromDB];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSessionManagerNotification:) name:YHNetworkingTaskDidCompleteWithoutBlockNotification object:nil];
    }
    return self;
}

#pragma mark - Public

- (void)addDownloadTaskWithCondition:(DownloadCondition *)condition {
    
    if ([self downloadTaskInfoInDownloadingListWithDownloadKey:condition.downloadKey] ||
        [self downloadTaskInfoInFinishListWithDownloadKey:condition.downloadKey]) {
        return;
    }
    
    //原来的下载列表中没有
    DownloadTaskInfo *taskInfo = [[DownloadTaskInfo alloc] init];
    taskInfo.downloadKey = condition.downloadKey;
    taskInfo.url = condition.url;
    taskInfo.script1 = condition.script1;
    taskInfo.script2 = condition.script2;
    taskInfo.resourceType = condition.downloadType;
    [self.downloadingList addObject:taskInfo];
    [self resumeDownloadTaskWithKey:taskInfo.downloadKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadAdd object:taskInfo];
}

- (void)pauseDownloadTaskWithKey:(NSString *)downloadKey {
    
    DownloadTaskInfo *pasuseTaskInfo = [self downloadTaskInfoInDownloadingListWithDownloadKey:downloadKey];
    if (!pasuseTaskInfo) {
        return;
    }
    if (pasuseTaskInfo.status == Download_status_downloading) {
        [pasuseTaskInfo.downloadTask cancelByProducingResumeData:^(NSData * resumeData) {
            [pasuseTaskInfo saveResumeData:resumeData];
        }];
    }
    pasuseTaskInfo.status = Download_status_pause;
    [self completeOneDownloadTask:pasuseTaskInfo];
}

- (void)resumeDownloadTaskWithKey:(NSString *)downloadKey {
    
    DownloadTaskInfo *taskInfo = [self downloadTaskInfoInDownloadingListWithDownloadKey:downloadKey];
    if (!taskInfo) {
        return;
    }
    if (self.curDownloadList.count < MaxConcurrentOperationCount) {
        [self.curDownloadList addObject:taskInfo];
        taskInfo.status =Download_status_downloading;
        [self createDownloadTaskWithTaskInfo:taskInfo];
    }else {
        taskInfo.status = Download_status_waiting;
    }
    [taskInfo.downloadTaskInfoRecord saveToDB];
}

- (void)deleteDownloadTaskWithKey:(NSString *)downloadKey {
    
    DownloadTaskInfo *taskInfo = [self downloadTaskInfoInDownloadingListWithDownloadKey:downloadKey];
    if (taskInfo) {
        [self.downloadingList removeObject:taskInfo];
        [self completeOneDownloadTask:taskInfo];
    }else {
        taskInfo = [self downloadTaskInfoInFinishListWithDownloadKey:downloadKey];
        if (!taskInfo) {
            return;
        }
        [self.finishList removeObject:taskInfo];
    }
    [taskInfo deleteResourceDownInfo];
    
    [self startWaitDownloadTask];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadDelete object:taskInfo];
}

- (void)pauseAllDownloadTask {
    
    for (DownloadTaskInfo *taskInfo in self.downloadingList) {
        [self pauseDownloadTaskWithKey:taskInfo.downloadKey];
    }
}

- (void)resumeAllDownloadTask {
    
    for (DownloadTaskInfo *taskInfo in self.downloadingList) {
        [self resumeDownloadTaskWithKey:taskInfo.downloadKey];
    }
}

- (DownloadTaskInfo *)downloadTaskInfoWithKey:(NSString *)downloadKey {
    
    DownloadTaskInfo *taskInfo = nil;
    taskInfo = [self downloadTaskInfoInFinishListWithDownloadKey:downloadKey];
    if (taskInfo) {
        return taskInfo;
    }
    taskInfo = [self downloadTaskInfoInDownloadingListWithDownloadKey:downloadKey];
    
    return taskInfo;
}

- (long long)downloadTaskSizeInByte {
    
    NSMutableArray *userDownloadList = [NSMutableArray arrayWithArray:self.downloadingList];
    [userDownloadList addObjectsFromArray:self.finishList];
    long long downSize = 0;
    for (DownloadTaskInfo *taskInfo in userDownloadList) {
        downSize += taskInfo.downSize;
    }
    return downSize;
}

#pragma mark - NSNotification

- (void)urlSessionManagerNotification:(NSNotification *)notification {
    
   if ([notification.name isEqualToString:YHNetworkingTaskDidCompleteWithoutBlockNotification]) {
        
        NSURLSessionDownloadTask *downloadTask = notification.object;
        if (!downloadTask) {
            return;
        }
        
        DownloadTaskInfo *taskInfo = [self downloadTaskInfoWithKey:downloadTask.taskDescription];
        if (!taskInfo) {
            return;
        }
        if (downloadTask.response) {  //上次正在下载的或者暂停的任务 第一次重启才会有值
            taskInfo.fileSize = downloadTask.countOfBytesExpectedToReceive;
            taskInfo.downSize = downloadTask.countOfBytesReceived;
        }
        NSError *error = [notification.userInfo objectForKey:YHNetworkingTaskDidCompleteErrorKey];
        if (error) {  //网络请求失败或者后台下载被强制关闭，将下载状态设为失败
           
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            if (resumeData) {
                [taskInfo saveResumeData:resumeData];
            }
        }else {  //下载成功
            
            taskInfo.status = Download_status_completed;
            NSURL *tmpUrl = [notification.userInfo objectForKey:YHNetworkingTaskDidCompleteTmpFileKey];
            NSURL *localPath = [taskInfo downloadFilePath];
            NSError *fileManagerError = nil;
            [[NSFileManager defaultManager] moveItemAtURL:tmpUrl toURL:localPath error:&fileManagerError];
            if (fileManagerError) {
                NSLog(@"下载文件拷贝失败");
            }
            taskInfo.localPath = localPath.absoluteString;
            
            [self.downloadingList removeObject:taskInfo];
            [self.finishList addObject:taskInfo];
        }
        [taskInfo.downloadTaskInfoRecord saveToDB];
    }
}

#pragma mark - Private

- (void)loadDataFromDB {
    
    NSArray *taskInfoRecordList = [DownloadTaskInfoRecord records];
    for (DownloadTaskInfoRecord *record in taskInfoRecordList) {
        
        DownloadTaskInfo *taskInfo = [DownloadTaskInfo infoWithRecord:record];
        if (taskInfo.status ==Download_status_completed) {
            if (![taskInfo checkResouceIsDown]) {
                taskInfo.downSize = 0;
                taskInfo.status =Download_status_Error;
            }
        }
        if (taskInfo.status ==Download_status_completed) {

            [self.finishList addObject:taskInfo];
        }else{
            
            [self.downloadingList addObject:taskInfo];
            taskInfo.status = Download_status_pause;
        }
        [[taskInfo downloadTaskInfoRecord] saveToDB];
    }
}

- (void)createDownloadTaskWithTaskInfo:(DownloadTaskInfo *)taskInfo {
    
    void (^progressBlock)() = ^(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, double progress) {
        [self downloadingTask:taskInfo totalBytesExpectedToWrite:totalBytesExpectedToWrite totalBytesWritten:totalBytesWritten];
    };
    NSURL *(^destination)() =^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [taskInfo downloadFilePath];
    };
    void (^completionHandler)() =^(NSURLSessionTask *urlSessionTask, NSURL *filePath, NSError *error) {
        [self finishDownloadTask:taskInfo urlSessionTask:urlSessionTask filePath:filePath.absoluteString error:error];
    };
    
    NSData *resumeData = [NSData dataWithContentsOfFile:taskInfo.tmpPath];
    NSURLSessionDownloadTask *downloadTask = nil;
    if (resumeData) {
        downloadTask = [self.urlSessionManager downloadTaskWithResumeData:resumeData
                                                                 progress:progressBlock destination:destination
                                                        completionHandler:completionHandler];
    }else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:taskInfo.url]];
        downloadTask = [self.urlSessionManager downloadTaskWithRequest:request
                                                              progress:progressBlock
                                                           destination:destination
                                                     completionHandler:completionHandler];
    }
    if (!downloadTask) {
        return;
    }
    downloadTask.taskDescription = taskInfo.downloadKey;
    taskInfo.downloadTask = downloadTask;
}

- (DownloadTaskInfo *)downloadTaskInfoInDownloadingListWithDownloadKey:(NSString *)downloadKey {
    
    for (DownloadTaskInfo *taskInfo in self.downloadingList) {
        
        if ([taskInfo.downloadKey isEqualToString:downloadKey]) {
            return taskInfo;
        }
    }

    return nil;
}

- (DownloadTaskInfo *)downloadTaskInfoInFinishListWithDownloadKey:(NSString *)downloadKey {
    
    for (DownloadTaskInfo *taskInfo in self.finishList) {
        
        if ([taskInfo.downloadKey isEqualToString:downloadKey]) {
            return taskInfo;
        }
    }
    return nil;
}

- (BOOL)freeDiskSpace {
    
    //检查当前空闲存储空间
    long long freeSize = [Public freeDiskSpaceInBytes];
    long long minSize = (long long)0 * 1024 * 1024;
    if(freeSize <= minSize) {
        return NO;
    }
    return YES;
}

#pragma mark DownloadTask

- (void)completeOneDownloadTask:(DownloadTaskInfo *)taskInfo {
    
    for (DownloadTaskInfo *curDownInfo in self.curDownloadList) {
        if (taskInfo == curDownInfo) {
            [self.curDownloadList removeObject:curDownInfo];
            [self startWaitDownloadTask];
            break;
        }
    }
    [taskInfo.downloadTaskInfoRecord saveToDB];
}

- (void)startWaitDownloadTask {
    
    if(self.curDownloadList.count>=MaxConcurrentOperationCount) {
        return;
    }
    NSInteger count = MaxConcurrentOperationCount - self.curDownloadList.count;
    while (count>0) {
        DownloadTaskInfo *curActiveDownload = nil;
        //查找等待中的任务
        for (DownloadTaskInfo *downInfo in self.downloadingList) {
            if (downInfo.status == Download_status_waiting) {
                curActiveDownload = downInfo;
                break;
            }
        }
        if (!curActiveDownload) {
            break;
        }
        [self resumeDownloadTaskWithKey:curActiveDownload.downloadKey];
        count--;
    }
}

- (void)downloadingTask:(DownloadTaskInfo *)taskInfo totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite totalBytesWritten:(int64_t)totalBytesWritten {
    
    //暂时处理
    if (taskInfo.resourceType == DownLoadResourceVideoDocumentType) { //二分屏下载， 包含图片
        totalBytesExpectedToWrite += totalBytesExpectedToWrite*0.05; //(图片大小为视频大小的5%)
    }
    taskInfo.fileSize = totalBytesExpectedToWrite;
    taskInfo.downSize = totalBytesWritten;
    
    if(![self freeDiskSpace])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"磁盘空间不足，下载失败！" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
        [self pauseAllDownloadTask];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadLowStorage object:taskInfo];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDownloading object:taskInfo];
}

- (void)finishDownloadTask:(DownloadTaskInfo *)taskInfo urlSessionTask:(NSURLSessionTask *)urlSessionTask filePath:(NSString *)filePath error:(NSError *)error {
    
    if (taskInfo.downloadTask != urlSessionTask) {
        return;
    }
    taskInfo.fileSize = urlSessionTask.countOfBytesExpectedToReceive;
    taskInfo.downSize = urlSessionTask.countOfBytesReceived;
    if (error || (!error && taskInfo.fileSize<2000)) {  //404的情况下， 也会下载成功 大小为168b
        
        if (error) {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            [taskInfo saveResumeData:resumeData];
        }else { //404
            [taskInfo saveResumeData:nil];
        }
        
        taskInfo.status = (taskInfo.status==Download_status_downloading)?Download_status_Error:taskInfo.status;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadFail object:taskInfo];
    }else {
        
        taskInfo.localPath = filePath;
        taskInfo.status = Download_status_completed;

        [self.downloadingList removeObject:taskInfo];
        [self.finishList addObject:taskInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDownloadComplete object:taskInfo];
    }
    [self completeOneDownloadTask:taskInfo];
}

@end

#pragma mark - Class DownloadCondition
@implementation DownloadCondition

- (instancetype)initWithDownloadKey:(NSString *)downloadKey
                                url:(NSString *)url
                            script1:(NSString *)script1
                            script2:(NSString *)script2
                       downloadType:(DownLoadResourceType)downloadType {
    
    self = [super init];
    if (self) {
        _downloadKey = downloadKey;
        _url = url;
        _script1 = script1;
        _script2 = script2;
        _downloadType = downloadType;
    }
    return self;
}

- (instancetype)initWithDownloadKey:(NSString *)downloadKey
                                url:(NSString *)url
                            script1:(NSString *)script1
                       downloadType:(DownLoadResourceType)downloadType {
    return [self initWithDownloadKey:downloadKey url:url script1:script1 script2:nil downloadType:downloadType];
}

- (instancetype)initWithDownloadKey:(NSString *)downloadKey
                                url:(NSString *)url
                       downloadType:(DownLoadResourceType)downloadType {
    
    return [self initWithDownloadKey:downloadKey url:url script1:nil script2:nil downloadType:downloadType];
}

@end
