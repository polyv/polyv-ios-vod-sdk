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
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsSelection = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 92;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    self.toolbar.buttons = @[self.queueDownloadButton, self.cleanDownloadButton];
    if(@available(iOS 13.0, *)) {
        self.tableView.backgroundColor = [UIColor secondarySystemBackgroundColor];
        self.toolbar.barTintColor = [UIColor systemBackgroundColor];
    } else {
        self.tableView.backgroundColor = [UIColor themeBackgroundColor];
        self.toolbar.barTintColor = [UIColor whiteColor];
    }
    
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
        downloadItemCellDic[info.identifier] = cell;
    }
    self.downloadItemCellDic = downloadItemCellDic;
    
    // 设置回调
    __weak typeof(self) weakSelf = self;
    for (PLVVodDownloadInfo *info in downloadInfos) {
        // 下载状态改变回调
        info.stateDidChangeBlock = ^(PLVVodDownloadInfo *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (info.state == PLVVodDownloadStateSuccess){ //下载成功，从列表中删除
                    [weakSelf handleDownloadSuccess:info];
                }
                
                [weakSelf updateCellWithDownloadInfo:info];
            });
        };
        
        // 下载进度回调
        info.progressDidChangeBlock = ^(PLVVodDownloadInfo *info) {
            //NSLog(@"vid: %@, progress: %f", info.vid, info.progress);
            PLVDownloadProcessingCell *cell = weakSelf.downloadItemCellDic[info.identifier];
            float receivedSize = MIN(info.progress, 1) * info.filesize;
            NSString *downloadProgressStr = [NSString stringWithFormat:@"%@/ %@", [self.class formatFilesize:receivedSize],[self.class formatFilesize:info.filesize]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.videoSizeLabel.text = downloadProgressStr;
            });
        };
      
    }
}

- (void)updateCellWithDownloadInfo:(PLVVodDownloadInfo *)info {
    PLVDownloadProcessingCell *cell = self.downloadItemCellDic[info.identifier];
    
    cell.videoStateLable.text = NSStringFromPLVVodDownloadState(info.state);
    cell.downloadStateImgView.image = [UIImage imageNamed:[self downloadStateImgFromState:info.state]];
    
    switch (info.state) {
        case PLVVodDownloadStatePreparing:
        case PLVVodDownloadStateReady:
        case PLVVodDownloadStateStopped:
        case PLVVodDownloadStateStopping:{
            cell.videoStateLable.textColor = [UIColor colorWithHex:0x666666];
            cell.videoSizeLabel.textColor = [UIColor colorWithHex:0x666666];
        } break;
        case PLVVodDownloadStatePreparingStart:
        case PLVVodDownloadStateRunning:{
            cell.videoStateLable.textColor = [UIColor colorWithHex:0x4A90E2];
            cell.videoSizeLabel.textColor = [UIColor colorWithHex:0x4A90E2];
        } break;
        case PLVVodDownloadStateSuccess:{
            cell.videoStateLable.textColor = [UIColor colorWithHex:0x666666];
            cell.videoSizeLabel.textColor = [UIColor colorWithHex:0x666666];
        } break;
        case PLVVodDownloadStateFailed:{
            cell.videoStateLable.textColor = [UIColor redColor];
            cell.videoSizeLabel.textColor = [UIColor redColor];
        } break;
    }
}

#pragma mark -- handle
- (void)handleDownloadSuccess:(PLVVodDownloadInfo *)downloadInfo{
    //
    [self.downloadInfos removeObject:downloadInfo];
    [self.downloadItemCellDic removeObjectForKey:downloadInfo.identifier];
    
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
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message:@"确定删除所有任务?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 清空下载队列
        [[PLVVodDownloadManager sharedManager] removeAllDownloadWithComplete:^(void *result) {
            //
            [self.downloadInfos removeAllObjects];
            [self.tableView reloadData];
        }];
    }];
                                 
    [alertView addAction:actionSure];
    [alertView addAction:actionCancel];

    [self presentViewController:alertView animated:YES completion:nil];
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
    PLVDownloadProcessingCell *cell = self.downloadItemCellDic[info.identifier];
    if (!cell) return [UITableViewCell new];
    
    PLVVodVideo *video = info.video;
    if (video){
        cell.thumbnailUrl = video.snapshot;
        
        float receivedSize = info.progress * info.filesize;
        if (receivedSize >= info.filesize){
            receivedSize = info.filesize;
        }
        NSString *downloadProgressStr = [NSString stringWithFormat:@"%@/ %@", [self.class formatFilesize:receivedSize],[self.class formatFilesize:info.filesize]];
        cell.videoSizeLabel.text = downloadProgressStr;
        
        if (info.fileType == PLVDownloadFileTypeAudio){
            cell.titleLabel.text = [NSString stringWithFormat:@"[音频] %@", video.title];
        }
        else{
            cell.titleLabel.text = video.title;
        }
    }
    else{
        // 取info数据
        
        cell.thumbnailUrl = info.snapshot;
        cell.titleLabel.text = info.title;
        
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
    if (info.state == PLVVodDownloadStateReady || info.state == PLVVodDownloadStateRunning) {
        // 暂停下载
        [self handleStopDownloadVideo:info];
    } else {
        // 开始下载
        [self handleStartDownloadVideo:info];
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
    
#ifndef PLVSupportDownloadAudio
    [downloadManager removeDownloadWithVid:downloadInfo.video.vid error:nil];
#else
    // 使用音频下载功能的客户，调用如下方法
    PLVVodVideoParams *params = [PLVVodVideoParams videoParamsWithVid:downloadInfo.vid fileType:downloadInfo.fileType];
    [downloadManager removeDownloadWithVideoParams:params error:nil];
#endif
    
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
    }
    
    return imageName;
}

#pragma mark -- handle
- (void)handleStopDownloadVideo:(PLVVodDownloadInfo *)info{
    
#ifndef PLVSupportDownloadAudio
    [[PLVVodDownloadManager sharedManager] stopDownloadWithVid:info.vid];
#else
    // 使用音频下载功能的客户，调用如下方法
    PLVVodVideoParams *params = [PLVVodVideoParams videoParamsWithVid:info.vid fileType:info.fileType];
    [[PLVVodDownloadManager sharedManager] stopDownloadWithVideoParams:params];
#endif
}

- (void)handleStartDownloadVideo:(PLVVodDownloadInfo *)info{
    
#ifndef PLVSupportDownloadAudio
    [[PLVVodDownloadManager sharedManager] startDownloadWithVid:info.vid highPriority:NO];
#else
    // 使用音频下载功能的客户，调用如下方法
    PLVVodVideoParams *params = [PLVVodVideoParams videoParamsWithVid:info.vid fileType:info.fileType];
    [[PLVVodDownloadManager sharedManager] startDownloadWithVideoParams:params];
#endif
    
    if ([PLVVodDownloadManager sharedManager].isDownloading){
        //
        self.queueDownloadButton.selected = YES;
    }
}


@end
