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
{
	UIStatusBarStyle _statusBarStyle;
	BOOL _shouldHideStatusBar;
	double _playbackRate;
}

@synthesize statusBarStyle = _statusBarStyle;
@synthesize shouldHideStatusBar = _shouldHideStatusBar;
@synthesize playbackRate = _playbackRate;

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
	if (topView && _topView != topView && topView != self.fullscreenView && topView != self.shrinkscreenView) {
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
	dispatch_async(dispatch_get_main_queue(), ^{
		weakSelf.fullscreenView.titleLabel.text = delegatePlayer.video.title;
	});
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
		[self.fullscreenView.definitionButton setTitle:definition forState:UIControlStateNormal];
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
	self.topView = self.mainControl;
	[self.controlContainerView addSubview:self.mainControl];
	self.priorConstraints = [self constrainSubview:self.mainControl toMatchWithSuperview:self.controlContainerView];
	
	// 配置控件细节
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
	UIDevice *device = [UIDevice currentDevice];
	[device beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
	[self orientationDidChanged:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	[self interfaceOrientationDidChange:nil];
}

- (void)removeOrientationObserve {
	UIDevice *device = [UIDevice currentDevice];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)orientationDidChanged:(NSNotification *)notification {
	UIDevice *device = [UIDevice currentDevice];
	switch (device.orientation) {
		case UIDeviceOrientationPortrait:{
			
		}break;
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
		case UIDeviceOrientationPortraitUpsideDown:{
			
		}break;
		default:{}break;
	}
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
	UIInterfaceOrientation interfaceOrientaion = [UIApplication sharedApplication].statusBarOrientation;
	switch (interfaceOrientaion) {
		case UIInterfaceOrientationPortrait:{
			self.mainControl = self.shrinkscreenView;
			self.statusBarStyle = UIStatusBarStyleDefault;
		}break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		case UIInterfaceOrientationPortraitUpsideDown:
		case UIInterfaceOrientationUnknown:{
			self.mainControl = self.fullscreenView;
			self.statusBarStyle = UIStatusBarStyleLightContent;
		}break;
		default:{}break;
	}
}

#pragma mark - tool

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
	//NSLog(@"%s - %@", __FUNCTION__, [NSThread currentThread]);
	if (self.topView == self.mainControl) return;
	[self transitFromView:self.topView toView:self.mainControl];
	[self fadeoutPlaybackControl];
}

- (IBAction)switchScreenAction:(UIButton *)sender {
	[self switchScreen];
	//NSLog(@"切换：%@", sender.selected?@"全屏":@"半屏");
}

- (IBAction)switchDmAction:(UIButton *)sender {
	sender.selected = !sender.selected;
	//NSLog(@"弹幕：%s", sender.selected?"开":"关");
	self.fullscreenView.dmButton.hidden = !sender.selected;
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self sendDanmu];
	[self backMainControl:textField];
	return NO;
}

#pragma mark - public method

- (void)showIndicator {
	[self transitToView:self.gestureIndicatorView];
}
- (void)hideIndicator {
	[self backMainControl:self.gestureIndicatorView];
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

@end
