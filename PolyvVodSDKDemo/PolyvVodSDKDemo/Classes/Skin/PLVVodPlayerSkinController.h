//
//  PLVVodPlayerSkinController.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/26.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodPlayerSkinProtocol.h>

@interface PLVVodPlayerSkinController : UIViewController<PLVVodPlayerSkinProtocol>

/// 弱引用的播放器
@property (nonatomic, weak) IBOutlet PLVVodPlayerViewController *delegatePlayer;

/// 需要隐藏状态栏
@property (nonatomic, assign) BOOL shouldHideStatusBar;

/// 状态栏样式
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/// 清晰度数量
@property (nonatomic, assign) int qualityCount;

/// 选择的清晰度
@property (nonatomic, assign) PLVVodQuality quality;

/// 选择的播放速率
@property (nonatomic, assign) double playbackRate;

/// 视频拉伸方式
@property (nonatomic, assign) NSInteger scalingMode;

/// srtKeys
@property (nonatomic, strong) NSArray<NSString *> *srtKeys;

/// 选中的字幕key
@property (nonatomic, copy) NSString *srtKey;

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

@end
