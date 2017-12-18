//
//  PLVCourseVideoListController.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseVideoListController.h"
#import "PLVVideoCell.h"

@interface PLVCourseVideoListController ()

@end

@implementation PLVCourseVideoListController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	self.tableView.tableFooterView = [UIView new];
	self.tableView.tableHeaderView = [UIView new];
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
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.videoSections[section].title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	//cell.selected = NO;
	PLVCourseVideo *courseVideo = self.videoSections[indexPath.section].videos[indexPath.row];
	__weak typeof(self) weakSelf = self;
	[courseVideo requestVodVideoWithCompletion:^(PLVVodVideo *vodVideo) {
		if (weakSelf.videoDidSelect) weakSelf.videoDidSelect(vodVideo);
	}];
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
