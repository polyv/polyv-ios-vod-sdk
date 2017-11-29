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

@interface PLVCourseDetailController ()

//@property (weak, nonatomic) IBOutlet DLCustomSlideView *pageView;
@property (nonatomic, strong) NSArray *subViewControllers;

@property (weak, nonatomic) IBOutlet UIView *playerView;

@end

@implementation PLVCourseDetailController

#pragma mark - property

- (NSArray *)subViewControllers {
	if (!_subViewControllers) {
		PLVCourseVideoListController *courseVideoList = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVCourseVideoListController"];
		PLVCourseIntroductionController *courseIntro = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVCourseIntroductionController"];
		_subViewControllers = @[courseVideoList, courseIntro];
	}
	return _subViewControllers;
}

//- (NinaPagerView *)ninaPagerView {
//	if (!_ninaPagerView) {
//		NSArray *titleArray = @[@"课时目录", @"课程介绍"];
//		NSArray *vcsArray = self.subViewControllers;
//		CGFloat width = self.view.bounds.size.width;
//		CGFloat y = CGRectGetMaxY(self.playerView.frame);
//		CGRect pagerRect = CGRectMake(0, y, width, 44);
//		_ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithVCs:vcsArray];
//
//		_ninaPagerView.ninaPagerStyles = NinaPagerStyleStateNormal;
//	}
//	return _ninaPagerView;
//}

//- (void)setCourse:(PLVCourse *)course {
//	_course = course;
//
//
//}
- (IBAction)test:(UIBarButtonItem *)sender {
	[self.navigationController pushViewController:self.subViewControllers[0] animated:YES];
	
}
- (IBAction)test2:(id)sender {
	[self.navigationController pushViewController:self.subViewControllers[1] animated:YES];
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
		PLVCourseVideoListController *courseVideoList = weakSelf.subViewControllers[0];
		courseVideoList.videoSections = videoSections;
		dispatch_async(dispatch_get_main_queue(), ^{
			[courseVideoList.tableView reloadData];
		});
	}];
	[self setupUI];
	
	
//	[self.view addSubview:self.ninaPagerView];
	
//	DLScrollTabbarView *tabbar = [[DLScrollTabbarView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
//	tabbar.tabItemNormalColor = [UIColor blackColor];
//	tabbar.tabItemSelectedColor = themeColor;
//	tabbar.tabItemNormalFontSize = 14.0f;
//	tabbar.trackColor = themeColor;
//
//	CGFloat itemWidth = width/2;
//	DLScrollTabbarItem *item0 = [DLScrollTabbarItem itemWithTitle:@"课时目录" width:itemWidth];
//	DLScrollTabbarItem *item1 = [DLScrollTabbarItem itemWithTitle:@"课程介绍" width:itemWidth];
//	tabbar.tabbarItems = @[item0, item1];
	
//	self.pageView.cache = [[DLLRUCache alloc] initWithCount:6];
//	self.pageView.tabbar = tabbar;
//	self.pageView.baseViewController = self;
//	self.pageView.delegate = self;
//	[self.pageView setup];
//	self.pageView.selectedIndex = 0;
}

- (void)setupUI {
	self.title = self.course.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - sppage

- (UIColor *)titleHighlightColorForIndex:(NSInteger)index {
	UIColor *themeColor = [UIColor colorWithHue:0.574 saturation:0.864 brightness:0.953 alpha:1.000];
	return themeColor;
}

- (UIColor *)markViewColorForIndex:(NSInteger)index {
	UIColor *themeColor = [UIColor colorWithHue:0.574 saturation:0.864 brightness:0.953 alpha:1.000];
	return themeColor;
}

- (CoverScrollStyle)preferCoverStyle {
	return CoverScrollStyleTop;
}

- (BOOL)needMarkView {
	return YES;
}

- (UIView *)preferCoverView {
	return self.playerView;
}

- (CGRect)preferCoverFrame {
	return self.playerView.frame;
}

- (CGFloat)preferTabY {
	return CGRectGetMaxY(self.playerView.frame);
}

- (CGRect)preferPageFrame {
	CGFloat y = CGRectGetMaxY(self.playerView.frame) + 40;
	CGFloat height = self.view.bounds.size.height - y;
	CGFloat width = self.view.bounds.size.width;
	return CGRectMake(0, y, width, height);
}

- (BOOL)isPreLoad {
	return YES;
}

- (NSInteger)numberOfControllers {
	return self.subViewControllers.count;
}

- (NSString *)titleForIndex:(NSInteger)index {
	UIViewController *vc = self.subViewControllers[index];
	return vc.title;
}

- (UIViewController *)controllerAtIndex:(NSInteger)index {
	return self.subViewControllers[index];
}

@end
