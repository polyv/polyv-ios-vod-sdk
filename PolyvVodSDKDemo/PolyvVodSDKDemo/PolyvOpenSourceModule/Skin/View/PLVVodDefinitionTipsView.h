//
//  PLVVodDefinitionTipsView.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/7/19.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodConstans.h>

NS_ASSUME_NONNULL_BEGIN

/// 清晰度切换的提示view
@interface PLVVodDefinitionTipsView : UIView

/// 是否正在展示
@property (nonatomic, assign, readonly) BOOL isShowing;

/// 是否不再提示
@property (nonatomic, assign, readonly) BOOL isDoNotShowAgain;

/// 点击切换清晰度回调
@property (nonatomic, copy) void (^clickSwitchQualityBlock) (PLVVodQuality quality);

/// 展示切换清晰度的提示
/// @param quality 建议切换的清晰度
- (void)showSwitchQuality:(PLVVodQuality)quality;

/// 展示切换成功的提示
/// @param quality 已经切换成功的清晰度
- (void)showSwitchSuccess:(PLVVodQuality)quality;

/// 隐藏提示view
- (void)hide;

@end

NS_ASSUME_NONNULL_END
