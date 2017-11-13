//
//  PLVCourse.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/13.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourse.h"
#import "PLVCourseNetworking.h"

@implementation PLVCourse

+ (void)requestCoursesWithCompletion:(void (^)(NSArray<PLVCourse *> *courses))completion {
	[PLVCourseNetworking requestCoursesWithCompletion:^(NSArray *courses) {
		NSMutableArray *courseModels = [NSMutableArray array];
		for (NSDictionary *dic in courses) {
			[courseModels addObject:[[self alloc] initWithDic:dic]];
		}
		if (completion) completion(courseModels);
	}];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
	if (self = [super init]) {
		_courseId = dic[@"course_id"];
		_categoryId = dic[@"category_id"];
		
		NSString *courseType = dic[@"course_type"];
		courseType = courseType.uppercaseString;
		if ([courseType isEqualToString:@"VOD"]) {
			_type = PLVCourseTypeVod;
		} else if ([courseType isEqualToString:@"LIVE"]) {
			_type = PLVCourseTypeLive;
		} else if (courseType.length > 0) {
			_type = PLVCourseTypeOther;
		} else {
			_type = PLVCourseTypeUnknown;
		}
		
		_title = dic[@"title"];
		_subtitle = dic[@"subtitle"];
		_summary = dic[@"summary"];
		_coverUrl = dic[@"cover_image"];
		_price = [dic[@"price"] doubleValue];
		_free = [dic[@"is_free"] boolValue];
		_freeForVip = [dic[@"is_free_vip"] boolValue];
		_recommended = [dic[@"is_recommended"] boolValue];
		_validity = [dic[@"validity"] integerValue];
	}
	return self;
}

@end
