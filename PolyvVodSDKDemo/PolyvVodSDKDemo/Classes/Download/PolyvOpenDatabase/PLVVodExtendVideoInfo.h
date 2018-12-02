//
//  PLVVodExtendVideoInfo.h
//  _PolyvVodSDK
//
//  Created by mac on 2018/10/15.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVVodExtendVideoInfo : NSObject

@property (nonatomic, copy) NSString *vid;

/// 以下可自定义字段
@property(nonatomic, assign) NSString *CusCatagoryID; // 课程分类ID
@property(nonatomic, copy) NSString *CusCatagoryName; // 课程分类名称

@property(nonatomic, assign) NSString *CusCourseID; // 课程id
@property(nonatomic, copy) NSString *CusCourseName; // 课程名称


@end
