//
//  PLVAccountVideoListController.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVAccountVideoListController.h"
#import "PLVCourseNetworking.h"
#import "PLVVodAccountVideo.h"
#import "PLVVideoCell.h"
#import "PLVVodSkinPlayerController.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "UIColor+PLVVod.h"

@interface PLVAccountVideoListController ()

@property (nonatomic, strong) NSArray<PLVVodAccountVideo *> *accountVideos;

@end

@implementation PLVAccountVideoListController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self requestData];
	
	self.tableView.backgroundColor = [UIColor themeBackgroundColor];
	self.tableView.tableFooterView = [UIView new];
}

- (void)requestData {
	__weak typeof(self) weakSelf = self;
	[PLVCourseNetworking requestAccountVideoWithPageCount:99 page:1 completion:^(NSArray<PLVVodAccountVideo *> *accountVideos) {
		weakSelf.accountVideos = accountVideos;
		dispatch_async(dispatch_get_main_queue(), ^{
			[weakSelf.tableView reloadData];
		});
	}];
}

- (UIView *)emptyView {
	UIButton *emptyButton = [UIButton buttonWithType:UIButtonTypeSystem];
	emptyButton.showsTouchWhenHighlighted = YES;
	emptyButton.tintColor = [UIColor themeColor];
	[emptyButton setTitle:@"暂无数据，点击重试" forState:UIControlStateNormal];
	[emptyButton addTarget:self action:@selector(requestData) forControlEvents:UIControlEventTouchUpInside];
	return emptyButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger number = self.accountVideos.count;
	tableView.backgroundView = number ? nil : [self emptyView];
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVVideoCell *cell = (PLVVideoCell *)[tableView dequeueReusableCellWithIdentifier:[PLVVideoCell identifier] forIndexPath:indexPath];
	cell.video = self.accountVideos[indexPath.row];
	__weak typeof(self) weakSelf = self;
	cell.playButtonAction = ^(PLVVideoCell *cell, UIButton *sender) {
		PLVVodAccountVideo *accountVideo = cell.video;
		NSString *vid = accountVideo.vid;
		if (!vid.length) return;
		[PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
			[weakSelf playVideo:video];
		}];
	};
	cell.downloadButtonAction = ^(PLVVideoCell *cell, UIButton *sender) {
		PLVVodAccountVideo *accountVideo = cell.video;
		NSString *vid = accountVideo.vid;
		if (!vid.length) return;
		[PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
			[weakSelf downloadVideo:video];
		}];
	};
	cell.backgroundColor = self.tableView.backgroundColor;
	
    return cell;
}

- (void)playVideo:(PLVVodVideo *)video {
	PLVVodSkinPlayerController *player = [[PLVVodSkinPlayerController alloc] init];
	player.video = video;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.navigationController pushViewController:player animated:YES];
	});
}
- (void)downloadVideo:(PLVVodVideo *)video {
	PLVVodDownloadInfo *info = [[PLVVodDownloadManager sharedManager] downloadVideo:video];
	if (info) NSLog(@"%@ - %zd 已加入下载队列", info.video.vid, info.quality);
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
