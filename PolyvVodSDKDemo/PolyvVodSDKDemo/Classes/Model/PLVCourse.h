//
//  PLVCourse.h
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/13.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PLVCourseType) {
	PLVCourseTypeUnknown,
	PLVCourseTypeVod,
	PLVCourseTypeLive,
	PLVCourseTypeOther
};

@interface PLVCourse : NSObject

/// course_id 该网校下课程唯一标识
@property (nonatomic, copy) NSString *courseId;

/// category_id 课程分类ID
@property (nonatomic, copy) NSString *categoryId;

/// course_type 课程类型
@property (nonatomic, assign) PLVCourseType type;

/// title 课程标题
@property (nonatomic, copy) NSString *title;

/// subtitle 课程副标题
@property (nonatomic, copy) NSString *subtitle;

/// summary 课程概要
@property (nonatomic, copy) NSString *summary;

/// cover_image 课程的封面图片
@property (nonatomic, copy) NSString *coverUrl;

/// price 课程价格
@property (nonatomic, assign) double price;

/// is_free 是否免费
@property (nonatomic, assign) BOOL free;

/// is_free_vip VIP学员能否免费
@property (nonatomic, assign) BOOL freeForVip;

/// is_recommended 该课程是否教师推荐的
@property (nonatomic, assign) BOOL recommended;

/// validity 有效期（天）
@property (nonatomic, assign) NSInteger validity;

@end
