//
//  PLVVodSkinPlayerController.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodSkinPlayerController.h"
#import "PLVVodPlayerSkin.h"
#import "PLVVodDanmuManager.h"
#import "PLVTimer.h"
#import "PLVVodDanmu+PLVVod.h"
#import "PLVVodExamViewController.h"
#import <PLVVodSDK/PLVVodExam.h>
#import <PLVSubtitle/PLVSubtitleManager.h>
#import <MediaPlayer/MediaPlayer.h>
#import <PLVMarquee/PLVMarquee.h>
#import <MediaPlayer/MPVolumeView.h>


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PLVVodSkinPlayerController ()

@property (weak, nonatomic) IBOutlet UIView *skinView;

/// 弹幕管理
@property (nonatomic, strong) PLVVodDanmuManager *danmuManager;

/// 播放刷新定时器
@property (nonatomic, strong) PLVTimer *playbackTimer;

/// 问答控制器
@property (nonatomic, strong) PLVVodExamViewController *examViewController;

/// 字幕管理器
@property (nonatomic, strong) PLVSubtitleManager *subtitleManager;

/// 视频截图
@property (nonatomic, strong) UIImage *coverImage;

/// 滑动进度
@property (nonatomic, assign) NSTimeInterval scrubTime;

/// 修改系统音量
@property (nonatomic, strong) MPVolumeView *volumeView;

@end

@implementation PLVVodSkinPlayerController

#pragma mark - property

- (void)setVideo:(PLVVodVideo *)video quality:(PLVVodQuality)quality {
	// !!!: 这部分的功能的控制，由于与每次设置的 video 有关，因此必须在设置 PLVVodVideo 对象之前，或在这里设置。
	{
		// 开启广告
		//self.enableAd = YES;
		
		// 开启片头
		//self.enableTeaser = YES;
		
		// 记忆播放位置
		//self.rememberLastPosition = YES;
	}
	
	[super setVideo:video quality:quality];
	if (!video.available) return;
	dispatch_async(dispatch_get_main_queue(), ^{
        [self setupPlaybackMode];
		[self setupAd];
		[self setupDanmu];
		[self setupExam];
		[self setupSubtitle];
		
		// 设置控制中心播放信息
		self.coverImage = nil;
		[self setupPlaybackInfo];
	});
}

- (void)setExamViewController:(PLVVodExamViewController *)examViewController {
	if (_examViewController) {
		[_examViewController.view removeFromSuperview];
		[_examViewController removeFromParentViewController];
	}
	_examViewController = examViewController;
}

#pragma mark - view controller

- (void)dealloc {
	[self.playbackTimer cancel];
	self.playbackTimer = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	[self setupSkin];
	
	[self addObserver];
	
	__weak typeof(self) weakSelf = self;
	self.playbackTimer = [PLVTimer repeatWithInterval:0.2 repeatBlock:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			// 同步显示弹幕
			weakSelf.danmuManager.currentTime = weakSelf.currentPlaybackTime;
			//NSLog(@"danmu time: %f", weakSelf.danmuManager.currentTime);
			[weakSelf.danmuManager synchronouslyShowDanmu];

			/// 同步显示问答
			weakSelf.examViewController.currentTime = weakSelf.currentPlaybackTime;
			if (weakSelf.playbackState == PLVVodPlaybackStatePlaying) {
				[weakSelf.examViewController synchronouslyShowExam];
			}

			/// 同步显示字幕
			[weakSelf.subtitleManager showSubtitleWithTime:weakSelf.currentPlaybackTime];
		});
	}];
	
	// 配置手势
	self.gestureCallback = ^(PLVVodPlayerViewController *player, UIGestureRecognizer *recognizer, PLVVodGestureType gestureType) {
		[weakSelf handleGesture:recognizer gestureType:gestureType];
	};
	
	// 开启后台播放
	//self.enableBackgroundPlayback = YES;
	
	// 自动播放
	//self.autoplay = NO;
	
	// 设置跑马灯
	//PLVMarquee *marquee = [[PLVMarquee alloc] init];
	//marquee.type = PLVMarqueeTypeRollFade;
	//marquee.maxFadeInterval = 5;
	//self.marquee = marquee;
	
	// 错误回调
	self.playerErrorHandler = ^(PLVVodPlayerViewController *player, NSError *error) {
		NSLog(@"player error: %@", error);
        
	};
    
    // 恢复播放
    self.playbackRecoveryHandle = ^(PLVVodPlayerViewController *player) {
        
        // 应用层重试，减小sdk出错概率，降低风险
        [weakSelf setCurrentPlaybackTime:weakSelf.lastPosition];
        // 对于某些场景需要再次调用play函数才能播放
        [weakSelf play];
    };
}

- (void)viewDidLayoutSubviews {
	//NSLog(@"layout guide: %f - %f", self.topLayoutGuide.length, self.bottomLayoutGuide.length);
	self.danmuManager.insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)setupSkin {
	PLVVodPlayerSkin *skin = [[PLVVodPlayerSkin alloc] initWithNibName:nil bundle:nil];
	__weak typeof(skin) _skin = skin;
	[self addChildViewController:skin];
	UIView *skinView = skin.view;
	[self.view addSubview:skinView];
	UIView *playerView = self.view;
	skinView.translatesAutoresizingMaskIntoConstraints = NO;
	NSDictionary *views = NSDictionaryOfVariableBindings(skinView, playerView);
	[playerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[skinView]|" options:0 metrics:nil views:views]];
	[playerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[skinView]|" options:0 metrics:nil views:views]];
	
	self.skinView = skinView;
	self.playerControl = skin;
	
	__weak typeof(self) weakSelf = self;
	// 配置皮肤控件事件
	skin.selectedSubtitleKeyDidChangeBlock = ^(NSString *selectedSubtitleKey) {
		[weakSelf setupSubtitle];
	};
	
	// 配置载入状态
	self.loadingHandler = ^(BOOL isLoading) {
		dispatch_async(dispatch_get_main_queue(), ^{
			isLoading ? [_skin.loadingIndicator startAnimating] : [_skin.loadingIndicator stopAnimating];
		});
	};
}

- (void)setupAd {
	self.adPlayer.adDidTapBlock = ^(PLVVodAd *ad) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:ad.address]];
	};
	self.adPlayer.canSkip = YES;
	
	// ad player UI
	[self.adPlayer.muteButton setImage:[UIImage imageNamed:@"plv_ad_btn_volume_on"] forState:UIControlStateNormal];
	[self.adPlayer.muteButton setImage:[UIImage imageNamed:@"plv_ad_btn_volume_off"] forState:UIControlStateSelected];
	[self.adPlayer.muteButton sizeToFit];
	[self.adPlayer.playButton setImage:[UIImage imageNamed:@"plv_vod_btn_play_60"] forState:UIControlStateNormal];
	[self.adPlayer.playButton sizeToFit];
	self.adPlayer.timeLabel.shadowColor = [UIColor grayColor];
	self.adPlayer.timeLabel.shadowOffset = CGSizeMake(1, 1);
}

- (void)setupDanmu {
	// 清除监听
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLVVodDanmuDidSendNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLVVodDanmuWillSendNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:PLVVodDanmuEndSendNotification object:nil];
	
	// 配置弹幕
	__weak typeof(self) weakSelf = self;
	[PLVVodDanmu requestDanmusWithVid:self.video.vid completion:^(NSArray<PLVVodDanmu *> *danmus, NSError *error) {
        
        __block PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)weakSelf.playerControl;
		__block PLVVodDanmuManager *danmuManager = [[PLVVodDanmuManager alloc] initWithDanmus:danmus inView:skin.skinMaskView/*weakSelf.maskView*/];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!skin.enableDanmu) {
				[danmuManager stop];
			} else {
				[danmuManager resume];
			}
			skin.enableDanmuChangeHandler = ^(PLVVodPlayerSkin *skin, BOOL enableDanmu) {
				if (!skin.enableDanmu) {
					[danmuManager stop];
				} else {
					[danmuManager resume];
				}
			};
			weakSelf.danmuManager = danmuManager;
		});
	}];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(danmuDidSend:) name:PLVVodDanmuDidSendNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(danmuWillSend:) name:PLVVodDanmuWillSendNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(danmuDidEnd:) name:PLVVodDanmuEndSendNotification object:nil];
}

- (void)setupExam {
	PLVVodExamViewController *examViewController = [[PLVVodExamViewController alloc] initWithNibName:nil bundle:nil];
	[self.view addSubview:examViewController.view];
	examViewController.view.frame = self.view.bounds;
	[self addChildViewController:examViewController];
	self.examViewController = examViewController;
	__weak typeof(self) weakSelf = self;
	self.examViewController.examWillShowHandler = ^(PLVVodExam *exam) {
		[weakSelf pause];
	};
	self.examViewController.examDidCompleteHandler = ^(PLVVodExam *exam, NSTimeInterval backTime) {
		if (backTime >= 0) {
			weakSelf.currentPlaybackTime = backTime;
		}
		[weakSelf play];
	};
	[PLVVodExam requestVideoWithVid:self.video.vid completion:^(NSArray<PLVVodExam *> *exams, NSError *error) {
		weakSelf.examViewController.exams = exams;
	}];
}

- (void)setupSubtitle {
	PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
	NSString *srtUrl = self.video.srts[skin.selectedSubtitleKey];
	//srtUrl = @"https://static.polyv.net/usrt/f/f46ead66de/srt/b3ecc235-a47c-4c22-af29-0aab234b1b69.srt";
	if (!srtUrl.length) {
		self.subtitleManager = [PLVSubtitleManager managerWithSubtitle:nil label:skin.subtitleLabel topLabel:skin.subtitleTopLabel error:nil];
	}
	__weak typeof(self) weakSelf = self;
	// 获取字幕内容并设置字幕
	[self.class requestStringWithUrl:srtUrl completion:^(NSString *string) {
		NSString *srtContent = string;
		weakSelf.subtitleManager = [PLVSubtitleManager managerWithSubtitle:srtContent label:skin.subtitleLabel topLabel:skin.subtitleTopLabel error:nil];
	}];
}

// 配置控制中心播放
- (void)setupPlaybackInfo {
	if (self.coverImage) {
		[self setupPlaybackInfoWithCover:self.coverImage];
		return;
	}
	__weak typeof(self) weakSelf = self;
	[[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:self.video.snapshot] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (!data.length) return;
		weakSelf.coverImage = [UIImage imageWithData:data];
		[weakSelf setupPlaybackInfoWithCover:weakSelf.coverImage];
	}] resume];
}
- (void)setupPlaybackInfoWithCover:(UIImage *)cover {
	NSMutableDictionary *playbackInfo = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo.mutableCopy;
	if (!playbackInfo.count) playbackInfo = [NSMutableDictionary dictionary];
	playbackInfo[MPMediaItemPropertyTitle] = self.video.title;
	playbackInfo[MPMediaItemPropertyPlaybackDuration] = @(self.video.duration);
	MPMediaItemArtwork *imageItem = [[MPMediaItemArtwork alloc] initWithImage:cover];
	playbackInfo[MPMediaItemPropertyArtwork] = imageItem;
	[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playbackInfo;
}

// 设置播放模式
- (void)setupPlaybackMode {
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin setUpPlaybackMode:self.video];
}

#pragma mark override
// 更新播放模式更新成功回调
- (void)playbackModeDidChange {
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin updatePlayModeContainView:self.video];
}

- (void)updateAudioCoverAnimation:(BOOL)isPlaying {
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin updateAudioCoverAnimation:isPlaying];
}

#pragma mark gesture

- (void)handleGesture:(UIGestureRecognizer *)recognizer gestureType:(PLVVodGestureType)gestureType {
	switch (gestureType) {
		case PLVVodGestureTypeTap:{
			PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
			[skin hideOrShowPlaybackControl];
		}break;
		case PLVVodGestureTypeDoubleTap:{
			[self playPauseAction:nil];
		}break;
		case PLVVodGestureTypeLeftSideDownPan:
		case PLVVodGestureTypeLeftSideUpPan:{
			[self changeBrightnessWithGesture:recognizer gestureType:gestureType];
		}break;
		case PLVVodGestureTypeRightSideDownPan:
		case PLVVodGestureTypeRightSideUpPan:{
			[self changeVolumeWithGesture:recognizer gestureType:gestureType];
		}break;
		case PLVVodGestureTypeLeftPan:
		case PLVVodGestureTypeRightPan:{
			[self changeProgressWithGesture:recognizer gestureType:gestureType];
		}break;
		default:{}break;
	}
}

- (void)changeBrightnessWithGesture:(UIGestureRecognizer *)recognizer gestureType:(PLVVodGestureType)gestureType {
	UIPanGestureRecognizer *pan = nil;
	if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		pan = (UIPanGestureRecognizer *)recognizer;
	} else {
		return;
	}
	
	// 手势所在视图
	UIView *gestureView = pan.view;
	// 速率
	CGPoint veloctyPoint = [pan velocityInView:gestureView];
	// 皮肤
	PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
	
	switch (pan.state) {
		case UIGestureRecognizerStateBegan: {
			[skin showGestureIndicator];
		} break;
		case UIGestureRecognizerStateChanged: {
			[UIScreen mainScreen].brightness -= veloctyPoint.y/10000;
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			formatter.numberStyle = NSNumberFormatterPercentStyle;
			NSString *text = [formatter stringFromNumber:@([UIScreen mainScreen].brightness)];
			skin.gestureIndicatorView.type = PLVVodGestureIndicatorTypeBrightness;
			skin.gestureIndicatorView.text = text;
		} break;
		case UIGestureRecognizerStateEnded: {
			[skin hideGestureIndicator];
		} break;
		default: {} break;
	}
}

- (void)changeVolumeWithGesture:(UIGestureRecognizer *)recognizer gestureType:(PLVVodGestureType)gestureType {
    UIPanGestureRecognizer *pan = nil;
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        pan = (UIPanGestureRecognizer *)recognizer;
    } else {
        return;
    }
    
    // 手势所在视图
    UIView *gestureView = pan.view;
    // 速率
    CGPoint veloctyPoint = [pan velocityInView:gestureView];
    // 皮肤
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    
    BOOL isSystemVolume = YES;
    if (isSystemVolume){
        // 系统音量调节
        switch (pan.state) {
            case UIGestureRecognizerStateBegan: {
            } break;
            case UIGestureRecognizerStateChanged: {
                self.playbackVolume -= veloctyPoint.y/10000;
                
                [self changeVolume:self.playbackVolume];
            } break;
            case UIGestureRecognizerStateEnded: {
            } break;
            default: {} break;
        }
    }
    else{
        // App 音量调节
        switch (pan.state) {
            case UIGestureRecognizerStateBegan: {
                [skin showGestureIndicator];
            } break;
            case UIGestureRecognizerStateChanged: {
                self.playbackVolume -= veloctyPoint.y/10000;
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterPercentStyle;
                NSString *text = [formatter stringFromNumber:@(self.playbackVolume)];
                skin.gestureIndicatorView.type = PLVVodGestureIndicatorTypeVolume;
                skin.gestureIndicatorView.text = text;
            } break;
            case UIGestureRecognizerStateEnded: {
                [skin hideGestureIndicator];
            } break;
            default: {} break;
        }
    }
}

- (void)changeVolume:(CGFloat)distance {
    if (self.volumeView == nil) {
        self.volumeView = [[MPVolumeView alloc] init];
        self.volumeView.showsVolumeSlider = YES;
    }
    
    for (UIView *v in self.volumeView.subviews) {
        if ([v.class.description isEqualToString:@"MPVolumeSlider"]) {
            UISlider *volumeSlider = (UISlider *)v;
            [volumeSlider setValue:distance];
            [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
}

- (void)changeProgressWithGesture:(UIGestureRecognizer *)recognizer gestureType:(PLVVodGestureType)gestureType {
	UIPanGestureRecognizer *pan = nil;
	if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		pan = (UIPanGestureRecognizer *)recognizer;
	} else {
		return;
	}
	
	// 手势所在视图
	UIView *gestureView = pan.view;
	// 速率
	CGPoint veloctyPoint = [pan velocityInView:gestureView];
	// 皮肤
	PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
	
	switch (pan.state) {
		case UIGestureRecognizerStateBegan: { // 开始移动
			self.scrubTime = self.currentPlaybackTime;
			[skin showGestureIndicator];
		} break;
		case UIGestureRecognizerStateChanged: { // 正在移动
			self.scrubTime += veloctyPoint.x / 200;
			if (self.scrubTime > self.duration) { self.scrubTime = self.duration;}
			if (self.scrubTime < 0) { self.scrubTime = 0; }
			NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
			NSString *currentTimeString = [formatter stringFromTimeInterval:self.scrubTime];
			NSString *durationString = [formatter stringFromTimeInterval:self.duration];
			NSString *text = [NSString stringWithFormat:@"%@ / %@", currentTimeString, durationString];
			skin.gestureIndicatorView.text = text;
			if (gestureType == PLVVodGestureTypeLeftPan) {
				skin.gestureIndicatorView.type = PLVVodGestureIndicatorTypeProgressDown;
			} else {
				skin.gestureIndicatorView.type = PLVVodGestureIndicatorTypeProgressUp;
			}
		} break;
		case UIGestureRecognizerStateEnded: { // 移动停止
			self.currentPlaybackTime = self.scrubTime;
			self.scrubTime = 0;
			[skin hideGestureIndicator];
		} break;
		default: {} break;
	}
}

#pragma mark - tool

+ (void)requestStringWithUrl:(NSString *)url completion:(void (^)(NSString *string))completion {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (string.length) {
			if (completion) completion(string);
		}
	}] resume];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.destinationViewController isKindOfClass:[PLVVodPlayerSkin class]]) {
		self.playerControl = segue.destinationViewController;
	}
}

#pragma mark - observer

- (void)addObserver {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adStateDidChange) name:PLVVodPlayerAdStateDidChangeNotification object:nil];
	[self adStateDidChange];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teaserStateDidChange) name:PLVVodPlayerTeaserStateDidChangeNotification object:nil];
	[self teaserStateDidChange];
	
	// 接收远程事件
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlEventDidReceive:) name:PLVVodRemoteControlEventDidReceiveNotification object:nil];
}

- (void)teaserStateDidChange {
	switch (self.teaserState) {
		case PLVVodAssetStateLoading:
		case PLVVodAssetStatePlaying:{
			dispatch_async(dispatch_get_main_queue(), ^{
				self.skinView.hidden = YES;
			});
		}break;
		case PLVVodAssetStateFinished:{
			dispatch_async(dispatch_get_main_queue(), ^{
				self.skinView.hidden = NO;
			});
		}break;
		default:{}break;
	}
}

- (void)adStateDidChange {
//	if (self.playbackState == PLVVodPlaybackStatePaused || self.playbackState == PLVVodPlaybackStatePlaying) {
//		dispatch_async(dispatch_get_main_queue(), ^{
//			self.skinView.hidden = NO;
//		});
//		return;
//	}
	switch (self.adPlayer.state) {
		case PLVVodAssetStateLoading:
		case PLVVodAssetStatePlaying:{
			dispatch_async(dispatch_get_main_queue(), ^{
				self.skinView.hidden = YES;
			});
		}break;
		case PLVVodAssetStateFinished:{
			dispatch_async(dispatch_get_main_queue(), ^{
				self.skinView.hidden = NO;
			});
		}break;
		default:{}break;
	}
}

- (void)danmuDidSend:(NSNotification *)notification {
	PLVVodDanmu *danmu = notification.object;
	//NSLog(@"danmu: %@", danmu);
	[self.danmuManager insetDanmu:danmu];
}

- (void)danmuWillSend:(NSNotification *)notification {
	[self pause];
	[self.danmuManager pause];
}

- (void)danmuDidEnd:(NSNotification *)notification {
	[self.danmuManager resume];
	[self play];
}

// 处理远程事件
- (void)remoteControlEventDidReceive:(NSNotification *)notification {
	UIEvent *event = notification.userInfo[PLVVodRemoteControlEventKey];
	if (event.type == UIEventTypeRemoteControl) {
		// 更新控制中心
		NSMutableDictionary *playbackInfo = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo.mutableCopy;
		if (!playbackInfo.count)
			playbackInfo = [NSMutableDictionary dictionary];
		playbackInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(self.currentPlaybackTime);
		playbackInfo[MPNowPlayingInfoPropertyPlaybackRate] = @(self.playbackRate);
		playbackInfo[MPMediaItemPropertyPlaybackDuration] = @(self.duration);
		[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playbackInfo;
		
		switch (event.subtype) {
			case UIEventSubtypeRemoteControlPause:{
				[self pause];
			}break;
			case UIEventSubtypeRemoteControlPlay:{
				[self play];
			}break;
			case UIEventSubtypeRemoteControlTogglePlayPause:{
				[self playPauseAction:nil];
			}break;
			case UIEventSubtypeRemoteControlPreviousTrack:{
				
			}break;
			case UIEventSubtypeRemoteControlNextTrack:{
				
			}break;
			case 5:{
				
			}break;
			default:{}break;
		}
	}
}

@end
