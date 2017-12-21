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
@property (nonatomic, strong) NSArray<PLVVodDownloadInfo *> *downloadInfos;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.downloadInfos = [PLVVodDownloadManager sharedManager].downloadInfos;
	
	self.tableView.backgroundColor = [UIColor themeBackgroundColor];
	self.tableView.tableFooterView = [UIView new];
	
//	__weak typeof(self) weakSelf = self;
//	self.timer = [PLVTimer repeatWithInterval:2 repeatBlock:^{
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[weakSelf.tableView reloadData];
//		});
//		if (!weakSelf.downloadInfos.count) {
//			[weakSelf.timer cancel];
//		}
//	}];
	
	self.toolbar.buttons = @[self.queueDownloadButton];
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
	UILabel *emptyLabel = [[UILabel alloc] init];
	emptyLabel.text = @"暂无缓存视频";
	emptyLabel.textAlignment = NSTextAlignmentCenter;
	self.emptyView = emptyLabel;
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

#pragma mark - property

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger number = self.downloadInfos.count;
	self.tableView.backgroundView = number ? nil : self.emptyView;
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVLoadCell *cell = (PLVLoadCell *)[tableView dequeueReusableCellWithIdentifier:[PLVLoadCell identifier] forIndexPath:indexPath];
	
	PLVVodDownloadInfo *downloadInfo = self.downloadInfos[indexPath.row];
	PLVVodVideo *video = downloadInfo.video;
	cell.thumbnailUrl = video.snapshot;
	cell.titleLabel.text = video.title;
	cell.videoSizeLabel.text = [NSByteCountFormatter stringFromByteCount:[video.filesizes[downloadInfo.quality-1] longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
	cell.downloadStateLabel.text = NSStringFromPLVVodDownloadState(downloadInfo.state);
	cell.downloadProgressView.progress = downloadInfo.progress;
	NSString *speedString = [NSByteCountFormatter stringFromByteCount:downloadInfo.bytesPerSeconds countStyle:NSByteCountFormatterCountStyleFile];
	speedString = [speedString stringByAppendingFormat:@"/s"];
	cell.downloadSpeedLabel.text = speedString;
	__weak typeof(downloadInfo) _downloadInfo = downloadInfo;
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
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
