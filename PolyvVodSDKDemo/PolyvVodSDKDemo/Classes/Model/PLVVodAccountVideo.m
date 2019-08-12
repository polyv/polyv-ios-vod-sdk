//
//  PLVVodAccountVideo.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/14.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodAccountVideo.h"

@interface PLVVodAccountVideo ()

@end

@implementation PLVVodAccountVideo

- (instancetype)initWithDic:(NSDictionary *)dic {
	if (self = [super init]) {
		_filesizes = dic[@"filesize"];
		_snapshot = dic[@"first_image"];
		_cataid = dic[@"cataid"];
		_cataname = dic[@"cataname"];
		_vid = dic[@"vid"];
		_title = dic[@"title"];
		_status = [dic[@"status"] integerValue];
		_duration = [self.class secondsWithtimeString:dic[@"duration"]];
	}
	return self;
}

/// 字符串转时间
+ (NSTimeInterval)secondsWithtimeString:(NSString *)timeString {
	NSArray *timeComponents = [timeString componentsSeparatedByString:@":"];
	NSTimeInterval seconds = 0;
	int componentCount = 3;
	if (timeComponents.count < componentCount) {
		componentCount = (int)timeComponents.count;
	}
	for (int i = 0; i < componentCount; i++) {
		NSInteger timeComponent = [timeComponents[i] integerValue];
		seconds += pow(60, componentCount-1-i) * timeComponent;
	}
	return seconds;
}

@end
