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
	[downloadManager requestDownloadInfosWithCompletion:^(NSArray<PLVVodDownloadInfo *> *downloadInfos) {
		dispatch_async(dispatch_get_main_queue(), ^{
			weakSelf.downloadInfos = downloadInfos.mutableCopy;
			[weakSelf.tableView reloadData];
		});
	}];
	
	downloadManager.completeBlock = ^{
		dispatch_async(dispatch_get_main_queue(), ^{
			weakSelf.queueDownloadButton.selected = NO;
		});
	};
	
	self.tableView.backgroundColor = [UIColor themeBackgroundColor];
	self.tableView.tableFooterView = [UIView new];
	
	self.toolbar.buttons = @[self.queueDownloadButton];
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
	UILabel *emptyLabel = [[UILabel alloc] init];
	emptyLabel.text = @"暂无缓存视频";
	emptyLabel.textAlignment = NSTextAlignmentCenter;
	self.emptyView = emptyLabel;
	
	[PLVVodDownloadManager sharedManager].downloadErrorHandler = ^(PLVVodVideo *video, NSError *error) {
		NSLog(@"download error: %@\n%@", video, error);
	};
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
		info.stateDidChangeBlock = ^(PLVVodDownloadInfo *info) {
			PLVLoadCell *cell = weakSelf.downloadItemCellDic[info.vid];
			dispatch_async(dispatch_get_main_queue(), ^{
				cell.downloadStateLabel.text = NSStringFromPLVVodDownloadState(info.state);
				cell.state = info.state == PLVVodDownloadStateSuccess ? PLVLoadCellStateCompleted : PLVLoadCellStateProcessing;
			});
		};
		info.progressDidChangeBlock = ^(PLVVodDownloadInfo *info) {
			//NSLog(@"vid: %@, progress: %f", info.vid, info.progress);
			PLVLoadCell *cell = weakSelf.downloadItemCellDic[info.vid];
			dispatch_async(dispatch_get_main_queue(), ^{
				cell.downloadProgressView.progress = info.progress;
			});
		};
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
	sender.selected = !sender.selected;
	PLVVodDownloadManager *downloadManager = [PLVVodDownloadManager sharedManager];
	if (sender.selected) {
		[downloadManager startDownload];
	} else {
		[downloadManager stopDownload];
	}
}

- (IBAction)refreshDownloadState:(UIBarButtonItem *)sender {
	[self.tableView reloadData];
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
	cell.thumbnailUrl = video.snapshot;
	cell.titleLabel.text = video.title;
	NSInteger filesize = [video.filesizes[info.quality-1] integerValue];
	cell.videoSizeLabel.text = [self.class formatFilesize:filesize];
	
	__weak typeof(info) _downloadInfo = info;
	cell.downloadButtonAction = ^(PLVLoadCell *cell, UIButton *sender) {
		sender.selected = _downloadInfo.state == PLVVodDownloadStateRunning;
		//PLVVodDownloadManager *downloadManager = [PLVVodDownloadManager sharedManager];
		if (_downloadInfo.state == PLVVodDownloadStateRunning) {
			//[downloadManager stopDownload];
		} else {
			//[downloadManager startDownload];
		}
	};
	cell.backgroundColor = self.tableView.backgroundColor;
	
    return cell;
}

/// 删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	PLVVodDownloadManager *manager = [PLVVodDownloadManager sharedManager];
	PLVVodDownloadInfo *downloadInfo = self.downloadInfos[indexPath.row];
	[manager removeDownloadWithVid:downloadInfo.video.vid error:nil];
	[self.downloadInfos removeObject:downloadInfo];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - util

+ (NSString *)formatFilesize:(NSInteger)filesize {
	return [NSByteCountFormatter stringFromByteCount:filesize countStyle:NSByteCountFormatterCountStyleFile];
}

@end
