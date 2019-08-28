//
//  PLVCourseNetworking.h
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLVCourse;
@class PLVVodAccountVideo;

@interface PLVCourseNetworking : NSObject

/// 请求课程列表
+ (void)requestCoursesWithCompletion:(void (^)(NSArray<PLVCourse *> *courses))completion;

/// 获取课程课时
+ (void)requestCourseVideosWithCourseId:(NSString *)courseId completion:(void (^)(NSArray *videoSections))completion;

/// 请求账户下的视频列表
+ (void)requestAccountVideoWithPageCount:(NSInteger)pageCount page:(NSInteger)page completion:(void (^)(NSArray<PLVVodAccountVideo *> *accountVideos))completion;

@end
