//
//  PLVCourseDetailController.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseDetailController.h"
#import "PLVCourseVideoListController.h"
#import "PLVCourseIntroductionController.h"
#import "PLVCourseNetworking.h"
#import "PLVCourseSection.h"
#import "DLTabedSlideView.h"
#import "PLVVodSkinPlayerController.h"
#import "UIView+PLVVod.h"

@interface PLVCourseDetailController ()<DLTabedSlideViewDelegate>

@property (nonatomic, strong) NSArray *subViewControllers;

@property (weak, nonatomic) IBOutlet UIView *playerPlaceholder;
@property (nonatomic, strong) PLVVodSkinPlayerController *player;

@property (weak, nonatomic) IBOutlet DLTabedSlideView *tabedSlideView;

@end

@implementation PLVCourseDetailController

- (void)dealloc {
	NSLog(@"%s - %@", __FUNCTION__, [NSThread currentThread]);
}

#pragma mark - property

- (NSArray *)subViewControllers {
	if (!_subViewControllers) {
		PLVCourseVideoListController *courseVideoList = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVCourseVideoListController"];
		PLVCourseIntroductionController *courseIntro = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVCourseIntroductionController"];
		_subViewControllers = @[courseVideoList, courseIntro];
	}
	return _subViewControllers;
}

#pragma mark - view controller

- (void)viewDidLoad {
    [super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	PLVCourseIntroductionController *intro = self.subViewControllers[1];
	intro.htmlContent = self.course.courseDescription;
	//NSLog(@"desc: %@", intro.htmlContent);
	__weak typeof(self) weakSelf = self;
	[PLVCourseNetworking requestCourseVideosWithCourseId:self.course.courseId completion:^(NSArray *videoSections) {
		if (!videoSections.count) return;
		PLVCourseVideoListController *courseVideoList = weakSelf.subViewControllers[0];
		courseVideoList.videoSections = videoSections;
		dispatch_async(dispatch_get_main_queue(), ^{
			[courseVideoList.tableView reloadData];
			// 自动播放第一项
			[courseVideoList selectRowWithIndex:0];
		});
	}];
	[self setupUI];
	
	// setup slide view
	self.tabedSlideView.delegate = self;
	self.tabedSlideView.baseViewController = self;
	UIColor *themeColor = [UIColor colorWithHue:0.574 saturation:0.864 brightness:0.953 alpha:1.000];
	self.tabedSlideView.tabbarHeight = 44;
	self.tabedSlideView.tabItemNormalColor = [UIColor blackColor];
	self.tabedSlideView.tabItemSelectedColor = themeColor;
	self.tabedSlideView.tabbarTrackColor = themeColor;
	DLTabedbarItem *item0 = [DLTabedbarItem itemWithTitle:@"课程目录" image:nil selectedImage:nil];
	DLTabedbarItem *item1 = [DLTabedbarItem itemWithTitle:@"课程介绍" image:nil selectedImage:nil];
	self.tabedSlideView.tabbarItems = @[item0, item1];
	[self.tabedSlideView buildTabbar];
	self.tabedSlideView.selectedIndex = 0;
	
	PLVCourseVideoListController *courseVideoList = self.subViewControllers.firstObject;
	courseVideoList.videoDidSelect = ^(PLVVodVideo *video) {
		//NSLog(@"video: %@", video.title);
		weakSelf.player.video = video;
	};
}

- (void)setupUI {
	self.title = self.course.title;
	[self setupPlayer];
}

- (void)setupPlayer {
	self.player = [[PLVVodSkinPlayerController alloc] initWithNibName:nil bundle:nil];
	[self.player addPlayerOnView:self.view parentViewController:self];
//	CGFloat width = MIN(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
//	CGFloat height = width / 16 * 9;
//	self.player.view.frame = CGRectMake(0, 64, width, height);
//	[self.player updateUI];
}

- (void)viewLayoutMarginsDidChange {
	[super viewLayoutMarginsDidChange];
	//NSLog(@"margin: %@", NSStringFromUIEdgeInsets(self.view.layoutMargins));
	UIEdgeInsets layoutMargins = self.view.layoutMargins;
	UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		CGFloat width = MIN(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
		CGFloat height = width / 16 * 9;
		self.player.view.frame = CGRectMake(0, layoutMargins.top, width, height);
		[self.player updateUI];
	}
}

- (BOOL)prefersStatusBarHidden {
	return self.player.prefersStatusBarHidden;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
	return self.player.preferredStatusBarStyle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	id vc = segue.destinationViewController;
	if ([vc isKindOfClass:[PLVVodSkinPlayerController class]]) {
		self.player = vc;
	}
}

#pragma mark - DLTabedSlideViewDelegate

- (NSInteger)numberOfTabsInDLTabedSlideView:(DLTabedSlideView *)sender{
	return self.subViewControllers.count;
}
- (UIViewController *)DLTabedSlideView:(DLTabedSlideView *)sender controllerAt:(NSInteger)index{
	return self.subViewControllers[index];
}
@end
