//
//  PLVTeacher.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/13.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVTeacher.h"

@implementation PLVTeacher

/// 初始化
- (instancetype)initWithDic:(NSDictionary *)dic {
	if (self = [super init]) {
		_teacherId = dic[@"teacherId"];
		_name = dic[@"teacherName"];
		_avatar = dic[@"teacherAvatar"];
	}
	return self;
}

@end
