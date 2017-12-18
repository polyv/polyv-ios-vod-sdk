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
	}
	return self;
}

- (void)requestVodVideoWithCompletion:(void (^)(PLVVodVideo *vodVideo))completion {
	if (self.vodVideo && completion) {
		completion(self.vodVideo);
		return;
	}
	__weak typeof(self) weakSelf = self;
	[PLVVodVideo requestVideoWithVid:self.vid completion:^(PLVVodVideo *video, NSError *error) {
		if (video) {
			weakSelf.vodVideo = video;
			if (completion) completion(video);
		}
	}];
}

@end
