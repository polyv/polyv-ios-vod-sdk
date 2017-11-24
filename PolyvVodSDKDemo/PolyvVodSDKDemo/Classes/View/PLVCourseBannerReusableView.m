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
	
	NSArray *arr = @[
					 @"http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",//网络图片
					 @"http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",//网络图片
					 @"http://photo.l99.com/source/11/1330351552722_cxn26e.gif",//网络gif图片
					 @"http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",//网络图片
					 ];
	self.carouseView.imageArray = arr;
}

@end
