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
    
    // 从本地文件目录中读取已缓存视频列表
    NSArray<PLVVodLocalVideo *> *localArray = [[PLVVodDownloadManager sharedManager] localVideos];
    
    // 从数据库中读取已缓存视频详细信息
    // TODO:也可以从开发者自定义数据库中读取数据,方便扩展
    NSArray<PLVVodDownloadInfo *> *dbInfos = [[PLVVodDownloadManager sharedManager] requestDownloadCompleteList];
    NSMutableDictionary *dbCachedDics = [[NSMutableDictionary alloc] init];
    [dbInfos enumerateObjectsUsingBlock:^(PLVVodDownloadInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [dbCachedDics setObject:obj forKey:obj.vid];
    }];

    // 组装数据
    // 以本地目录数据为准，因为数据库存在损坏的情形，会丢失数据，造成用户已缓存视频无法读取
    [localArray enumerateObjectsUsingBlock:^(PLVVodLocalVideo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PLVDownloadCompleteInfoModel *model = [[PLVDownloadCompleteInfoModel alloc] init];
        model.localVideo = obj;
        model.downloadInfo = dbCachedDics[obj.vid];
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
    PLVVodLocalVideo *localModel = self.downloadInfos[indexPath.row].localVideo;
    
    // 播放本地加密/非加密视频
    PLVSimpleDetailController *detailVC = [[PLVSimpleDetailController alloc] init];
    detailVC.localVideo = localModel;
    [self.navigationController pushViewController:detailVC animated:YES];
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
    PLVDownloadCompleteInfoModel *localVideo = self.downloadInfos[indexPath.row];
    
    [downloadManager removeDownloadWithVid:localVideo.localVideo.vid error:nil];
    [self.downloadInfos removeObject:localVideo];
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
