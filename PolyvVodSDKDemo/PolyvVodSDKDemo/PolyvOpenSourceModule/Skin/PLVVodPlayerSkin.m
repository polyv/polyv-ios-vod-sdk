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
		[self transitFromView:_mainControl toView:mainControl];
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
	if (topView && _topView != topView && topView != self.mainControl) {
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
	UIDevice *device = [UIDevice currentDevice];
	switch (device.orientation) {
		case UIDeviceOrientationPortrait:{
			self.mainControl = self.shrinkscreenView;
		}break;
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
		case UIDeviceOrientationPortraitUpsideDown:{
			self.mainControl = self.fullscreenView;
		}break;
		default:{}break;
	}
	//NSLog(@"main control: %@", self.mainControl);
	[self.view addSubview:self.mainControl];
	self.priorConstraints = [self constrainSubview:self.mainControl toMatchWithSuperview:self.view];
	
	// 配置控件细节
	UIImage *playbackThumb = [UIImage imageNamed:@"plv_vod_btn_slider_player"];
	[self.fullscreenView.playbackSlider setThumbImage:playbackThumb forState:UIControlStateNormal];
	[self.shrinkscreenView.playbackSlider setThumbImage:playbackThumb forState:UIControlStateNormal];
	
	UIImage *settingThumb = [UIImage imageNamed:@"plv_vod_btn_slider_settings"];
	[self.settingsPanelView.volumeSlider setThumbImage:settingThumb forState:UIControlStateNormal];
	[self.settingsPanelView.brightnessSlider setThumbImage:settingThumb forState:UIControlStateNormal];
	
	// 链接属性
	self.brightnessSlider = self.settingsPanelView.brightnessSlider;
	self.volumeSlider = self.settingsPanelView.volumeSlider;
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
	[UIView transitionFromView:fromView
						toView:toView
					  duration:0.25
					   options:options
					completion:^(BOOL finished) {
						if (priorConstraints != nil) {
							[self.view removeConstraints:priorConstraints];
						}
					}];
	self.priorConstraints = [self constrainSubview:toView toMatchWithSuperview:self.view];
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
	NSLog(@"%s - %@", __FUNCTION__, [NSThread currentThread]);
	if (self.topView == self.mainControl) {
		return;
	}
	[self transitFromView:self.topView toView:self.mainControl];
	self.topView = self.mainControl;
}

- (IBAction)switchScreenAction:(UIButton *)sender {
	[self switchScreen];
	NSLog(@"切换：%@", sender.selected?@"全屏":@"半屏");
}

- (IBAction)switchDmAction:(UIButton *)sender {
	sender.selected = !sender.selected;
	NSLog(@"弹幕：%s", sender.selected?"开":"关");
	self.fullscreenView.dmButton.hidden = !sender.selected;
}

- (IBAction)definitionAction:(UIButton *)sender {
	[self transitToView:self.definitionPanelView];
	self.topView = self.definitionPanelView;
}

- (IBAction)playbackRateAction:(UIButton *)sender {
	[self transitToView:self.playbackRatePanelView];
	self.topView = self.playbackRatePanelView;
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
	self.topView = self.sharePanelView;
}

- (IBAction)settingAction:(UIButton *)sender {
	[self transitToView:self.settingsPanelView];
	self.topView = self.settingsPanelView;
}

- (IBAction)snapshotAction:(UIButton *)sender {
	UIImage *snapshot = [self.delegatePlayer snapshot];
	NSLog(@"snapshot: %@", snapshot);
}

- (IBAction)danmuAction:(UIButton *)sender {
	[self transitToView:self.danmuSendView];
	self.topView = self.danmuSendView;
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
	self.topView = self.gestureIndicatorView;
}
- (void)hideIndicator {
	[self backMainControl:self.gestureIndicatorView];
}

@end
