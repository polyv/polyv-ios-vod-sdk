//
//  PLVCourseVideoListController.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseVideoListController.h"
#import "PLVVideoCell.h"
#import "UIColor+PLVVod.h"
#import "PLVToolbar.h"

@interface PLVCourseVideoListController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet PLVToolbar *toolbar;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, assign) BOOL selecting;

@end

@implementation PLVCourseVideoListController

#pragma mark - property

- (UIButton *)downloadButton {
	if (!_downloadButton) {
		_downloadButton = [PLVToolbar buttonWithTitle:@"缓存" image:[UIImage imageNamed:@"plv_btn_cache"]];
		[_downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _downloadButton;
}

- (UIButton *)cancelButton {
	if (!_cancelButton) {
		_cancelButton = [PLVToolbar buttonWithTitle:@"取消" image:nil];
		[_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _cancelButton;
}

- (UIButton *)confirmButton {
	if (!_confirmButton) {
		_confirmButton = [PLVToolbar buttonWithTitle:@"确认缓存" image:nil];
		[_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _confirmButton;
}

#pragma mark - view controller

- (void)viewDidLoad {
    [super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.tableView.tableFooterView = [UIView new];
	self.tableView.tableHeaderView = [UIView new];
	
	self.tableView.backgroundColor = [UIColor themeBackgroundColor];
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
	
	self.toolbar.buttons = @[self.downloadButton];
}

- (void)downloadButtonAction:(UIButton *)sender {
	//self.selecting = sender.selected = !sender.isSelected;
	self.selecting = YES;
	[self.tableView setEditing:YES animated:YES];
	
	self.toolbar.buttons = @[self.cancelButton, self.confirmButton];
}

- (void)cancelButtonAction:(UIButton *)sender {
	[self.tableView setEditing:NO animated:YES];
	self.toolbar.buttons = @[self.downloadButton];
	self.selecting = NO;
}

- (void)confirmButtonAction:(UIButton *)sender {
	// 下载视频
	for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
		NSString *vid = self.videoSections[indexPath.section].videos[indexPath.row].vid;
        [PLVVodVideo requestVideoPriorityCacheWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
            [[PLVVodDownloadManager sharedManager] downloadVideo:video];
        }];
	}
	[self.tableView setEditing:NO animated:YES];
	self.toolbar.buttons = @[self.downloadButton];
	self.selecting = NO;
}

- (void)selectRowWithIndex:(NSInteger)index {
	NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView selectRowAtIndexPath:firstIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
	[self tableView:self.tableView didSelectRowAtIndexPath:firstIndexPath];
}


#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger number = self.videoSections.count;
	return number;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger number = self.videoSections[section].videos.count;
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLVVideoCell" forIndexPath:indexPath];
	cell.video = self.videoSections[indexPath.section].videos[indexPath.row];
	cell.backgroundColor = self.tableView.backgroundColor;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.videoSections[section].title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.selecting) {
		return;
	}
	//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	//cell.selected = NO;
	PLVCourseVideo *courseVideo = self.videoSections[indexPath.section].videos[indexPath.row];
	__weak typeof(self) weakSelf = self;
	[courseVideo requestVodVideoWithCompletion:^(PLVVodVideo *vodVideo) {
		if (weakSelf.videoDidSelect) weakSelf.videoDidSelect(vodVideo);
	}];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
