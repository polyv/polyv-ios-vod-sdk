//
//  PLVDownloadCompleteViewController.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/7/24.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVDownloadCompleteViewController.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "UIColor+PLVVod.h"
#import <PLVTimer/PLVTimer.h>
#import "PLVToolbar.h"
#import "PLVSimpleDetailController.h"
#import "PLVPPTSimpleDetailController.h"
#import "PLVDownloadComleteCell.h"
#import "PLVDownloadCompleteInfoModel.h"


@interface PLVDownloadCompleteViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<PLVDownloadCompleteInfoModel *> *downloadInfos;

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation PLVDownloadCompleteViewController

- (NSMutableArray<PLVDownloadCompleteInfoModel *> *)downloadInfos{
    if (!_downloadInfos){
        _downloadInfos = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _downloadInfos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
   
    [self initVideoList];
    
    self.tableView.backgroundColor = [UIColor themeBackgroundColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsSelection = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.text = @"暂无缓存视频";
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyView = emptyLabel;
    
    //
    [PLVVodDownloadManager sharedManager].downloadCompleteBlock = ^(PLVVodDownloadInfo *info) {
        // 刷新列表
        dispatch_async(dispatch_get_main_queue(), ^{
            
            PLVDownloadCompleteInfoModel *model = [[PLVDownloadCompleteInfoModel alloc] init];
            model.downloadInfo = info;
            model.localVideo = [PLVVodLocalVideo localVideoWithVideo:info.video dir:[PLVVodDownloadManager sharedManager].downloadDir];
            [weakSelf.downloadInfos addObject:model];
            
            [weakSelf.tableView reloadData];
        });
    };
}

- (void)initVideoList{
    
    // 从数据库中读取已缓存视频详细信息
    // TODO:也可以从开发者自定义数据库中读取数据,方便扩展
    NSArray<PLVVodDownloadInfo *> *dbInfos = [[PLVVodDownloadManager sharedManager] requestDownloadCompleteList];
    NSMutableDictionary *dbCachedDics = [[NSMutableDictionary alloc] init];
    [dbInfos enumerateObjectsUsingBlock:^(PLVVodDownloadInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dbCachedDics setObject:obj forKey:obj.vid];
        
        PLVDownloadCompleteInfoModel *model = [[PLVDownloadCompleteInfoModel alloc] init];
        model.downloadInfo = obj;
        [self.downloadInfos addObject:model];
    }];
    
}

#pragma mark - property

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
    
    PLVDownloadComleteCell *cell = [tableView dequeueReusableCellWithIdentifier:[PLVDownloadComleteCell identifier]];
    
    PLVVodDownloadInfo *info = [self.downloadInfos objectAtIndex:indexPath.row].downloadInfo;
    
    cell.thumbnailUrl = info.snapshot;
    cell.titleLabel.text = info.title;
    if (info.fileType == PLVDownloadFileTypeAudio){
        //
        cell.titleLabel.text = [NSString stringWithFormat:@"[音频] %@", info.title];
    }
    
    NSInteger filesize = info.filesize;
    cell.videoSizeLabel.text = [self.class formatFilesize:filesize];
    cell.videoDurationTime.text = [self.class timeFormatStringWithTime:info.duration];
    
    cell.downloadStateImgView.image = [UIImage imageNamed:@"plv_icon_download_will"];
    
    cell.backgroundColor = self.tableView.backgroundColor;
    
    return cell;
}

#pragma mark -- UITableViewDelegate --
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 播放本地缓存视频
    PLVVodDownloadInfo *info = self.downloadInfos[indexPath.row].downloadInfo;
    
    // 播放本地加密/非加密视频
    PLVVodPlaybackMode playMode;
    if (info.fileType == PLVDownloadFileTypeAudio){
        playMode = PLVVodPlaybackModeAudio;
    }
    else {
        playMode = PLVVodPlaybackModeVideo;
    }
    
#ifndef PLVSupportPPTScreen
     //普通视频播放页面入口
     PLVSimpleDetailController *detailVC = [[PLVSimpleDetailController alloc] init];
     detailVC.vid = info.vid;            // vid
     detailVC.isOffline = YES;           // 离线播放
     detailVC.playMode = playMode;       // 根据本地资源类型设置播放模式
#else
    
    // 三分屏模式视频播放页面入口
    PLVPPTSimpleDetailController *detailVC = [[PLVPPTSimpleDetailController alloc] init];
    detailVC.vid = info.vid;
    detailVC.isOffline = YES;           // 离线播放
    detailVC.playbackMode = playMode;       // 根据本地资源类型设置播放模式
    
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:detailVC animated:YES];
    });
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
    PLVDownloadCompleteInfoModel *localModel = self.downloadInfos[indexPath.row];
    
#ifndef PLVSupportDownloadAudio
    [downloadManager removeDownloadWithVid:localModel.downloadInfo.vid error:nil];
#else
    // 使用音频下载功能的客户，调用如下方法
    PLVVodVideoParams *params = [PLVVodVideoParams videoParamsWithVid:localModel.downloadInfo.vid
                                                             fileType:localModel.downloadInfo.fileType];
    [downloadManager removeDownloadWithVideoParams:params error:nil];
#endif
    
    
    [self.downloadInfos removeObject:localModel];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - util

+ (NSString *)formatFilesize:(NSInteger)filesize {
    return [NSByteCountFormatter stringFromByteCount:filesize countStyle:NSByteCountFormatterCountStyleFile];
}

+ (NSString *)timeFormatStringWithTime:(NSTimeInterval )time{
    
    NSInteger hour = time/60/60;
    NSInteger minite = (time - hour*60*60)/60;
    NSInteger second = (time - hour*60*60 - minite*60);
    
    NSString *timeStr =[NSString stringWithFormat:@"%02d:%02d:%02d", (int)hour, (int)minite,(int)second];
    
    return timeStr;
}

@end
