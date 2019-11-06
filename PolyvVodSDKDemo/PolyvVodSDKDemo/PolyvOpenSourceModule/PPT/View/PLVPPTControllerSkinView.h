//
//  PLVPPTControllerSkinView.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/20.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVPPTControllerSkinView : UIView

- (void)showNoPPTTips;

- (void)hiddenNoPPTTips;

- (void)startLoading;

- (void)startDownloading;

- (void)downloadProgressChanged:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
