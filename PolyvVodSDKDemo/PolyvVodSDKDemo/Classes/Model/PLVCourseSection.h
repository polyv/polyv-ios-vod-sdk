//
//  PLVCourseSection.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVCourseVideo.h"

@interface PLVCourseSection : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray<PLVCourseVideo *> *videos;

+ (NSArray<PLVCourseSection *> *)sectionsWithArray:(NSArray *)array;
@end
