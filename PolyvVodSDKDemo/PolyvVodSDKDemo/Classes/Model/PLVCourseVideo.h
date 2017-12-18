//
//  PLVCourseVideo.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVCourseVideo : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) double duration;
@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *snapshot;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
