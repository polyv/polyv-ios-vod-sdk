//
//  PLVVodExamViewController.h
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PLVVodExam;

@interface PLVVodExamViewController : UIViewController

/// 问答模型数组
@property (nonatomic, strong) NSArray<PLVVodExam *> *exams;

/// 当前播放时间
@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, copy) void (^examWillShowHandler)(PLVVodExam *exam);
@property (nonatomic, copy) void (^examDidCompleteHandler)(PLVVodExam *exam, NSTimeInterval backTime);

/// 同步显示问答
- (void)synchronouslyShowExam;

@end
