//
//  PLVVodFullscreenView.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodConstans.h>
#import <PLVVodSDK/PLVVodVideo.h>

@interface PLVVodFullscreenView : UIView

@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressView;
@property (weak, nonatomic) IBOutlet UISlider *playbackSlider;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchScreenButton;
@property (weak, nonatomic) IBOutlet UIButton *snapshotButton;
@property (weak, nonatomic) IBOutlet UIButton *danmuSendButton;
@property (weak, nonatomic) IBOutlet UIButton *definitionButton;
@property (weak, nonatomic) IBOutlet UIButton *videoToolBoxButton;
@property (weak, nonatomic) IBOutlet UIButton *playbackRateButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *danmuButton;
@property (weak, nonatomic) IBOutlet UIButton *lockScreenButton;
@property (weak, nonatomic) IBOutlet UIButton *routeButton; // 线路切换
@property (weak, nonatomic) IBOutlet UIButton *subScreenButton; // 关闭三分屏按钮
@property (weak, nonatomic) IBOutlet UIButton *pptCatalogButton; // 显示课件目录按钮
@property (weak, nonatomic) IBOutlet UIButton *floatingButton; // 悬浮窗播放按钮
@property (weak, nonatomic) IBOutlet UIButton *knowledgeButton; // 知识点按钮

//音视频切换
@property (weak, nonatomic) IBOutlet UIView *playModeContainerView;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayModeButton;
@property (weak, nonatomic) IBOutlet UIButton *audioPlayModeButton;

// 清晰度按钮是否响应事件
@property (nonatomic, assign) BOOL enableQualityBtn;   // 清晰度按钮是否响应事件

//滑杆背景视频，添加视频打点
@property (weak, nonatomic) IBOutlet UIView *sliderBackView;

// 选中的播放打点信息回调，seek 到指定位置播放视频
@property (nonatomic, strong) void(^plvVideoTipsSelectedBlock)(NSUInteger selIndex);

// 变更播放模式
- (void)switchToPlayMode:(PLVVodPlaybackMode)mode;

// 是否支持三分屏功能，不调用时默认不支持
- (void)enablePPTMode:(BOOL)enable;

// 添加播放打点信息
- (void)addPlayTipsWithVideo:(PLVVodVideo *)video;

// 展示点击后的浮动打点信息
- (void)showPlayTipsWithIndex:(NSUInteger )index;
// 隐藏浮动信息
- (void)hidePlayTipsView;

// 是否支持悬浮窗播放，不调用时默认不支持
- (void)enableFloating:(BOOL)enable;

// 是否支持知识点功能，不调用时默认不支持
- (void)enableKnowledge:(BOOL)enable;

@end
