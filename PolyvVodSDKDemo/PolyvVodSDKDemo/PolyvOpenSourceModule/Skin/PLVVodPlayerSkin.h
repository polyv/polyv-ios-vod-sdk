//
//  PLVVodPlayerSkin.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/26.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodPlayerSkinProtocol.h>
#import <PLVVodSDK/PLVVodVideo.h>
#import "PLVVodGestureIndicatorView.h"
#import "PLVVodNetworkTipsView.h"

@class PLVVodAudioCoverPanelView;

@interface PLVVodPlayerSkin : UIViewController<PLVVodPlayerSkinProtocol>

#pragma mark - PLVVodPlayerSkinProtocol 重新声明

/// 弱引用的播放器
@property (nonatomic, weak) IBOutlet PLVVodPlayerViewController *delegatePlayer;

/// 指导页面隐藏导航栏
@property (nonatomic, assign) BOOL shouldHideNavigationBar;

/// 指导页面状态栏隐藏
@property (nonatomic, assign) BOOL shouldHideStatusBar;

/// 指导页面状态栏样式
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

// 播放速率
@property (nonatomic, assign) double playbackRate;

/// 是否播放本地视频
@property (nonatomic, assign) BOOL localPlayback;

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

/// 投屏按钮
@property (nonatomic, weak) IBOutlet UIButton *castButton;

/// 全屏顶部投屏按钮
@property (nonatomic, weak) IBOutlet UIButton *castButtonInFullScreen;

/// 半屏全屏按钮点击事件
@property (nonatomic, strong) void (^castButtonTouchHandler)(UIButton * button);

#pragma mark - 额外

/// 字幕标签
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

/// 顶部字幕标签
@property (weak, nonatomic) IBOutlet UILabel *subtitleTopLabel;

/// 手势指示器
@property (strong, nonatomic) IBOutlet PLVVodGestureIndicatorView *gestureIndicatorView;

/// 载入指示器
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

/// 皮肤覆盖层，显示弹幕
@property (nonatomic, strong) UIView *skinMaskView;

/// 是否是锁屏状态
@property (nonatomic, assign, readonly) BOOL isLockScreen;

/// 是否启用弹幕
@property (nonatomic, assign) BOOL enableDanmu;
@property (nonatomic, copy) void (^enableDanmuChangeHandler)(PLVVodPlayerSkin *skin, BOOL enableDanmu);

/// 视频打点，点击播放回调
@property (nonatomic, copy) void(^plvVideoTipsPlayerBlock)(NSUInteger playIndex);

/// 线路选择回调
@property (nonatomic, copy) void (^routeLineDidChangeBlock)(NSUInteger routeIndex);
/// 设置线路数
- (void)setRouteLineCount:(NSUInteger)count;
/// 线路选择按钮显示或隐藏
- (void)setRouteLineFullScreenBtnHidden:(BOOL)hidden;
- (void)setRouteLineShrinkScreenBtnHidden:(BOOL)hidden;

/// 是否显示线路按钮
- (BOOL)isShowRoutelineInShrinkSreen;

/// 清晰度按钮是否响应事件
- (void)setEnableQualityBtn:(BOOL )enable;


- (void)showGestureIndicator;
- (void)hideGestureIndicator;

- (void)hideOrShowPlaybackControl;

- (void)setUpPlaybackMode:(PLVVodVideo *)video;
- (void)updatePlayModeContainView:(PLVVodVideo *)video;

- (void)updateCoverView:(PLVVodVideo *)video;
- (void)removeCoverView;

- (void)updateAudioCoverAnimation:(BOOL)isPlaying;

// 添加视频打点信息
- (void)addVideoPlayTips:(PLVVodVideo *)video;
// 展示视频打点信息
- (void)showVideoPlayTips:(NSUInteger )tipsIndx;

// 展示网络类型提示；返回的提示视图PLVVodNetworkTipsView，可设置点击事件Block
- (PLVVodNetworkTipsView *)showNetworkTips;
- (void)hideNetworkTips;

// 播放错误提示
- (PLVVodNetworkTipsView *)showPlayErrorWithTips:(NSString *)errorTips isLocal:(BOOL)isLocal;
- (void)hidePlayErrorTips;




@end
