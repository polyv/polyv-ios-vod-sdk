//
//  PLVCourseNetworking.h
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLVSchool;
@class PLVCourse;
@class PLVTeacher;

@interface PLVCourseNetworking : NSObject

/// 请求课程列表
+ (void)requestCoursesWithCompletion:(void (^)(NSArray<PLVCourse *> *courses))completion;

/// 获取教师列表
+ (void)requestTeachersWithCourseId:(NSString *)courseId completion:(void (^)(NSArray<PLVTeacher *> *teachers))completion;

@end
