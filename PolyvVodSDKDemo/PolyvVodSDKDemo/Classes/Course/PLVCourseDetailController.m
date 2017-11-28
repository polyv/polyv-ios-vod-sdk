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
#import <NinaPagerView/NinaPagerView.h>

@interface PLVCourseDetailController ()

//@property (weak, nonatomic) IBOutlet DLCustomSlideView *pageView;
@property (nonatomic, strong) NSArray *subViewControllers;

@property (nonatomic, strong) NinaPagerView *ninaPagerView;
@property (weak, nonatomic) IBOutlet UIView *playerView;

@end

@implementation PLVCourseDetailController

#pragma mark - property

- (NSArray *)subViewControllers {
	if (!_subViewControllers) {
		PLVCourseVideoListController *courseVideoList = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVCourseVideoListController"];
		PLVCourseIntroductionController *courseIntro = [self.storyboard instantiateViewControllerWithIdentifier:@"PLVCourseIntroductionController"];
		_subViewControllers = @[courseVideoList, courseIntro];
		NSLog(@"subview: %@", _subViewControllers);
	}
	return _subViewControllers;
}

- (NinaPagerView *)ninaPagerView {
	if (!_ninaPagerView) {
		NSArray *titleArray = @[@"课时目录", @"课程介绍"];
		NSArray *vcsArray = self.subViewControllers;
		CGFloat width = self.view.bounds.size.width;
		CGFloat y = CGRectGetMaxY(self.playerView.frame);
		CGRect pagerRect = CGRectMake(0, y, width, 44);
		_ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithVCs:vcsArray];
		
		_ninaPagerView.ninaPagerStyles = NinaPagerStyleStateNormal;
	}
	return _ninaPagerView;
}

//- (void)setCourse:(PLVCourse *)course {
//	_course = course;
//
//
//}
- (IBAction)test:(UIBarButtonItem *)sender {
	[self.navigationController pushViewController:self.subViewControllers[0] animated:YES];
	
}

#pragma mark - view controller

- (void)viewDidLoad {
    [super viewDidLoad];
	self.automaticallyAdjustsScrollViewInsets = NO;
	
//	NSArray *titles = @[@"课时目录", @"课程介绍"];
//	[self.ninaPagerView reloadTopTabByTitles:titles WithObjects:self.subViewControllers];
//	self.ninaPagerView.ninaPagerStyles = NinaPagerStyleBottomLine;
	
	
	
	__weak typeof(self) weakSelf = self;
	[PLVCourseNetworking requestCourseVideosWithCourseId:self.course.courseId completion:^(NSArray *videoSections) {
		PLVCourseVideoListController *courseVideoList = weakSelf.subViewControllers[0];
		courseVideoList.videoSections = videoSections;
		dispatch_async(dispatch_get_main_queue(), ^{
			[courseVideoList.tableView reloadData];
//			[weakSelf presentViewController:weakSelf.subViewControllers[0] animated:YES completion:^{
//
//			}];
		});
	}];
	
	UIColor *themeColor = [UIColor colorWithHue:0.574 saturation:0.864 brightness:0.953 alpha:1.000];
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

@end
