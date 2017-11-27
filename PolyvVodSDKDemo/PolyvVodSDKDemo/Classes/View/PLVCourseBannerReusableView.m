//
//  PLVCourseBannerReusableView.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/15.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseBannerReusableView.h"
#import <XRCarouselView/XRCarouselView.h>

@interface PLVCourseBannerReusableView ()<XRCarouselViewDelegate>

@property (nonatomic, strong) XRCarouselView *carouseView;

@end

@implementation PLVCourseBannerReusableView

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setupUI];
	}
	return self;
}

- (void)setupUI {
	self.carouseView = [[XRCarouselView alloc] initWithFrame:self.bounds];
	self.carouseView.delegate = self;
	[self addSubview:self.carouseView];
}

#pragma mark - property

- (void)setBannerCourses:(NSArray *)bannerCourses {
	_bannerCourses = bannerCourses;
	if (!bannerCourses.count) {
		return;
	}
	NSMutableArray *imageArray = [NSMutableArray array];
	for (PLVCourse *course in self.bannerCourses) {
		NSString *imageUrl = course.coverUrl;
		if (imageUrl.length) {
			[imageArray addObject:imageUrl];
		}
	}
	self.carouseView.placeholderImage = [UIImage imageNamed:@"plv_ph_courseCover"];
	self.carouseView.imageArray = imageArray;
}

#pragma mark - XRCarouselViewDelegate

- (void)carouselView:(XRCarouselView *)carouselView clickImageAtIndex:(NSInteger)index {
	if (!(index >= 0 && index < self.bannerCourses.count)) {
		return;
	}
	PLVCourse *course = self.bannerCourses[index];
	if (self.courseDidClick) self.courseDidClick(course);
}

@end
