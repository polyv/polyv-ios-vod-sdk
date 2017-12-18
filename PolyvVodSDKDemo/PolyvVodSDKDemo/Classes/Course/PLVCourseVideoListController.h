//
//  PLVCourseVideoListController.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVCourseSection.h"

@interface PLVCourseVideoListController : UITableViewController

@property (nonatomic, strong) NSArray<PLVCourseSection *> *videoSections;

@property (nonatomic, copy) void (^videoDidSelect)(PLVVodVideo *video);

@end
