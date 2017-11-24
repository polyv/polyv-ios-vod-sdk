//
//  PLVCourseCell.h
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/16.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVCourse.h"

static const CGSize PLVCourseCellPreferredContentSize = {160.0, 142.0};

@interface PLVCourseCell : UICollectionViewCell

@property (nonatomic, strong) PLVCourse *course;

@end
