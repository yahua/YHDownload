//
//  DownloadTaskInfo.m
//  Download
//
//  Created by wsw on 10/20/15.
//  Copyright © 2015 wsw. All rights reserved.
//

#import "DownloadTaskInfo.h"
#import "Public.h"

@implementation DownloadTaskInfoRecord

- (void)saveToDB {
    
    [self saveToDB:self.downloadKey];
}

@end

@implementation DownloadTaskInfo

#pragma mark - Public

+ (instancetype)infoWithRecord:(DownloadTaskInfoRecord *)record {
    
    DownloadTaskInfo *taskInfo = [DownloadTaskInfo new];
    taskInfo.downloadKey = record.downloadKey;
    taskInfo.url = record.url;
    taskInfo.status = [record.status integerValue];
    taskInfo.fileSize = [record.fileSize integerValue];
    taskInfo.downSize = [record.downSize integerValue];
    taskInfo.localPath = record.localPath;
    taskInfo.script1 = record.script1;
    taskInfo.script2 = record.script2;
    taskInfo.resourceType = [record.resourceType integerValue];

    return taskInfo;
}

- (NSURL *)downloadFilePath {
    
    NSString *fileName = self.url.lastPathComponent;
    NSString *folderName =[NSString stringWithFormat:@"MyDownload/%@", self.downloadKey];
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *optionPath = [documentPath stringByAppendingPathComponent:folderName];
    if (![fm fileExistsAtPath:optionPath]) {
        [fm createDirectoryAtPath:optionPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", optionPath, fileName]];
}

- (void)deleteResourceDownInfo {
    
    [self.downloadTask cancel];
    self.downloadTask = nil;
    [self.downloadTaskInfoRecord deleteFromDB:self.downloadKey];
    
    [Public deleteFileWithFileName:self.tmpPath];
    [Public deleteFileWithFileName:self.localPath];
}

- (BOOL)checkResouceIsDown {
    
    if (self.resourceType == DownLoadResourceExerciseType &&
        self.status ==Download_status_completed) {  //练习存数据库，没有文件存储
        return YES;
    }
    
    if (self.status ==Download_status_completed &&
        self.fileSize == self.downSize &&
        [self.localPath length] > 0) {
        
        return [[NSFileManager defaultManager] fileExistsAtPath:self.localPath];
    }
    
    return NO;
}

- (void)saveResumeData:(NSData *)resumeData {
    
    if (!resumeData) {
        [Public deleteFileWithFileName:self.tmpPath];
    }else {
        [resumeData writeToFile:self.tmpPath atomically:YES];
    }
}

#pragma mark - Getter Setter

- (DownloadTaskInfoRecord *)downloadTaskInfoRecord {
    
    _downloadTaskInfoRecord = [DownloadTaskInfoRecord new];
    
    _downloadTaskInfoRecord.downloadKey = self.downloadKey;
    _downloadTaskInfoRecord.url =self.url;
    _downloadTaskInfoRecord.status = @(self.status);
    _downloadTaskInfoRecord.script1 =self.script1;
    _downloadTaskInfoRecord.script2 =self.script2;
    _downloadTaskInfoRecord.resourceType = @(self.resourceType);
    _downloadTaskInfoRecord.fileSize = @(self.fileSize);
    _downloadTaskInfoRecord.downSize = @(self.downSize);
    _downloadTaskInfoRecord.localPath = self.localPath;
    
    return _downloadTaskInfoRecord;
}

- (NSString *)tmpPath {
    
    if (!_tmpPath) {
        NSString *fileName = self.url.lastPathComponent;;
        
        NSString *folderName =[NSString stringWithFormat:@"MyDownload/%@", self.downloadKey];
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *optionPath = [documentPath stringByAppendingPathComponent:folderName];
        if (![fm fileExistsAtPath:optionPath]) {
            [fm createDirectoryAtPath:optionPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //设置文件保存路径
        NSString *tempDownloadPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat: @"TempDownload/%@", folderName]];
        if (![fm fileExistsAtPath:tempDownloadPath]) {
            [fm createDirectoryAtPath:tempDownloadPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //设置下载临时文件路径
        _tmpPath = [tempDownloadPath stringByAppendingPathComponent:fileName];
    }
    
    return _tmpPath;
}

- (void)setDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    
    [_downloadTask cancel];
    _downloadTask = downloadTask;
    [_downloadTask resume];
}

- (void)setLocalPath:(NSString *)localPath {
    
    _localPath = [DownloadTaskInfo resetlocalPath:localPath];
}

- (void)setStatus:(Download_status)status {
    
    _status = status;
    if (status == Download_status_completed) {
        [Public deleteFileWithFileName:self.tmpPath];
    }
}

- (void)setFileSize:(long long)fileSize {
    
    if (_fileSize>0 && fileSize == 0) { //快速点击下载和暂停返回的fileSize可能为0
        return;
    }
    _fileSize = fileSize;
}

- (void)setDownSize:(long long)downSize {
    
    if (_downSize>0 && _status!=Download_status_completed && downSize==0) { //快速发送下载和暂停返回的downSize可能为0
        return;
    }
    _downSize = downSize;
}

#pragma mark - Private

+ (NSString*)resetlocalPath:(NSString*)fileName {  //去除file:///  //版本更新导致路径不对的问题
    
    if (!fileName) {
        return nil;
    }
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray * pathArray = [fileName componentsSeparatedByString:@"/"];
    NSString * filePath = [NSString stringWithFormat:@"%@",documentPath];
    BOOL bFind = NO;
    for (NSInteger i=0; i<pathArray.count; i++) {
        NSString *str = [pathArray objectAtIndex:i];
        if ([str isEqualToString:@"MyDownload"]) {
            bFind = YES;
        }
        if (bFind) {
            filePath = [filePath stringByAppendingPathComponent:[pathArray objectAtIndex:i]];
        }
    }
    return filePath;
}

@end
