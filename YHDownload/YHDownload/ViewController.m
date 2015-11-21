//
//  ViewController.m
//  YHDownload
//
//  Created by wsw on 15/11/19.
//  Copyright © 2015年 wsw. All rights reserved.
//

#import "ViewController.h"
#import "DownLoadManager.h"
#import "DownLoadingCell.h"

@interface ViewController () <UITableViewDelegate,
UITableViewDataSource,
DownloadCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *downloadInfoArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    DownloadCondition *condition = [[DownloadCondition alloc] initWithDownloadKey:@"123" url:@"https://codeload.github.com/spenciefy/SYWaveformPlayer/zip/master"];
    [[DownLoadManager shareInstance] addDownloadTaskWithCondition:condition];
    
    self.downloadInfoArray = [NSMutableArray arrayWithArray:[DownLoadManager shareInstance].downloadingList];
    [self.downloadInfoArray addObjectsFromArray:[DownLoadManager shareInstance].finishList];
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.downloadInfoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DownLoadingCell heightOfCell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    DownloadTaskInfo *downloadInfo = [self.downloadInfoArray objectAtIndex:index];
    
        //TODO 某些情况下会crash， 与kvo有关， 暂时不复用cell
        //        static NSString* CellIdentifier = @"DownLoadingCell";
        //        DownLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //        if (cell == nil) {
        //            cell = [DownLoadingCell cellWithReuseIdentifier:CellIdentifier];
        //            cell.delegate = self;
        //        }
        DownLoadingCell *cell = [DownLoadingCell new];
        cell.delegate = self;
        [cell setDownloadInfo:downloadInfo];
        return cell;
    
}

#pragma mark TableViewDelegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DownLoadingCell *cell = (DownLoadingCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self downloadCellClick:cell];

}

#pragma mark - DownloadCellDelegate

- (void)downloadCellClick:(DownLoadingCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DownloadTaskInfo *downloadInfo = [self.downloadInfoArray objectAtIndex:indexPath.row];
    
    switch (downloadInfo.status) {
        case Download_status_waiting:
        case Download_status_downloading:
        {
            //暂停下载
            [[DownLoadManager shareInstance] pauseDownloadTaskWithKey:downloadInfo.downloadKey];
            break;
        }
        case Download_status_pause:
        case Download_status_Error:
        {
            
            [[DownLoadManager shareInstance] resumeDownloadTaskWithKey:downloadInfo.downloadKey];
            break;
        }
        case Download_status_completed:
        {
            [[DownLoadManager shareInstance] deleteDownloadTaskWithKey:downloadInfo.downloadKey];
            [self.downloadInfoArray removeObject:downloadInfo];
            break;
        }
        default:
            break;
    }
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}


@end
