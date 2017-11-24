//
//  PLVCourse.h
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/13.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVTeacher.h"

typedef NS_ENUM(NSInteger, PLVCourseType) {
	PLVCourseTypeUnknown,
	PLVCourseTypeVod,
	PLVCourseTypeLive,
	PLVCourseTypeOther
};

@interface PLVCourse : NSObject

/// 该网校下课程唯一标识
@property (nonatomic, copy) NSString *courseId;

/// 课程分类ID
@property (nonatomic, copy) NSString *categoryId;

/// 课程类型
@property (nonatomic, assign) PLVCourseType type;

/// 课程标题
@property (nonatomic, copy) NSString *title;

/// 课程的封面图片
@property (nonatomic, copy) NSString *coverUrl;

/// 课程价格
@property (nonatomic, assign) double price;

/// 是否免费
@property (nonatomic, assign) BOOL free;

/// VIP学员能否免费
@property (nonatomic, assign) BOOL freeForVip;

/// 有效期（天）
@property (nonatomic, assign) NSInteger validity;

/// 学生人数
@property (nonatomic, assign) NSInteger studentCount;

/// 课程描述
@property (nonatomic, copy) NSString *courseDescription;

/// 教师
@property (nonatomic, strong) PLVTeacher *teacher;

/// 初始化
- (instancetype)initWithDic:(NSDictionary *)dic;

@end
