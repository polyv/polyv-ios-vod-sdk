//
//  PLVTeacher.h
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/13.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVTeacher : NSObject

/// 教师唯一编号标识
@property (nonatomic, copy) NSString *teacherId;

/// 教师昵称
@property (nonatomic, copy) NSString *name;

/// 教师头像地址
@property (nonatomic, copy) NSString *avatar;

/// 初始化
- (instancetype)initWithDic:(NSDictionary *)dic;

@end
