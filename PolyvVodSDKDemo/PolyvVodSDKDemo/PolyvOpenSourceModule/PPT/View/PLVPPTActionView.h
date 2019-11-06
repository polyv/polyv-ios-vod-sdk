//
//  PLVPPTActionView.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/1.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVVodPPT;

NS_ASSUME_NONNULL_BEGIN

@interface PLVPPTActionView : UIView

@property (nonatomic, copy) void (^didSelectCellHandler)(NSInteger index);

- (instancetype)initWithPPT:(PLVVodPPT *)ppt;

/**
 展示 PLVPPTActionView 到顶层 window
 */
- (void)show;

/**
 隐藏 PLVPPTActionView，并移出 window
 */
- (void)dissmiss;

@end

NS_ASSUME_NONNULL_END
