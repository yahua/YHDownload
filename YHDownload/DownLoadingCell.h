//
//  DownLoadingCell.h
//  YCZZ
//
//  Created by wsw on 15/4/14.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DownLoadManager.h"

@class DownLoadingCell;
@protocol DownloadCellDelegate <NSObject>

- (void)downloadCellClick:(DownLoadingCell *)cell;

- (void)updateDatadownloadCell:(DownLoadingCell *)cell;

@end

@interface DownLoadingCell : UITableViewCell

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UILabel *downloadSizeLab;
@property (strong, nonatomic) UILabel *progressLab;
@property (strong, nonatomic) UIButton *downloadBtn;
@property (weak, nonatomic) id<DownloadCellDelegate> delegate;


+ (CGFloat)heightOfCell;
+ (DownLoadingCell *)cellWithReuseIdentifier:(NSString *)ident;

#pragma mark 设置下载数据
-(void)setDownloadInfo:(DownloadTaskInfo *)downloadInfo;

@end
