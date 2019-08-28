//
//  PLVPPTSkinProgressView.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/20.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVPPTSkinProgressView : UIView

- (instancetype)initWithRadius:(CGFloat)radius;

- (void)changeRadius:(CGFloat)radius;

- (void)startLoading;

- (void)stopLoading;

- (void)startDownloading;

- (void)updateProgress:(CGFloat)progrss;

@end

NS_ASSUME_NONNULL_END
