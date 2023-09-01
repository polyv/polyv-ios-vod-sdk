//
//  PLVVodPlayerSkin.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/26.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodPlayerSkin.h"
#import "PLVVodUtils.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "PLVVodFullscreenView.h"
#import "PLVVodShrinkscreenView.h"
#import "PLVVodSettingPanelView.h"
#import "PLVVodAudioCoverPanelView.h"
#import "PLVVodDanmuSendView.h"
#import "PLVVodDanmu+PLVVod.h"
#import "PLVVodDefinitionPanelView.h"
#import "PLVVodVideoToolBoxPanelView.h"
#import "PLVVodPlaybackRatePanelView.h"
#import "PLVVodLockScreenView.h"
#import "PLVVodCoverView.h"
#import "PLVVodRouteLineView.h"
#import "UIButton+EnlargeTouchArea.h"
#import <Photos/Photos.h>


@interface PLVVodPlayerSkin ()<UITextFieldDelegate>

/// 半屏皮肤
@property (strong, nonatomic) IBOutlet PLVVodShrinkscreenView *shrinkscreenView;

/// 全屏皮肤
@property (strong, nonatomic) IBOutlet PLVVodFullscreenView *fullscreenView;

/// 综合设置面板
@property (strong, nonatomic) IBOutlet PLVVodSettingPanelView *settingsPanelView;

/// 清晰度选择面板
@property (strong, nonatomic) IBOutlet PLVVodDefinitionPanelView *definitionPanelView;

/// 软硬解选择面板
@property (strong, nonatomic) IBOutlet PLVVodVideoToolBoxPanelView *videoToolBoxPanelView;

/// 速率选择面板
@property (strong, nonatomic) IBOutlet PLVVodPlaybackRatePanelView *playbackRatePanelView;

/// 线路选择面板
@property (strong, nonatomic) IBOutlet PLVVodRouteLineView *routeLineView;

/// 分享平台选择面板
@property (strong, nonatomic) IBOutlet UIView *sharePanelView;

/// 音频封面面板
@property (strong, nonatomic) IBOutlet PLVVodAudioCoverPanelView *audioCoverPanelView;

/// 锁屏状态面板
@property (strong, nonatomic) IBOutlet PLVVodLockScreenView *lockScreenView;

/// 源文件音频播放封面图面板
@property (strong, nonatomic) IBOutlet PLVVodCoverView *coverView;
@property (nonatomic, assign) BOOL isVideoCover;

/// 在面板的点击
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *panelTap;

/// 之前的约束
@property (nonatomic, strong) NSArray *priorConstraints;

/// 当前的播放控件视图
@property (nonatomic, weak) UIView *mainControl;

/// 顶层视图
@property (nonatomic, weak) UIView *topView;

/// 弹幕发送、配置视图
@property (strong, nonatomic) IBOutlet PLVVodDanmuSendView *danmuSendView;

/// 皮肤控件容器视图
@property (weak, nonatomic) IBOutlet UIView *controlContainerView;

/// 锁屏状态
@property (assign, nonatomic) BOOL isLockScreen;

/// 网络类型提示视图
@property (nonatomic, strong) PLVVodNetworkTipsView *networkTipsV;

/// 播放错误提示视图
@property (nonatomic, strong) PLVVodNetworkTipsView *playErrorTipsView;

/// 手势快进提示视图
@property (nonatomic, strong) PLVVodFastForwardView *fastForwardView;

/// 切换清晰度的提示视图
@property (nonatomic, strong) PLVVodDefinitionTipsView *definitionTipsView;

@end

@implementation PLVVodPlayerSkin

#pragma mark - property

- (void)setMainControl:(UIView *)mainControl {
	if (_mainControl && mainControl) {
		[self transitFromView:self.topView toView:mainControl];
	}
	_mainControl = mainControl;
	if ([mainControl isKindOfClass:[PLVVodFullscreenView class]]) {
		PLVVodFullscreenView *playbackControl = (PLVVodFullscreenView *)mainControl;
		self.playPauseButton = playbackControl.playPauseButton;
		self.timeLabel = playbackControl.timeLabel;
		self.bufferProgressView = playbackControl.bufferProgressView;
		self.playbackSlider = playbackControl.playbackSlider;
		self.fullShrinkscreenButton = playbackControl.switchScreenButton;
	} else if ([mainControl isKindOfClass:[PLVVodShrinkscreenView class]]) {
		PLVVodShrinkscreenView *playbackControl = (PLVVodShrinkscreenView *)mainControl;
		self.playPauseButton = playbackControl.playPauseButton;
		self.timeLabel = playbackControl.timeLabel;
		self.bufferProgressView = playbackControl.bufferProgressView;
		self.playbackSlider = playbackControl.playbackSlider;
		self.fullShrinkscreenButton = playbackControl.switchScreenButton;
	}
    
    [self.playPauseButton setEnlargeEdgeWithTop:15 right:15 bottom:15 left:15];
}

- (void)setTopView:(UIView *)topView {
	if (topView && _topView != topView &&
        topView != self.fullscreenView &&
        topView != self.shrinkscreenView
        && topView != self.gestureIndicatorView) {
		if ([_topView.gestureRecognizers containsObject:self.panelTap]) {
			[_topView removeGestureRecognizer:self.panelTap];
		}
		if (![topView.gestureRecognizers containsObject:self.panelTap]) {
			[topView addGestureRecognizer:self.panelTap];
		}
	}
	_topView = topView;
}

- (void)setDelegatePlayer:(PLVVodSkinPlayerController *)delegatePlayer {
	_delegatePlayer = delegatePlayer;
	if (!delegatePlayer) return;
	__weak typeof(self) weakSelf = self;
	//[self.delegatePlayer.doNotReceiveGestureViews addObject:self.shrinkscreenView];
	dispatch_async(dispatch_get_main_queue(), ^{
		[weakSelf.fullscreenView.backButton setTitle:delegatePlayer.video.title forState:UIControlStateNormal];
        // 根据 video 的 hasPPT 属性和 player.enablePPT 确定是否要显示【关闭副屏】【显示课件目录】按钮
        [weakSelf enablePPTMode:delegatePlayer.video.hasPPT && delegatePlayer.enablePPT];
	});
    
    _delegatePlayer.didFullScreenSwitch = ^(BOOL fullScreen) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.shrinkscreenView.switchScreenButton.selected = fullScreen;
            [weakSelf updateUIForOrientation];
        });
    };
    
    // 切换清晰度成功回调
    _delegatePlayer.switchQualitySuccessHandler = ^(PLVVodQuality quality) {
        if (self->_delegatePlayer.fullscreen) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.definitionTipsView showSwitchSuccess:quality];
            });
        }
    };
    
    //差网络回调
    _delegatePlayer.poorNetWorkHandler = ^{
        if (self->_delegatePlayer.quality > PLVVodQualityStandard &&
            self->_delegatePlayer.fullscreen) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.definitionTipsView showSwitchQuality:self->_delegatePlayer.quality - 1];
            });
        }
    };
}

- (void)setLocalPlayback:(BOOL)localPlayback {
	_localPlayback = localPlayback;
	dispatch_async(dispatch_get_main_queue(), ^{
		UIButton *definitionButton = self.fullscreenView.definitionButton;
		if (localPlayback) {
			[definitionButton setTitle:@"本地" forState:UIControlStateNormal];
			definitionButton.selected = NO;
			definitionButton.enabled = NO;
		} else {
			definitionButton.selected = YES;
			definitionButton.enabled = YES;
            
            if (self.delegatePlayer.video.keepSource){
                definitionButton.enabled = NO;
            }
		}
        
        UIButton *shrinkDefiBtn = self.shrinkscreenView.definitionButton;
        if (localPlayback) {
            [shrinkDefiBtn setTitle:@"本地" forState:UIControlStateNormal];
            shrinkDefiBtn.enabled = NO;
        } else {
            shrinkDefiBtn.enabled = YES;
            
            if (self.delegatePlayer.video.keepSource){
                shrinkDefiBtn.enabled = NO;
            }
        }
	});
}

- (void)setEnableDanmu:(BOOL)enableDanmu {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.fullscreenView.danmuButton.selected = enableDanmu;
	});
}
- (BOOL)enableDanmu {
	return self.fullscreenView.danmuButton.selected;
}

#pragma mark - PLVVodPlayerSkinProtocol

#pragma mark 字幕

- (void)setSubtitleKeys:(NSArray<NSString *> *)subtitleKeys {
	self.settingsPanelView.subtitleKeys = subtitleKeys;
}
- (NSArray<NSString *> *)subtitleKeys {
	return self.settingsPanelView.subtitleKeys;
}

- (void)setSelectedSubtitleKeyDidChangeBlock:(void (^)(NSString *))selectedSubtitleKeyDidChangeBlock {
	self.settingsPanelView.selectedSubtitleKeyDidChangeBlock = selectedSubtitleKeyDidChangeBlock;
}
- (void (^)(NSString *))selectedSubtitleKeyDidChangeBlock {
	return self.settingsPanelView.selectedSubtitleKeyDidChangeBlock;
}

- (void)setSelectedSubtitleKey:(NSString *)selectedSubtitleKey {
	self.settingsPanelView.selectedSubtitleKey = selectedSubtitleKey;
}
- (NSString *)selectedSubtitleKey {
	return self.settingsPanelView.selectedSubtitleKey;
}

#pragma mark 清晰度

- (void)setQualityCount:(int)qualityCount {
	self.definitionPanelView.qualityCount = qualityCount;
}
- (int)qualityCount {
	return self.definitionPanelView.qualityCount;
}

- (void)setQuality:(PLVVodQuality)quality {
	self.definitionPanelView.quality = (int)quality;
	NSString *definition = NSStringFromPLVVodQuality(quality);
	dispatch_async(dispatch_get_main_queue(), ^{
		UIButton *definitionButton = self.fullscreenView.definitionButton;
		[definitionButton setTitle:definition forState:UIControlStateNormal];
        
        UIButton *shrinkDefinitionBtn = self.shrinkscreenView.definitionButton;
        if (shrinkDefinitionBtn){
            [shrinkDefinitionBtn setTitle:definition forState:UIControlStateNormal];
        }
	});
}
- (PLVVodQuality)quality {
	return self.definitionPanelView.quality;
}

- (void)setQualityDidChangeBlock:(void (^)(PLVVodQuality))qualityDidChangeBlock {
	self.definitionPanelView.qualityDidChangeBlock = qualityDidChangeBlock;
}
- (void (^)(PLVVodQuality))qualityDidChangeBlock {
	return self.definitionPanelView.qualityDidChangeBlock;
}

- (void)setEnableQualityBtn:(BOOL)enable{
    [self.shrinkscreenView setEnableQualityBtn:enable];
    [self.fullscreenView setEnableQualityBtn:enable];
}

#pragma mark 软硬解

- (void)setIsVideoToolBox:(BOOL)isVideoToolBox {
    self.videoToolBoxPanelView.isVideoToolBox = isVideoToolBox;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = isVideoToolBox ? @"硬解" : @"软解";
        UIButton *videoToolBoxButton = self.fullscreenView.videoToolBoxButton;
        [videoToolBoxButton setTitle:title forState:UIControlStateNormal];
    });
}

- (BOOL)isVideoToolBox {
    return self.videoToolBoxPanelView.isVideoToolBox;
}

- (void)setVideoToolBoxDidChangeBlock:(void (^)(BOOL))videoToolBoxDidChangeBlock {
    self.videoToolBoxPanelView.videoToolBoxDidChangeBlock = videoToolBoxDidChangeBlock;
}

- (void (^)(BOOL))videoToolBoxDidChangeBlock {
    return self.videoToolBoxPanelView.videoToolBoxDidChangeBlock;
}

#pragma mark 拉伸方式

- (void)setScalingMode:(NSInteger)scalingMode {
	self.settingsPanelView.scalingMode = scalingMode;
}
- (NSInteger)scalingMode {
	return self.settingsPanelView.scalingMode;
}
- (void)setScalingModeDidChangeBlock:(void (^)(NSInteger))scalingModeDidChangeBlock {
	self.settingsPanelView.scalingModeDidChangeBlock = scalingModeDidChangeBlock;
}
- (void (^)(NSInteger))scalingModeDidChangeBlock {
	return self.settingsPanelView.scalingModeDidChangeBlock;
}

#pragma mark 播放速率

- (void)setPlaybackRate:(double)playbackRate {
	NSString *title = [NSString stringWithFormat:@"%.1fx", playbackRate];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.fullscreenView.playbackRateButton setTitle:title forState:UIControlStateNormal];
        [self.playbackRatePanelView setCurRate:playbackRate];
        
        if (self.shrinkscreenView.playbackRateButton){
            [self.shrinkscreenView.playbackRateButton setTitle:title forState:UIControlStateNormal];
        }
	});
}

- (void)setSelectedPlaybackRateDidChangeBlock:(void (^)(double))selectedPlaybackRateDidChangeBlock {
	self.playbackRatePanelView.selectedPlaybackRateDidChangeBlock = selectedPlaybackRateDidChangeBlock;
}

- (void (^)(double))selectedPlaybackRateDidChangeBlock {
	return self.playbackRatePanelView.selectedPlaybackRateDidChangeBlock;
}

#pragma mark 线路数
- (void)setRouteLineCount:(NSUInteger)count{
    [self.routeLineView setRouteLineCount:count];
}

- (void)setRouteLineShrinkScreenBtnHidden:(BOOL)hidden{
    self.shrinkscreenView.routeButton.hidden = hidden;
}

- (void)setRouteLineFullScreenBtnHidden:(BOOL)hidden{
    self.fullscreenView.routeButton.hidden = hidden;
}

- (BOOL)isShowRoutelineInShrinkSreen{
    return self.shrinkscreenView.isShowRouteline;
}

#pragma mark 音视频切换（PlaybackMode）
- (void)setUpPlaybackMode:(PLVVodVideo *)video {
    BOOL canSwithPlaybackMode = [video canSwithPlaybackMode];
    self.shrinkscreenView.playModeContainerView.hidden = !canSwithPlaybackMode;
    self.fullscreenView.playModeContainerView.hidden = !canSwithPlaybackMode;
    
    [self.audioCoverPanelView setCoverUrl:video.snapshot];
    if ([self.audioCoverPanelView superview] == nil) {
        [self.view addSubview:self.audioCoverPanelView];
        [self constrainSubview:self.audioCoverPanelView toMatchWithSuperview:self.view];
        [self.view sendSubviewToBack:self.audioCoverPanelView];
    }
    
    if (![video canSwithPlaybackMode]) {
        [self.audioCoverPanelView hiddenContainerView:YES];
    }
    
    [self updatePlayModeContainView:video];
}

- (void)updatePlayModeContainView:(PLVVodVideo *)video {
    if ([video canSwithPlaybackMode]) {
        PLVVodPlaybackMode playbackMode = self.delegatePlayer.playbackMode;
        [self.shrinkscreenView switchToPlayMode:playbackMode];
        [self.fullscreenView switchToPlayMode:playbackMode];
        [self.audioCoverPanelView switchToPlayMode:playbackMode];
    }
    
    // 根据 video 的 hasPPT 属性和 player.enablePPT 确定是否要显示【关闭副屏】【显示课件目录】按钮
    [self enablePPTMode:video.hasPPT && self.delegatePlayer.enablePPT];
}

- (void)enablePPTMode:(BOOL)enable {
    // 是否要显示【关闭副屏】【显示课件目录】按钮
    [self.shrinkscreenView enablePPTMode:enable];
    [self.fullscreenView enablePPTMode:enable];
}

- (void)enableFloating:(BOOL)enable {
    // 是否要显示【悬浮窗播放】按钮
    [self.shrinkscreenView enableFloating:enable];
    [self.fullscreenView enableFloating:enable];
}

- (void)setEnableKnowledge:(BOOL)enableKnowledge {
    _enableKnowledge = enableKnowledge;
    [self.fullscreenView enableKnowledge:enableKnowledge];
}

- (void)setKnowledgeButtonTitle:(NSString *)knowledgeButtonTitle {
    [self.fullscreenView.knowledgeButton setTitle:knowledgeButtonTitle forState:0];
}

- (NSString *)knowledgeButtonTitle {
    return self.fullscreenView.knowledgeButton.titleLabel.text;
}

- (void)updateAudioCoverAnimation:(BOOL)isPlaying {
    if (isPlaying) {
        [self.audioCoverPanelView startRotate];
    } else {
        [self.audioCoverPanelView stopRotate];
    }
}

#pragma mark 音视频封面图
- (void)updateCoverView:(PLVVodVideo *)video{
    NSString * fileUrl;

    if ([video isKindOfClass: [PLVVodLocalVideo class]]){
        // 是本地文件
        PLVVodDownloadInfo * info = [[PLVVodDownloadManager sharedManager]requestDownloadInfoWithVid:video.vid];
        
        video.snapshot = info.snapshot;
        
        PLVVodLocalVideo * localVideoModel = (PLVVodLocalVideo *)video;
        fileUrl = localVideoModel.path;
    }else{
        // 非本地文件
        if (video.keepSource == NO) {
            // 非源文件
            fileUrl = video.isHls302 ? video.hlsIndex2 : video.hlsIndex;
        }else{
            // 源文件
            fileUrl = video.play_source_url;
        }
    }
    
    // 判断链接是否存在
    if (fileUrl && [fileUrl isKindOfClass:[NSString class]] && fileUrl.length != 0) {
        // 判断是否为音频
        if ([fileUrl hasSuffix:@".mp3"]) {
            self.isVideoCover = NO;
        }else{
            self.isVideoCover = YES;
        }
        
        self.coverView.hidden = NO;
        [self.coverView setCoverImageWithUrl:video.snapshot];
        [self.view addSubview:self.coverView];
        [self constrainSubview:self.coverView toMatchWithSuperview:self.view];
        [self.view sendSubviewToBack:self.coverView];
    }
}

- (void)removeCoverView{
    if (self.isVideoCover) { // 视频播放时需隐藏，而音频无需
        [self.coverView setHidden:YES];
    }
}

#pragma mark 添加视频打点信息
- (void)addVideoPlayTips:(PLVVodVideo *)video{
    [self.fullscreenView addPlayTipsWithVideo:video];
}

#pragma mark 展示视频打点信息
- (void)showVideoPlayTips:(NSUInteger)tipsIndx{
    [self.fullscreenView showPlayTipsWithIndex:tipsIndx];
}

#pragma mark 网络类型提示
- (PLVVodNetworkTipsView *)showNetworkTips{
    [self.networkTipsV show];
    BOOL isShowing = self.controlContainerView.alpha > 0.0;
    if (isShowing) {
        [self hideOrShowPlaybackControl];
    }
    return self.networkTipsV;
}

- (void)hideNetworkTips{
    [self.networkTipsV hide];
}

#pragma mark -- 播放错误提示
- (PLVVodNetworkTipsView *)showPlayErrorWithTips:(NSString *)errorTips isLocal:(BOOL)isLocal{
    [self.playErrorTipsView show];
    self.playErrorTipsView.tipsLb.text = errorTips;
    self.playErrorTipsView.playBtn.hidden = isLocal;
    BOOL isShowing = self.controlContainerView.alpha > 0.0;
    if (isShowing) {
        [self hideOrShowPlaybackControl];
    }
    
    return self.playErrorTipsView;
}

- (void)hidePlayErrorTips{
    [self.playErrorTipsView hide];
}

#pragma getter --

- (PLVVodNetworkTipsView *)networkTipsV{
    if (!_networkTipsV) {
        _networkTipsV = [[PLVVodNetworkTipsView alloc] init];
        [_networkTipsV hide];
        [self.view addSubview:_networkTipsV];
        [self constrainSubview:_networkTipsV toMatchWithSuperview:self.view];
        [self.view bringSubviewToFront:_networkTipsV];
    }
    return _networkTipsV;
}

- (PLVVodNetworkTipsView *)playErrorTipsView{
    if (!_playErrorTipsView){
        _playErrorTipsView = [[PLVVodNetworkTipsView alloc] init];
        [_playErrorTipsView.playBtn setTitle:@"播放重试" forState:UIControlStateNormal];
        [_playErrorTipsView hide];
        [self.view addSubview:_playErrorTipsView];
        [self constrainSubview:_playErrorTipsView toMatchWithSuperview:self.view];
        [self.view bringSubviewToFront:_playErrorTipsView];
    }
    
    return _playErrorTipsView;
}

- (PLVVodFastForwardView *)fastForwardView {
    if (!_fastForwardView) {
        _fastForwardView = [[PLVVodFastForwardView alloc] init];
        [self.view addSubview:_fastForwardView];
        [self constrainSubview:_fastForwardView toMatchWithSuperview:self.view];
        [self.view bringSubviewToFront:_fastForwardView];
    }
    return _fastForwardView;
}

-(PLVVodDefinitionTipsView *)definitionTipsView {
    if (!_definitionTipsView) {
        _definitionTipsView = [[PLVVodDefinitionTipsView alloc] init];
        __weak typeof(self) weakSelf = self;
        [_definitionTipsView setClickSwitchQualityBlock:^(PLVVodQuality quality) {
            weakSelf.quality = quality;
            if (weakSelf.definitionPanelView.qualityDidChangeBlock) {
                weakSelf.definitionPanelView.qualityDidChangeBlock(quality);
            }
        }];
        [self.view addSubview:_definitionTipsView];
        [self constrainSubview:_definitionTipsView toMatchWithSuperview:self.view];
        [self.view bringSubviewToFront:_definitionTipsView];
    }
    return _definitionTipsView;
}


#pragma mark - view controller

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interfaceOrientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
	[self setupUI];
}

- (void)setupUI {
	[self updateUIForOrientation];
	
	self.topView = self.mainControl;
	[self.controlContainerView addSubview:self.mainControl];
	self.priorConstraints = [self constrainSubview:self.mainControl toMatchWithSuperview:self.controlContainerView];
	
	[self.view addSubview:self.gestureIndicatorView];
	[self constrainSubview:self.gestureIndicatorView toMatchWithSuperview:self.view];
	self.gestureIndicatorView.alpha = 0;
	
	// 配置控件细节
	self.subtitleLabel.text = @"";
    self.subtitleTopLabel.text = @"";
	UIImage *playbackThumb = [UIImage imageNamed:@"plv_vod_btn_slider_player"];
	[self.fullscreenView.playbackSlider setThumbImage:playbackThumb forState:UIControlStateNormal];
	[self.shrinkscreenView.playbackSlider setThumbImage:playbackThumb forState:UIControlStateNormal];
	
	UIImage *settingThumb = [UIImage imageNamed:@"plv_vod_btn_slider_settings"];
	[self.settingsPanelView.volumeSlider setThumbImage:settingThumb forState:UIControlStateNormal];
	[self.settingsPanelView.brightnessSlider setThumbImage:settingThumb forState:UIControlStateNormal];
	
	__weak typeof(self) weakSelf = self;
	self.definitionPanelView.qualityButtonDidClick = ^(UIButton *sender) {
		[weakSelf backMainControl:sender];
	};
    self.videoToolBoxPanelView.videoToolBoxButtonDidClick = ^(UIButton * _Nonnull sender) {
        [weakSelf backMainControl:sender];
    };
	self.playbackRatePanelView.playbackRateButtonDidClick = ^(UIButton *sender) {
		[weakSelf backMainControl:sender];
	};
    self.routeLineView.routeLineBtnDidClick = ^(UIButton * _Nonnull sender) {
        [weakSelf backMainControl:sender];
    };
    self.routeLineView.routeLineDidChangeBlock = ^(NSUInteger routeIndex) {
        if (weakSelf.routeLineDidChangeBlock){
            weakSelf.routeLineDidChangeBlock(routeIndex);
        }
    };
    
	// 链接属性
	self.brightnessSlider = self.settingsPanelView.brightnessSlider;
	self.volumeSlider = self.settingsPanelView.volumeSlider;
    
    // 在线视频网络加载速度
    self.loadSpeed.hidden = YES;
    
    // 视频打点信息，点击播放回调，UI层触发
    self.fullscreenView.plvVideoTipsSelectedBlock = ^(NSUInteger selIndex) {
        if (weakSelf.plvVideoTipsPlayerBlock){
            weakSelf.plvVideoTipsPlayerBlock(selIndex);
        }
    };
	
	// 自动隐藏控件
    [self fadeoutPlaybackControl];
    
    // 皮肤控件覆盖层，现实弹幕
    self.skinMaskView = [[UIView alloc] init];
    self.skinMaskView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.skinMaskView];
    [self constrainSubview:self.skinMaskView toMatchWithSuperview:self.view];
    [self.view sendSubviewToBack:self.skinMaskView];
    
    [self enableFloating:self.enableFloating];
}

#pragma mark - observe

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    if (self.isLockScreen) return;
	[self updateUIForOrientation];
}

- (void)updateUIForOrientation {
    if (self.deviceOrientationChangedNotSwitchFullscreen) {
        if (self.delegatePlayer.fullscreen) {
            self.mainControl = self.fullscreenView;
            self.shouldHideStatusBar = YES;
            self.shouldHideNavigationBar = YES;
        } else {
            self.mainControl = self.shrinkscreenView;
            self.shouldHideStatusBar = NO;
            self.shouldHideNavigationBar = NO;
        }
    }else {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (!UIInterfaceOrientationIsPortrait(orientation)) {
            self.mainControl = self.fullscreenView;
            self.shouldHideStatusBar = YES;
            self.shouldHideNavigationBar = YES;
        } else {
            if (self.delegatePlayer.fullscreen) {
                self.mainControl = self.fullscreenView;
                self.shouldHideStatusBar = YES;
                self.shouldHideNavigationBar = YES;
            } else {
                self.mainControl = self.shrinkscreenView;
                self.shouldHideStatusBar = NO;
                self.shouldHideNavigationBar = NO;
            }
        }
    }
    
    self.statusBarStyle = self.delegatePlayer.fullscreen ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

#pragma mark - 皮肤按钮事件

// 回到控制器主状态
- (IBAction)backMainControl:(id)sender {
    if (self.topView == self.mainControl) return;
    [self transitFromView:self.topView toView:self.mainControl];
    [self fadeoutPlaybackControl];
}

// 横竖屏切换
- (IBAction)switchScreenAction:(UIButton *)sender {
    if (self.mainControl == self.fullscreenView) {
        [self.delegatePlayer playInFullscreen:NO];
        return;
    }
    
    [self.delegatePlayer playInFullscreen:!self.delegatePlayer.fullscreen];
}

// 弹幕发送
- (IBAction)danmuButtonAction:(UIButton *)sender {
	sender.selected = !sender.selected;
	self.fullscreenView.danmuSendButton.hidden = !sender.selected;
	if (self.enableDanmuChangeHandler) self.enableDanmuChangeHandler(self, sender.selected);
}

// 清晰度设置
- (IBAction)definitionAction:(UIButton *)sender {
	[self transitToView:self.definitionPanelView];
}

- (IBAction)videotoolboxAction:(UIButton *)sender {
    [self transitToView:self.videoToolBoxPanelView];
}

// 播放速率设置
- (IBAction)playbackRateAction:(UIButton *)sender {
	[self transitToView:self.playbackRatePanelView];
}

//  切换到竖屏
- (IBAction)backAction:(UIButton *)sender {
    [self.delegatePlayer playInFullscreen:NO];
}

// 分享设置
- (IBAction)shareAction:(UIButton *)sender {
	[self transitToView:self.sharePanelView];
}

// 设置按钮
- (IBAction)settingAction:(UIButton *)sender {
	[self transitToView:self.settingsPanelView];
    [self.settingsPanelView switchToPlayMode:self.delegatePlayer.playbackMode];
    self.settingsPanelView.volumeSlider.value = self.delegatePlayer.playbackVolume;
}

// 截图按钮
- (IBAction)snapshotAction:(UIButton *)sender {
    UIImage *snapshot;
    if (self.pptVideoDelegate && [self.pptVideoDelegate respondsToSelector:@selector(tapSnapshotButton:)]) {
        snapshot = [self.pptVideoDelegate tapSnapshotButton:self];
    }
    
    if (snapshot == nil) {
        snapshot = [self.delegatePlayer snapshot];
    }
	
	NSLog(@"snapshot: %@", snapshot);
	// 请求图库权限
	__weak typeof(self) weakSelf = self;
    
    void (^authorizedHandler)(void) = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageWriteToSavedPhotosAlbum(snapshot, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        });
    };
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:{
            // 请求权限
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    authorizedHandler();
                }
            }];
        }break;
        case PHAuthorizationStatusAuthorized:{
            authorizedHandler();
        }break;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:{
            // 前往设置页
            NSString *message = [NSString stringWithFormat:@"无法获取您的照片权限，请前往设置"];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:settingURL]) {
                    [[UIApplication sharedApplication] openURL:settingURL];
                } else {
                    NSLog(@"无法打开 URL: %@", settingURL);
                }
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }break;
    }
}

- (IBAction)routeLineAction:(UIButton *)sender{
    [self transitToView:self.routeLineView];
}

-  (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = error ? @"截图保存失败" : @"截图保存成功";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:^{}];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 弹出弹幕按钮
- (IBAction)danmuAction:(UIButton *)sender {
	[self transitToView:self.danmuSendView];
}

// 视频模式按钮
- (IBAction)videoPlaybackModeAction:(id)sender {
    self.delegatePlayer.playbackMode = PLVVodPlaybackModeVideo;
    self.delegatePlayer.allowShowToast = NO;
    // add by libl [更新线路面板] 2019-02-14 start
    [self setRouteLineCount:self.delegatePlayer.video.availableRouteLines.count];
    // add end
}

// 音频模式按钮
- (IBAction)audioPlaybackModeAction:(id)sender {
    self.delegatePlayer.playbackMode = PLVVodPlaybackModeAudio;
    self.delegatePlayer.allowShowToast = NO;
    // add by libl [更新线路面板] 2019-02-14 start
    [self setRouteLineCount:self.delegatePlayer.video.availableAudioRouteLines.count];
    // add end
}

// 锁屏按钮
- (IBAction)lockScreenAction:(UIButton *)sender{
    // 进入锁屏状态
    [self transitToView:self.lockScreenView];
    [self.lockScreenView showLockScreenButton];
    self.isLockScreen = YES;
}

// 解锁按钮
- (IBAction)unlockScreenAction:(UIButton *)sender{
    [self backMainControl:sender];
    self.isLockScreen = NO;
}

// 投屏按钮
- (IBAction)castAction:(UIButton *)sender {    
    sender.selected = !sender.selected;
    if (self.castButtonTouchHandler) self.castButtonTouchHandler(sender);
}

- (IBAction)subScreenButtonAction:(id)sender {
    if (self.pptVideoDelegate && [self.pptVideoDelegate respondsToSelector:@selector(tapSubScreenButton:)]) {
        [self.pptVideoDelegate tapSubScreenButton:self];
    }
}

- (IBAction)pptCatalogButtonnAction:(id)sender {
    if (self.pptVideoDelegate && [self.pptVideoDelegate respondsToSelector:@selector(tapPPTCatalogButton:)]) {
        [self.pptVideoDelegate tapPPTCatalogButton:self];
    }
}

// 【悬浮窗播放】按钮点击事件
- (IBAction)floatingButtonAction:(id)sender {
    
    // 接着，执行对应的 block
    if (self.floatingButtonTouchHandler) {
        self.floatingButtonTouchHandler();
    }
}

// 【知识点】按钮点击事件
- (IBAction)knowledgeButtonAction:(id)sender {
    if (self.knowledgeButtonTouchHandler) {
        self.knowledgeButtonTouchHandler();
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    PLVVodDanmu *danmu = [[PLVVodDanmu alloc] init];
    danmu.content = self.danmuSendView.danmuContent;
    danmu.colorHex = self.danmuSendView.danmuColorHex;
    danmu.fontSize = self.danmuSendView.danmuFontSize;
    danmu.mode = self.danmuSendView.danmuMode;
    danmu.time = self.delegatePlayer.currentPlaybackTime;
    [danmu sendDammuWithVid:self.delegatePlayer.video.vid completion:^(NSError *error, NSString *danmuId) {
        NSLog(@"send danmu error: %@", error);
    }];
	[self backMainControl:textField];
	return NO;
}

#pragma mark - public method

- (void)showGestureIndicator:(BOOL)show {
    [UIView animateWithDuration:PLVVodAnimationDuration animations:^{
        self.gestureIndicatorView.alpha = (show ? 1 : 0);
    }];
}

- (void)hideOrShowPlaybackControl {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if (self.topView != self.mainControl) return;
	[self backMainControl:nil];
	
	BOOL isShowing = self.controlContainerView.alpha > 0.0;
	[UIView animateWithDuration:PLVVodAnimationDuration animations:^{
		self.controlContainerView.alpha = isShowing ? 0 : 1;
        if (isShowing && [self.mainControl isKindOfClass:[PLVVodFullscreenView class]]){
            PLVVodFullscreenView *fullScreen = (PLVVodFullscreenView *)self.mainControl;
            [fullScreen hidePlayTipsView];
        }
	} completion:^(BOOL finished) {
		if (!isShowing && finished) {
			[self fadeoutPlaybackControl];
		}
	}];
}

- (void)fadeoutPlaybackControl {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideOrShowPlaybackControl) object:nil];
    [self performSelector:@selector(hideOrShowPlaybackControl) withObject:nil afterDelay:PLVVodAnimationDuration*10];
}

#pragma mark - tool

// makes "subview" match the width and height of "superview" by adding the proper auto layout constraints
- (NSArray *)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview {
	subview.translatesAutoresizingMaskIntoConstraints = NO;
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview);
	
	NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDictionary];
	constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:viewsDictionary]];
	[superview addConstraints:constraints];
	
	return constraints;
}

// 执行动画视图转场
- (void)transitToView:(UIView *)toView {
	[self transitFromView:self.mainControl toView:toView];
}

- (void)transitFromView:(UIView *)fromView toView:(UIView *)toView {
	if (fromView == toView || !fromView || !toView) {
		return;
	}
	[self transitFromView:fromView toView:toView options:UIViewAnimationOptionTransitionCrossDissolve];
}

- (void)transitFromView:(UIView *)fromView toView:(UIView *)toView options:(UIViewAnimationOptions)options {
	NSArray *priorConstraints = self.priorConstraints;
    if (!self.networkTipsV.isShow) {
        fromView.superview.alpha = 1.0;
    }
	[UIView transitionFromView:fromView toView:toView duration:0.25 options:options completion:^(BOOL finished) {
		if (priorConstraints != nil) {
			[self.controlContainerView removeConstraints:priorConstraints];
		}
	}];
	self.priorConstraints = [self constrainSubview:toView toMatchWithSuperview:self.controlContainerView];
	self.topView = toView;
}

@end
