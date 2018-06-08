//
//  PLVVodPlayerSkin.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/26.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodPlayerSkin.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "PLVVodFullscreenView.h"
#import "PLVVodShrinkscreenView.h"
#import "PLVVodSettingPanelView.h"
#import "PLVVodAudioCoverPanelView.h"
#import "UIView+PLVVod.h"
#import "PLVVodDanmuSendView.h"
#import "PLVVodDanmu+PLVVod.h"
#import "PLVVodDefinitionPanelView.h"
#import "PLVVodPlaybackRatePanelView.h"
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

/// 速率选择面板
@property (strong, nonatomic) IBOutlet PLVVodPlaybackRatePanelView *playbackRatePanelView;

/// 分享平台选择面板
@property (strong, nonatomic) IBOutlet UIView *sharePanelView;

/// 音频封面面板
@property (strong, nonatomic) IBOutlet PLVVodAudioCoverPanelView *audioCoverPanelView;

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
}

- (void)setTopView:(UIView *)topView {
	if (topView && _topView != topView && topView != self.fullscreenView && topView != self.shrinkscreenView && topView != self.gestureIndicatorView) {
		if ([_topView.gestureRecognizers containsObject:self.panelTap]) {
			[_topView removeGestureRecognizer:self.panelTap];
		}
		if (![topView.gestureRecognizers containsObject:self.panelTap]) {
			[topView addGestureRecognizer:self.panelTap];
		}
		self.shouldHideStatusBar = YES;
	} else {
		self.shouldHideStatusBar = NO;
	}
	_topView = topView;
}

- (void)setDelegatePlayer:(PLVVodPlayerViewController *)delegatePlayer {
	_delegatePlayer = delegatePlayer;
	if (!delegatePlayer) return;
	__weak typeof(self) weakSelf = self;
	//[self.delegatePlayer.doNotReceiveGestureViews addObject:self.shrinkscreenView];
	dispatch_async(dispatch_get_main_queue(), ^{
		[weakSelf.fullscreenView.backButton setTitle:delegatePlayer.video.title forState:UIControlStateNormal];
	});
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
	self.definitionPanelView.quality = quality;
	NSString *definition = NSStringFromPLVVodQuality(quality);
	dispatch_async(dispatch_get_main_queue(), ^{
		UIButton *definitionButton = self.fullscreenView.definitionButton;
		[definitionButton setTitle:definition forState:UIControlStateNormal];
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
	});
}

- (void)setSelectedPlaybackRateDidChangeBlock:(void (^)(double))selectedPlaybackRateDidChangeBlock {
	self.playbackRatePanelView.selectedPlaybackRateDidChangeBlock = selectedPlaybackRateDidChangeBlock;
}

- (void (^)(double))selectedPlaybackRateDidChangeBlock {
	return self.playbackRatePanelView.selectedPlaybackRateDidChangeBlock;
}

#pragma mark 音视频切换（PlaybackMode）
- (void)setUpPlaybackMode:(PLVVodVideo *)video {
    if ([video canSwithPlaybackMode]) {
        self.shrinkscreenView.playModeContainerView.hidden = NO;
        self.fullscreenView.playModeContainerView.hidden = NO;
        
        [self.audioCoverPanelView setCoverUrl:video.snapshot];
        [self.view addSubview:self.audioCoverPanelView];
        [self constrainSubview:self.audioCoverPanelView toMatchWithSuperview:self.view];
        [self.view sendSubviewToBack:self.audioCoverPanelView];
        
        [self updatePlayModeContainView:video];
    } else {
        self.shrinkscreenView.playModeContainerView.hidden = YES;
        self.fullscreenView.playModeContainerView.hidden = YES;
    }
}

- (void)updatePlayModeContainView:(PLVVodVideo *)video {
    if ([video canSwithPlaybackMode]) {
        PLVVodPlaybackMode playbackMode = self.delegatePlayer.playbackMode;
        [self.shrinkscreenView switchToPlayMode:playbackMode];
        [self.fullscreenView switchToPlayMode:playbackMode];
        [self.audioCoverPanelView switchToPlayMode:playbackMode];
    }
}

- (void)updateAudioCoverAnimation:(BOOL)isPlaying {
    if (isPlaying) {
        [self.audioCoverPanelView startRotate];
    } else {
        [self.audioCoverPanelView stopRotate];
    }
}

#pragma getter --
- (UIView *)skinMaskView
{
    if (!_skinMaskView){
        _skinMaskView = [[UIView alloc] init];
    }
    
    return _skinMaskView;
}

#pragma mark - view controller

- (void)dealloc {
	[self removeOrientationObserve];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self addOrientationObserve];
	[self setupUI];
}

- (void)setupUI {
	[self updateUIForTraitCollection:self.traitCollection];
	
	self.topView = self.mainControl;
	[self.controlContainerView addSubview:self.mainControl];
	self.priorConstraints = [self constrainSubview:self.mainControl toMatchWithSuperview:self.controlContainerView];
	
	[self.view addSubview:self.gestureIndicatorView];
	[self constrainSubview:self.gestureIndicatorView toMatchWithSuperview:self.view];
	self.gestureIndicatorView.alpha = 0;
	
	// 配置控件细节
	self.subtitleLabel.text = @"";
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
	self.playbackRatePanelView.playbackRateButtonDidClick = ^(UIButton *sender) {
		[weakSelf backMainControl:sender];
	};
	
	// 链接属性
	self.brightnessSlider = self.settingsPanelView.brightnessSlider;
	self.volumeSlider = self.settingsPanelView.volumeSlider;
	
	// 自动隐藏控件
	[self fadeoutPlaybackControl];
    
    // 皮肤控件覆盖层，现实弹幕
    [self.view addSubview:self.skinMaskView];
    [self constrainSubview:self.skinMaskView toMatchWithSuperview:self.view];
    self.skinMaskView.backgroundColor = [UIColor clearColor];
    [self.view sendSubviewToBack:self.skinMaskView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }

#pragma mark - observe

- (void)addOrientationObserve {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)removeOrientationObserve {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
	UIInterfaceOrientation interfaceOrientaion = [UIApplication sharedApplication].statusBarOrientation;
	switch (interfaceOrientaion) {
		case UIInterfaceOrientationPortrait:{
			
		}break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		case UIInterfaceOrientationPortraitUpsideDown:
		case UIInterfaceOrientationUnknown:{
			
		}break;
		default:{}break;
	}
	[self updateUIForTraitCollection:self.traitCollection];
}

//- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
//		[self updateUIForTraitCollection:newCollection];
//	} completion:nil];
//}

- (void)updateUIForTraitCollection:(UITraitCollection *)collection {
	if (collection.verticalSizeClass == UIUserInterfaceSizeClassCompact) { // 横屏
		self.mainControl = self.fullscreenView;
		self.statusBarStyle = UIStatusBarStyleLightContent;
		self.shouldHideNavigationBar = YES;
	} else {
		self.mainControl = self.shrinkscreenView;
		self.statusBarStyle = UIStatusBarStyleDefault;
		self.shouldHideNavigationBar = NO;
	}
}

#pragma mark - orientation

- (void)switchScreen {
	UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		[PLVVodPlayerViewController rotateOrientation:UIInterfaceOrientationLandscapeRight];
	} else {
		[PLVVodPlayerViewController rotateOrientation:UIInterfaceOrientationPortrait];
	}
}

#pragma mark - action

- (IBAction)backMainControl:(id)sender {
	if (self.topView == self.mainControl) return;
	[self transitFromView:self.topView toView:self.mainControl];
	[self fadeoutPlaybackControl];
}

- (IBAction)switchScreenAction:(UIButton *)sender {
	[self switchScreen];
}

- (IBAction)danmuButtonAction:(UIButton *)sender {
	sender.selected = !sender.selected;
	self.fullscreenView.danmuSendButton.hidden = !sender.selected;
	if (self.enableDanmuChangeHandler) self.enableDanmuChangeHandler(self, sender.selected);
}

- (IBAction)definitionAction:(UIButton *)sender {
	[self transitToView:self.definitionPanelView];
}

- (IBAction)playbackRateAction:(UIButton *)sender {
	[self transitToView:self.playbackRatePanelView];
}

- (IBAction)backAction:(UIButton *)sender {
	// 切换到竖屏
	UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		[PLVVodPlayerViewController rotateOrientation:UIInterfaceOrientationPortrait];
	}
}

- (IBAction)shareAction:(UIButton *)sender {
	[self transitToView:self.sharePanelView];
}

- (IBAction)settingAction:(UIButton *)sender {
	[self transitToView:self.settingsPanelView];
    [self.settingsPanelView switchToPlayMode:self.delegatePlayer.playbackMode];
}

- (IBAction)snapshotAction:(UIButton *)sender {
	UIImage *snapshot = [self.delegatePlayer snapshot];
	NSLog(@"snapshot: %@", snapshot);
	// 请求图库权限
	__weak typeof(self) weakSelf = self;
	[self.class requestPhotoAuthorizationWithDelegate:self authorized:^{
		UIImageWriteToSavedPhotosAlbum(snapshot, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	}];
}

-  (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if (error == nil) {
		[self showMessage:@"截图保存成功"];
	} else {
		[self showMessage:@"截图保存失败"];
	}
}

- (IBAction)danmuAction:(UIButton *)sender {
	[self transitToView:self.danmuSendView];
}

- (void)sendDanmu {
	PLVVodDanmu *danmu = [[PLVVodDanmu alloc] init];
	danmu.content = self.danmuSendView.danmuContent;
	danmu.colorHex = self.danmuSendView.danmuColorHex;
	danmu.fontSize = self.danmuSendView.danmuFontSize;
	danmu.mode = self.danmuSendView.danmuMode;
	danmu.time = self.delegatePlayer.currentPlaybackTime;
	[danmu sendDammuWithVid:self.delegatePlayer.video.vid completion:^(NSError *error) {
		NSLog(@"send danmu error: %@", error);
	}];
}

- (IBAction)videoPlaybackModeAction:(id)sender {
    self.delegatePlayer.playbackMode = PLVVodPlaybackModeVideo;
}

- (IBAction)audioPlaybackModeAction:(id)sender {
    self.delegatePlayer.playbackMode = PLVVodPlaybackModeAudio;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self sendDanmu];
	[self backMainControl:textField];
	return NO;
}

#pragma mark - public method

- (void)showGestureIndicator {
	[UIView animateWithDuration:PLVVodAnimationDuration animations:^{
		self.gestureIndicatorView.alpha = 1;
	} completion:^(BOOL finished) {
		
	}];
}
- (void)hideGestureIndicator {
	[UIView animateWithDuration:PLVVodAnimationDuration animations:^{
		self.gestureIndicatorView.alpha = 0;
	} completion:^(BOOL finished) {
		
	}];
}

- (void)hideOrShowPlaybackControl {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if (self.topView != self.mainControl) return;
	[self backMainControl:nil];
	
	BOOL isShowing = self.controlContainerView.alpha > 0.0;
	[UIView animateWithDuration:PLVVodAnimationDuration animations:^{
		self.controlContainerView.alpha = isShowing ? 0 : 1;
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

- (void)showMessage:(NSString *)message {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[alertController dismissViewControllerAnimated:YES completion:^{}];
	}]];
	[self presentViewController:alertController animated:YES completion:^{
		
	}];
}

+ (void)requestPhotoAuthorizationWithDelegate:(UIViewController *__weak)viewController authorized:(void (^)(void))authorizedHandler {
	authorizedHandler = ^(){
		dispatch_async(dispatch_get_main_queue(), ^{
			if (authorizedHandler) authorizedHandler();
		});
	};
	
	PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
	switch (status) {
		case PHAuthorizationStatusNotDetermined:{
			// 请求权限
			[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
				switch (status) {
					case PHAuthorizationStatusAuthorized:{
						authorizedHandler();
					}break;
					default:{
						// 权限不允许
					}break;
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
				NSURL *settingURL = [NSURL URLWithString:@"App-Prefs:root=Privacy&path=PHOTOS"];
				if ([[UIApplication sharedApplication] canOpenURL:settingURL]) {
					[[UIApplication sharedApplication] openURL:settingURL];
				} else {
					NSLog(@"无法打开 URL: %@", settingURL);
				}
			}]];
			[viewController presentViewController:alertController animated:YES completion:nil];
		}break;
		default:{}break;
	}
}

// makes "subview" match the width and height of "superview" by adding the proper auto layout constraints
- (NSArray *)constrainSubview:(UIView *)subview toMatchWithSuperview:(UIView *)superview {
	subview.translatesAutoresizingMaskIntoConstraints = NO;
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(subview);
	
	NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:viewsDictionary];
	constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:viewsDictionary]];
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
	[UIView transitionFromView:fromView toView:toView duration:0.25 options:options completion:^(BOOL finished) {
		if (priorConstraints != nil) {
			[self.controlContainerView removeConstraints:priorConstraints];
		}
	}];
	self.priorConstraints = [self constrainSubview:toView toMatchWithSuperview:self.controlContainerView];
	self.topView = toView;
}

@end
