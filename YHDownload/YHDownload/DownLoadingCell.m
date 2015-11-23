//
//  DownLoadingCell.m
//  YCZZ
//
//  Created by wsw on 15/4/14.
//  Copyright (c) 2015年 . All rights reserved.
//

#import "DownLoadingCell.h"
#import "UIView+MethodExt.h"

@interface DownLoadingCell ()

@property (nonatomic, strong) DownloadTaskInfo *downloadInfo;

@end

@implementation DownLoadingCell

+ (CGFloat)heightOfCell
{
    return 80;
}

+ (DownLoadingCell *)cellWithReuseIdentifier:(NSString *)ident
{
    
    DownLoadingCell *cell = [[DownLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    
    return cell;
}

- (void)dealloc
{
    [self removeDownloadInfoObserVer];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initUI];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self.downloadSizeLab sizeToFit];
    self.downloadSizeLab.top = self.titleLab.bottom;
    [self.progressLab sizeToFit];
    self.progressLab.width += 10;
    self.progressLab.left = self.downloadSizeLab.right+12;
    self.progressLab.centerY = self.downloadSizeLab.centerY;
    self.downloadBtn.bottom = self.height;
    self.downloadBtn.right = self.width;
}

#pragma mark - Public

#pragma mark - 设置下载状态
-(void)setDownloadStatus:(Download_status) status
{
    
    NSString *imgName = @"icon_download_pause";
    
    switch (status) {
        case Download_status_waiting:
        {
            imgName = @"icon_download_wait";
            break;
        }
        case Download_status_downloading:
        {
            break;
        }
        case Download_status_pause:
        {
            imgName = @"icon_download_continue";
            break;
        }
        case Download_status_Error:
        {
            imgName = @"icon_download_resume";
            break;
        }
        case Download_status_completed:
        {
            break;
        }
        default:
            break;
    }
    
    [self.downloadBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
}

#pragma mark 设置下载百分比
-(void)setDownloadProgess:(CGFloat)progress
{

    NSString *str = @"%";
    self.progressLab.text = [NSString stringWithFormat:@"已下载：%td%@", (NSInteger)(progress*100), str];
    [self setNeedsLayout];
}

-(void)setDownloadInfo:(DownloadTaskInfo *)downloadInfo
{
    if (!downloadInfo) {
        return;
    }
    _downloadInfo =downloadInfo;
    [self addDownloadInfoObserver];
    //刷新界面
    [self refreshData];
}

#pragma mark - Action 

- (void)clickDownloadBtn {
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(downloadCellClick:)]) {
        [_delegate downloadCellClick:self];
    }
}

#pragma mark - Private KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"downSize"]) {
        
        if (self.downloadInfo.downSize >0 && self.downloadInfo.fileSize>0) { //暂停再下载的时候downSize清零，  防止界面显示从75%变%0再变75%
            CGFloat progress = (CGFloat)self.downloadInfo.downSize/self.downloadInfo.fileSize;
            [self setDownloadProgess:progress];
        }
        //有可能从未下载到有下载 未下载时fileSize为0
        self.downloadSizeLab.text = [NSString stringWithFormat:@"共：%@", [DownLoadingCell formatDataSize:self.downloadInfo.fileSize keepDotNumber:0]];
    } else if ([keyPath isEqualToString:@"status"]) {
        
        if (self.downloadInfo.status == Download_status_completed &&
            _delegate  &&
            [_delegate respondsToSelector:@selector(updateDatadownloadCell:)]) {
            [_delegate updateDatadownloadCell:self];
            [self setDownloadProgess:1];
        }
        [self setDownloadStatus:self.downloadInfo.status];
    }
}

- (void)addDownloadInfoObserver {
    
    [self.downloadInfo addObserver:self forKeyPath:@"downSize" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    [self.downloadInfo addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)removeDownloadInfoObserVer {
    
    [self.downloadInfo removeObserver:self forKeyPath:@"downSize"];
    [self.downloadInfo removeObserver:self forKeyPath:@"status"];
}

#pragma mark - Private

- (void)refreshData
{

    self.titleLab.text = @"下载文件";
    self.downloadSizeLab.text = [NSString stringWithFormat:@"共：%@", [DownLoadingCell formatDataSize:self.downloadInfo.fileSize keepDotNumber:0]];
    
    if (self.downloadInfo.fileSize != 0) {
        [self setDownloadProgess:(CGFloat)self.downloadInfo.downSize/self.downloadInfo.fileSize];
    }else {
        [self setDownloadProgess:0];
    }
    
    if (self.downloadInfo.status == Download_status_completed &&
        _delegate  &&
        [_delegate respondsToSelector:@selector(updateDatadownloadCell:)]) {
        [_delegate updateDatadownloadCell:self];
    }
    [self setDownloadStatus:self.downloadInfo.status];
}

- (void)initUI
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(12, 0, 250, 80)];
    [self addSubview:self.containerView];
    
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 250, 38)];
    self.titleLab.font = [UIFont systemFontOfSize:14.0f];
    self.titleLab.backgroundColor = [UIColor clearColor];
    self.titleLab.textColor = [UIColor blackColor];
    
    //内容大小
    self.downloadSizeLab = [[UILabel alloc] initWithFrame:CGRectZero];
    self.downloadSizeLab.font = [UIFont systemFontOfSize:10.0f];
    self.downloadSizeLab.textColor = [UIColor grayColor];
    
    self.progressLab = [[UILabel alloc] initWithFrame:CGRectZero];
    self.progressLab.font = [UIFont systemFontOfSize:10.0f];
    self.progressLab.textColor = [UIColor grayColor];
    

    
    [self.containerView addSubview:self.titleLab];
    [self.containerView addSubview:self.downloadSizeLab];
    [self.containerView addSubview:self.progressLab];
    

    self.downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadBtn.frame = CGRectMake(0, 0, 46, 46);
    [self.downloadBtn setImage:[UIImage imageNamed:@"icon_download_continue"] forState:UIControlStateNormal];
    [self.downloadBtn setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [self.downloadBtn addTarget:self action:@selector(clickDownloadBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.self.downloadBtn];
    

}

+(NSString *)formatDataSize:(long long) dataSize keepDotNumber:(NSInteger)number
{
    if(dataSize <= 0){
        return [NSString stringWithFormat:@"%dK", 0];
    }
    
    if(dataSize/1024 == 0){
        return [NSString stringWithFormat:@"%lldB", dataSize];
    }
    
    if(dataSize/1024/1024 == 0){
        NSString *formatText = [NSString stringWithFormat:@"%%0.%dfK", number];
        return [NSString stringWithFormat:formatText, (float)dataSize/1024];
    }
    
    if(dataSize/1024/1024/1024 == 0){
        NSString *formatText = [NSString stringWithFormat:@"%%0.%dfM", number];
        return [NSString stringWithFormat:formatText, (float)dataSize/1024/1024];
    }
    
    NSString *formatText = [NSString stringWithFormat:@"%%0.%dfG", number];
    return [NSString stringWithFormat:formatText, (float)dataSize/1024/1024/1024];
}

@end
