//
//  PLVCourseBannerReusableView.h
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/15.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVCourse.h"

@interface PLVCourseBannerReusableView : UICollectionReusableView

@property (nonatomic, strong) NSArray *bannerCourses;
@property (nonatomic, copy) void (^courseDidClick)(PLVCourse *course);

@end
