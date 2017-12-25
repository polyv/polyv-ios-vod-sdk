//
//  PLVVodQuestionView.h
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodQuestion.h"

@interface PLVVodQuestionView : UIView

@property (nonatomic, copy) void (^submitActionHandler)(NSArray<NSIndexPath *> *indexPathsForSelectedItems);
@property (nonatomic, copy) void (^skipActionHandler)(void);

@property (nonatomic, strong) PLVVodQuestion *question;

- (void)scrollToTop;

@end
