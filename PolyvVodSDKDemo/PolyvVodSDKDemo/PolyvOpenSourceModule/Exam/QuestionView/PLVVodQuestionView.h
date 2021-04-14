//
//  PLVVodQuestionView.h
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodQuestion.h"

/// 选择题问题view
@interface PLVVodQuestionView : UIView

/// 选择题的提交回调
@property (nonatomic, copy) void (^submitActionHandler)(NSArray<NSNumber *> *indexForSelectedItems);

/// 跳过回调
@property (nonatomic, copy) void (^skipActionHandler)(void);

@property (nonatomic, strong) PLVVodQuestion *question;

- (void)scrollToTop;

@end
