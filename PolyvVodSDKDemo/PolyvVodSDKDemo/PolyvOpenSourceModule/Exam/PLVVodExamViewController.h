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
@property (nonatomic, copy) void (^examDidCompleteHandler)(PLVVodExam *exam, NSTimeInterval backTime, NSArray<NSNumber *> *answerIndexs);

@property (nonatomic, assign, readonly) BOOL showing;

/// 同步显示问答
- (void)synchronouslyShowExam;

/**
 问题回答错误，替换问题
 
 @param arrExam  新问题数组，用来替换回答错误的问题
 @param showTime 时间节点，在该时间点替换或者插入新问题
 */
- (void)changeExams:(NSArray<PLVVodExam *> *)arrExam showTime:(NSTimeInterval )showTime;

@end
