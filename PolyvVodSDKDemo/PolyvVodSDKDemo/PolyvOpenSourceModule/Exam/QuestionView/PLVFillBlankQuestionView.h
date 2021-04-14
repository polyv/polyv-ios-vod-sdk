//
//  PLVFillBlankQuestionView.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/1/28.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodQuestion.h"

NS_ASSUME_NONNULL_BEGIN

/// 填空题 问题view
@interface PLVFillBlankQuestionView : UIView

@property (nonatomic, strong) PLVVodQuestion *question;

/// 填空题的提交回调
@property (nonatomic, copy) void (^submitFillBlankTopicActionHandler)(NSArray<NSString *> *answerItems);

/// 跳过回调
@property (nonatomic, copy) void (^skipActionHandler)(void);

- (void)scrollToTop;

@end

NS_ASSUME_NONNULL_END
