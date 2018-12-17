//
//  PLVDownloadProcessingViewController.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/7/24.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVDownloadProcessingViewController.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "UIColor+PLVVod.h"
#import <PLVTimer/PLVTimer.h>
#import "PLVToolbar.h"
#import "PLVSimpleDetailController.h"
#import "PLVDownloadProcessingCell.h"


@interface PLVDownloadProcessingViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet PLVToolbar *toolbar;

@property (nonatomic, strong) NSMutableArray<PLVVodDownloadInfo *> *downloadInfos;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PLVDownloadProcessingCell *> *downloadItemCellDic;

@property (nonatomic, strong) PLVTimer *timer;

@property (nonatomic, strong) UIButton *queueDownloadButton;
@property (nonatomic, strong) UIButton *cleanDownloadButton;

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation PLVDownloadProcessingViewController

- (UIButton *)queueDownloadButton {
    if (!_queueDownloadButton) {
        UIImage *downloadIcon = [UIImage imageNamed:@"plv_btn_cache"];
        downloadIcon = [downloadIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _queueDownloadButton = [PLVToolbar buttonWithTitle:@"全部开始" image:downloadIcon];
        [_queueDownloadButton setTitle:@"全部停止" forState:UIControlStateSelected];
        [_queueDownloadButton setTitleColor:[UIColor colorWithHex:0x2196F3] forState:UIControlStateNormal];
        [_queueDownloadButton addTarget:self action:@selector(queueDownloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _queueDownloadButton;
}

- (UIButton *)cleanDownloadButton{
    if (!_cleanDownloadButton){
        _cleanDownloadButton = [PLVToolbar buttonWithTitle:@"全部清空" image:[UIImage imageNamed:@"plv_icon_clean_all_download"]];
        [_cleanDownloadButton setTitleColor:[UIColor colorWithHex:0xE74C3C] forState:UIControlStateNormal];
        [_cleanDownloadButton addTarget:self action:@selector(cleanDownloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cleanDownloadButton;
}

- (void)dealloc {
    [self.timer cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    PLVVodDownloadManager *downloadManager = [PLVVodDownloadManager sharedManager];
    
    [downloadManager requstDownloadProcessingListWithCompletion:^(NSArray<PLVVodDownloadInfo *> *downloadInfos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.downloadInfos = downloadInfos.mutableCopy;
            
            [weakSelf.tableView reloadData];
        });
    }];
    
    // 所有下载完成回调
    downloadManager.completeBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.queueDownloadButton.selected = NO;
        });
    };
    self.queueDownloadButton.selected = [PLVVodDownloadManager sharedManager].isDownloading;
    
    self.tableView.backgroundColor = [UIColor themeBackgroundColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsSelection = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 92;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    self.toolbar.buttons = @[self.queueDownloadButton, self.cleanDownloadButton];
    self.toolbar.barTintColor = [UIColor whiteColor];
    
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = @"暂无缓存视频";
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyView = emptyLabel;
}

#pragma mark - property

- (void)setDownloadInfos:(NSMutableArray<PLVVodDownloadInfo *> *)downloadInfos {
    _downloadInfos = downloadInfos;
    
    // 设置单元格字典
    NSMutableDictionary *downloadItemCellDic = [NSMutableDictionary dictionary];
    for (PLVVodDownloadInfo *info in downloadInfos) {
        PLVDownloadProcessingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[PLVDownloadProcessingCell identifier]];
        downloadItemCellDic[info.vid] = cell;
    }
    self.downloadItemCellDic = downloadItemCellDic;
    
    // 设置回调
    __weak typeof(self) weakSelf = self;
    for (PLVVodDownloadInfo *info in downloadInfos) {
        // 下载状态改变回调
        info.stateDidChangeBlock = ^(PLVVodDownloadInfo *info) {
            PLVDownloadProcessingCell *cell = weakSelf.downloadItemCellDic[info.vid];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                cell.videoStateLable.text = NSStringFromPLVVodDownloadState(info.state);
                cell.downloadStateImgView.image = [UIImage imageNamed:[self downloadStateImgFromState:info.state]];
                
                switch (info.state) {
                    case PLVVodDownloadStatePreparing:
                    case PLVVodDownloadStateReady:
                    case PLVVodDownloadStateStopped:
                    case PLVVodDownloadStateStopping:{
                        cell.videoStateLable.textColor = [UIColor colorWithHex:0x666666];
                        cell.videoSizeLabel.textColor = [UIColor colorWithHex:0x666666];

                    }break;
                    case PLVVodDownloadStatePreparingStart:
                    case PLVVodDownloadStateRunning:{
                        cell.videoStateLable.textColor = [UIColor colorWithHex:0x4A90E2];
                        cell.videoSizeLabel.textColor = [UIColor colorWithHex:0x4A90E2];

                    }break;
                    case PLVVodDownloadStateSuccess:{
                        cell.videoStateLable.textColor = [UIColor colorWithHex:0x666666];
                        cell.videoSizeLabel.textColor = [UIColor colorWithHex:0x666666];

                        if (info.state == PLVVodDownloadStateSuccess){
                            // 下载成功，从列表中删除
                            [weakSelf handleDownloadSuccess:info];
                        }
                        
                    }break;
                    case PLVVodDownloadStateFailed:{
                        cell.videoStateLable.textColor = [UIColor redColor];
                        cell.videoSizeLabel.textColor = [UIColor redColor];
                    }break;
                }
            });
        };
        
        // 下载进度回调
        info.progressDidChangeBlock = ^(PLVVodDownloadInfo *info) {
            //NSLog(@"vid: %@, progress: %f", info.vid, info.progress);
            PLVDownloadProcessingCell *cell = weakSelf.downloadItemCellDic[info.vid];
            float receivedSize = info.progress * info.filesize;
            if (receivedSize >= info.filesize){
                receivedSize = info.filesize;
            }
            NSString *downloadProgressStr = [NSString stringWithFormat:@"%@/ %@", [self.class formatFilesize:receivedSize],[self.class formatFilesize:info.filesize]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.videoSizeLabel.text = downloadProgressStr;
            });
        };
        
        // 下载速率回调
//        info.bytesPerSecondsDidChangeBlock = ^(PLVVodDownloadInfo *info) {
//            PLVDownloadProcessingCell *cell = weakSelf.downloadItemCellDic[info.vid];
//            NSString *speedString = [NSByteCountFormatter stringFromByteCount:info.bytesPerSeconds countStyle:NSByteCountFormatterCountStyleFile];
//            speedString = [speedString stringByAppendingFormat:@"/s"];
//            dispatch_async(dispatch_get_main_queue(), ^{
////                cell.downloadSpeedLabel.text = speedString;
//            });
//        };
    }
}

#pragma mark -- handle
- (void)handleDownloadSuccess:(PLVVodDownloadInfo *)downloadInfo{
    //
    [self.downloadInfos removeObject:downloadInfo];
    [self.downloadItemCellDic removeObjectForKey:downloadInfo.vid];
    
    [self.tableView reloadData];
}

#pragma mark - action

- (void)queueDownloadButtonAction:(UIButton *)sender {
    if (self.downloadInfos.count == 0)
        return;
    
    sender.selected = !sender.selected;
    PLVVodDownloadManager *downloadManager = [PLVVodDownloadManager sharedManager];
    if (sender.selected) {
        // 开始队列下载
        [downloadManager startDownload];
    } else {
        // 停止队列下载
        [downloadManager stopDownload];
    }
}

- (void)cleanDownloadButtonAction:(UIButton *)sender{
    
    if (self.downloadInfos.count == 0)
        return;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"确定删除所有任务?"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        // 清空下载队列
        [[PLVVodDownloadManager sharedManager] removeAllDownloadWithComplete:^(void *result) {
            //
            [self.downloadInfos removeAllObjects];
            [self.tableView reloadData];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = self.downloadInfos.count;
    self.tableView.backgroundView = number ? nil : self.emptyView;
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVVodDownloadInfo *info = self.downloadInfos[indexPath.row];
    PLVDownloadProcessingCell *cell = self.downloadItemCellDic[info.vid];
    if (!cell) return [UITableViewCell new];
    
    PLVVodVideo *video = info.video;
    if (video){
        cell.thumbnailUrl = video.snapshot;
        cell.titleLabel.text = video.title;
        NSInteger filesize = [video.filesizes[info.quality-1] integerValue];
        
        float receivedSize = info.progress * info.filesize;
        if (receivedSize >= info.filesize){
            receivedSize = info.filesize;
        }
        NSString *downloadProgressStr = [NSString stringWithFormat:@"%@/ %@", [self.class formatFilesize:receivedSize],[self.class formatFilesize:info.filesize]];
        cell.videoSizeLabel.text = downloadProgressStr;
        
    }
    else{
        // 取info数据
        
        cell.thumbnailUrl = info.snapshot;
        cell.titleLabel.text = info.title;
        NSInteger filesize = info.filesize;
        
        float receivedSize = info.progress * info.filesize;
        if (receivedSize >= info.filesize){
            receivedSize = info.filesize;
        }
        NSString *downloadProgressStr = [NSString stringWithFormat:@"%@/ %@", [self.class formatFilesize:receivedSize],[self.class formatFilesize:info.filesize]];
        cell.videoSizeLabel.text = downloadProgressStr;
    }

    cell.backgroundColor = self.tableView.backgroundColor;
    cell.downloadStateImgView.image = [UIImage imageNamed:[self downloadStateImgFromState:info.state]];

    return cell;
}

#pragma mark -- UITableViewDelegate --
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 播放本地缓存视频
    PLVVodDownloadInfo *info = self.downloadInfos[indexPath.row];
    
    switch (info.state) {
        case PLVVodDownloadStateReady:
        case PLVVodDownloadStateRunning:
        {
            // 暂停下载
            [self handleStopDownloadVideo:info];
        }
            break;
        default:
        {
            // 开始下载
            [self handleStartDownloadVideo:info];
        }
            break;
    }
    
}

/// 删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVVodDownloadManager *downloadManager = [PLVVodDownloadManager sharedManager];
    PLVVodDownloadInfo *downloadInfo = self.downloadInfos[indexPath.row];
    [downloadManager removeDownloadWithVid:downloadInfo.video.vid error:nil];
    [self.downloadInfos removeObject:downloadInfo];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - util

+ (NSString *)formatFilesize:(NSInteger)filesize {
    return [NSByteCountFormatter stringFromByteCount:filesize countStyle:NSByteCountFormatterCountStyleFile];
}

- (NSString *)downloadStateImgFromState:(PLVVodDownloadState )state{
    //
    NSString *imageName = nil;
    switch (state) {
        case PLVVodDownloadStateReady:
        case PLVVodDownloadStatePreparing:
            imageName = @"plv_icon_download_will";
            break;
        case PLVVodDownloadStateStopped:
        case PLVVodDownloadStateStopping:
            imageName = @"plv_icon_download_stop";
            break;
        case PLVVodDownloadStatePreparingStart:
        case PLVVodDownloadStateRunning:
            imageName = @"plv_icon_download_processing";
            break;
        case PLVVodDownloadStateSuccess:
            imageName = @"plv_icon_download_will";
            break;
        case PLVVodDownloadStateFailed:
            imageName = @"plv_icon_download_fail";
            break;
            
        default:
            break;
    }
    
    return imageName;
}

#pragma mark -- handle
- (void)handleStopDownloadVideo:(PLVVodDownloadInfo *)info{
    [[PLVVodDownloadManager sharedManager] stopDownloadWithVid:info.vid];
}

- (void)handleStartDownloadVideo:(PLVVodDownloadInfo *)info{
    [[PLVVodDownloadManager sharedManager] startDownloadWithVid:info.vid];
    
    if ([PLVVodDownloadManager sharedManager].isDownloading){
        //
        self.queueDownloadButton.selected = YES;
    }
}


@end
