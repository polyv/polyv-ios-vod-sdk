//
//  PLVCourseVideoListController.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVCourseSection.h"

/**
 PLVCourseDetailController 子控制器。
 展示课程视频列表。
 */
@interface PLVCourseVideoListController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray<PLVCourseSection *> *videoSections;

@property (nonatomic, copy) void (^videoDidSelect)(PLVVodVideo *video);

- (void)selectRowWithIndex:(NSInteger)index;

@end
