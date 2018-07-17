//
//  PLVDownloadListController.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVDownloadListController.h"
#import "PLVLoadCell.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "UIColor+PLVVod.h"
#import <PLVTimer/PLVTimer.h>
#import "PLVToolbar.h"
#import "PLVSimpleDetailController.h"

@interface PLVDownloadListController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet PLVToolbar *toolbar;

@property (nonatomic, strong) NSMutableArray<PLVVodDownloadInfo *> *downloadInfos;
@property (nonatomic, strong) NSDictionary<NSString *, PLVLoadCell *> *downloadItemCellDic;

@property (nonatomic, strong) PLVTimer *timer;

@property (nonatomic, strong) UIButton *queueDownloadButton;

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation PLVDownloadListController

- (UIButton *)queueDownloadButton {
	if (!_queueDownloadButton) {
		_queueDownloadButton = [PLVToolbar buttonWithTitle:@"队列下载" image:[UIImage imageNamed:@"plv_btn_cache"]];
		[_queueDownloadButton setTitle:@"停止下载" forState:UIControlStateSelected];
		[_queueDownloadButton addTarget:self action:@selector(queueDownloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _queueDownloadButton;
}

- (void)dealloc {
	[self.timer cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	__weak typeof(self) weakSelf = self;
	PLVVodDownloadManager *downloadManager = [PLVVodDownloadManager sharedManager];
	
	// 获取所有下载信息列表
	[downloadManager requestDownloadInfosWithCompletion:^(NSArray<PLVVodDownloadInfo *> *downloadInfos) {
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
	
//	// 下载错误回调
//	[PLVVodDownloadManager sharedManager].downloadErrorHandler = ^(PLVVodVideo *video, NSError *error) {
//		NSLog(@"download error: %@\n%@", video.vid, error);
//	};
	
	self.tableView.backgroundColor = [UIColor themeBackgroundColor];
	self.tableView.tableFooterView = [UIView new];
	self.tableView.allowsSelection = YES;
	
	self.toolbar.buttons = @[self.queueDownloadButton];
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
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
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[PLVLoadCell identifier]];
		downloadItemCellDic[info.vid] = cell;
	}
	self.downloadItemCellDic = downloadItemCellDic;
	
	// 设置回调
	__weak typeof(self) weakSelf = self;
	for (PLVVodDownloadInfo *info in downloadInfos) {
		// 下载状态改变回调
		info.stateDidChangeBlock = ^(PLVVodDownloadInfo *info) {
			PLVLoadCell *cell = weakSelf.downloadItemCellDic[info.vid];
			dispatch_async(dispatch_get_main_queue(), ^{
				cell.state = info.state == PLVVodDownloadStateSuccess ? PLVLoadCellStateCompleted : PLVLoadCellStateProcessing;
				cell.downloadStateLabel.text = NSStringFromPLVVodDownloadState(info.state);
				switch (info.state) {
					case PLVVodDownloadStateReady:
					case PLVVodDownloadStateStopped:
					case PLVVodDownloadStatePreparing:{
						cell.downloadStateLabel.textColor = [UIColor colorWithHex:0xE67E22];
					}break;
					case PLVVodDownloadStateRunning:
					case PLVVodDownloadStateStopping:
					case PLVVodDownloadStateSuccess:{
						cell.downloadStateLabel.textColor = [UIColor colorWithHex:0x7CB342];
					}break;
					case PLVVodDownloadStateFailed:{
						cell.downloadStateLabel.textColor = [UIColor redColor];
					}break;
				}
			});
		};
		// 下载进度回调
		info.progressDidChangeBlock = ^(PLVVodDownloadInfo *info) {
			//NSLog(@"vid: %@, progress: %f", info.vid, info.progress);
			PLVLoadCell *cell = weakSelf.downloadItemCellDic[info.vid];
			dispatch_async(dispatch_get_main_queue(), ^{
				cell.downloadProgressView.progress = info.progress;
			});
		};
		// 下载速率回调
		info.bytesPerSecondsDidChangeBlock = ^(PLVVodDownloadInfo *info) {
			PLVLoadCell *cell = weakSelf.downloadItemCellDic[info.vid];
			NSString *speedString = [NSByteCountFormatter stringFromByteCount:info.bytesPerSeconds countStyle:NSByteCountFormatterCountStyleFile];
			speedString = [speedString stringByAppendingFormat:@"/s"];
			dispatch_async(dispatch_get_main_queue(), ^{
				cell.downloadSpeedLabel.text = speedString;
			});
		};
	}
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
    //PLVLoadCell *cell = (PLVLoadCell *)[tableView dequeueReusableCellWithIdentifier:[PLVLoadCell identifier] forIndexPath:indexPath];
	PLVLoadCell *cell = self.downloadItemCellDic[info.vid];
	if (!cell) return nil;
	
	PLVVodVideo *video = info.video;
    if (video){
        cell.thumbnailUrl = video.snapshot;
        cell.titleLabel.text = video.title;
        NSInteger filesize = [video.filesizes[info.quality-1] integerValue];
        cell.videoSizeLabel.text = [self.class formatFilesize:filesize];
    }
	
	__weak typeof(info) _downloadInfo = info;
	cell.downloadButtonAction = ^(PLVLoadCell *cell, UIButton *sender) {
		sender.selected = _downloadInfo.state == PLVVodDownloadStateRunning;
		// *downloadManager = [PLVVodDownloadManager sharedManager];
		if (_downloadInfo.state == PLVVodDownloadStateRunning) {
			//[downloadManager stopDownload];
		} else {
			//[downloadManager startDownload];
		}
	};
	cell.backgroundColor = self.tableView.backgroundColor;
	
    return cell;
}

#pragma mark -- UITableViewDelegate --
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 播放本地缓存视频
    PLVVodDownloadInfo *info = self.downloadInfos[indexPath.row];
    if (info.state == PLVVodDownloadStateSuccess){
        
        //
        PLVVodVideo *videoModel = info.video;
        
        // 非加密
        PLVVodLocalVideo *localModel = nil;
        if (videoModel){
            localModel = [PLVVodLocalVideo localVideoWithVideo:videoModel dir:[PLVVodDownloadManager sharedManager].downloadDir];
        }
        
        if (!localModel){
            localModel = [PLVVodLocalVideo localVideoWithVid:info.vid dir:[PLVVodDownloadManager sharedManager].downloadDir];
        }
        
        if (localModel){
            // 播放本地加密/非加密视频
            PLVSimpleDetailController *detailVC = [[PLVSimpleDetailController alloc] init];
            detailVC.localVideo = localModel;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        else{
            
            // 在线播放
//            PLVSimpleDetailController *detailVC = [[PLVSimpleDetailController alloc] init];
//            detailVC.vid = info.vid;
//            [self.navigationController pushViewController:detailVC animated:YES];
        }
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

@end
