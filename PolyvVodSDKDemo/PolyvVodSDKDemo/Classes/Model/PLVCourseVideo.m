//
//  PLVCourseVideo.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseVideo.h"

@implementation PLVCourseVideo

- (instancetype)initWithDic:(NSDictionary *)dic {
	if (self = [super init]) {
		_title = dic[@"title"];
		_duration = [dic[@"videoDuration"] doubleValue];
		_vid = dic[@"videoId"];
		_snapshot = dic[@"videoCoverImage"];
	}
	return self;
}

@end
