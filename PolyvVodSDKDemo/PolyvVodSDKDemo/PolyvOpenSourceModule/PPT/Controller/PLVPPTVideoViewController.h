//
//  PLVPPTVideoViewController.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/7/26.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodSkinPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@class PLVVodPlayerLogoParam;

@protocol PLVPPTVideoViewControllerProtocol <NSObject>

- (void)videoWithVid:(NSString *)vid title:(NSString *)title hasPPT:(BOOL)hasPPT localPlay:(BOOL)localPlay;

- (PLVVodPlaybackMode)currenPlaybackMode;

@end

@interface PLVPPTVideoViewController : UIViewController

@property (nonatomic, weak) id<PLVPPTVideoViewControllerProtocol> delegate;
@property (nonatomic, strong, readonly) PLVVodSkinPlayerController *player;

@property (nonatomic, strong, readonly) UIView *videoView; // 播放器渲染视图

@property (nonatomic, strong, readonly) UIView *skinLoadingView; // 加载指示器
@property (nonatomic, strong, readonly) UIView *skinCoverView;   // 音视频封面图
@property (nonatomic, strong, readonly) UIView *skinAnimationCoverView;// 音频模式动画封面

@property (nonatomic, assign, readonly) BOOL isLockScreen;

@property (nonatomic, copy) void (^closeSubscreenButtonActionHandler) (void);
@property (nonatomic, copy) void (^pptCatalogButtonActionHandler) (void);
@property (nonatomic, copy) UIImage *(^snapshotButtonActionHandler) (void);

- (void)playWithVid:(NSString *)vid offline:(BOOL)isOffline;

- (void)hiddenSkin:(BOOL)hidden;

- (void)insertView:(UIView *)subView;

- (void)recoverCoverView;

- (void)recoverAudioAnimationCoverView;

- (void)recoverLoadingView;

- (void)setAudioAniViewCornerRadius:(CGFloat)cornerRadius;

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime;

- (void)addLogoWithParam:(NSArray <PLVVodPlayerLogoParam *> *)paramArray;

@end

NS_ASSUME_NONNULL_END
