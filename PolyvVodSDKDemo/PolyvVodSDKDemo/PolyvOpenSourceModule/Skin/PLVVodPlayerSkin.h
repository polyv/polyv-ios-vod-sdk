//
//  PLVVodPlayerSkin.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/26.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodPlayerSkinProtocol.h>
#import "PLVVodGestureIndicatorView.h"

@interface PLVVodPlayerSkin : UIViewController<PLVVodPlayerSkinProtocol>

#pragma mark - PLVVodPlayerSkinProtocol

/// 弱引用的播放器
@property (nonatomic, weak) IBOutlet PLVVodPlayerViewController *delegatePlayer;

#pragma mark 控件

/// 播放/暂停按钮
@property (nonatomic, weak) IBOutlet UIButton *playPauseButton;

/// 时间标签
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

/// 缓冲进度
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressView;

/// 播放进度滑杆
@property (weak, nonatomic) IBOutlet UISlider *playbackSlider;

/// 亮度滑杆
@property (nonatomic, weak) IBOutlet UISlider *brightnessSlider;

/// 音量滑杆
@property (nonatomic, weak) IBOutlet UISlider *volumeSlider;

/// 全屏/半屏按钮
@property (nonatomic, weak) IBOutlet UIButton *fullShrinkscreenButton;

#pragma mark - 额外

/// 字幕标签
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

/// 手势指示器
@property (strong, nonatomic) IBOutlet PLVVodGestureIndicatorView *gestureIndicatorView;

/// 载入指示器
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

/// 是否启用弹幕
@property (nonatomic, assign) BOOL enableDanmu;
@property (nonatomic, copy) void (^enableDanmuChangeHandler)(PLVVodPlayerSkin *skin, BOOL enableDanmu);

- (void)showGestureIndicator;
- (void)hideGestureIndicator;

- (void)hideOrShowPlaybackControl;

@end
