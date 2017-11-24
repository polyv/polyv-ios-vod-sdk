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

- (instancetype)initWithDic:(NSDictionary *)dic {
	if (self = [super init]) {
		_courseId = dic[@"courseId"];
		_categoryId = dic[@"categoryId"];
		
		NSString *courseType = dic[@"courseMeth"];
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
		_coverUrl = dic[@"coverImage"];
		_price = [dic[@"price"] doubleValue];
		_free = [dic[@"isFree"] boolValue];
		_freeForVip = [dic[@"isFreeVip"] boolValue];
		_validity = [dic[@"validity"] integerValue];
		_courseDescription = dic[@"description"];
		_studentCount = [dic[@"studentCount"] integerValue];
		_teacher = [[PLVTeacher alloc] initWithDic:dic];
	}
	return self;
}

@end
