//
//  PLVVodSkinPlayerController.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodSkinPlayerController.h"
#import "PLVVodPlayerSkin.h"
#import "PLVVodDanmu+PLVVod.h"
#import "PLVVodExamViewController.h"
#import <PLVVodSDK/PLVVodExam.h>
#import <PLVSubtitle/PLVSubtitleManager.h>
#import <MediaPlayer/MediaPlayer.h>
#import <PLVMarquee/PLVMarquee.h>
#import <MediaPlayer/MPVolumeView.h>
#import <AlicloudUtils/AlicloudReachabilityManager.h>
#import <PLVVodSDK/PLVVodDownloadManager.h>
#import <PLVVodSDK/PLVVodLocalVideo.h>
#import <AVFoundation/AVFoundation.h>

#if __has_include(<PLVVodDanmu/PLVVodDanmuManager.h>)
#import <PLVVodDanmu/PLVVodDanmuManager.h>
#else
#import "PLVVodDanmuManager.h"
#endif
#if __has_include(<PLVTimer/PLVTimer.h>)
#import <PLVTimer/PLVTimer.h>
#else
#import "PLVTimer.h"
#endif
#ifdef PLVCastFeature
#import "PLVCastBusinessManager.h" // 若需投屏功能，请解开此注释
#endif

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

NSString *PLVVodPlaybackRecoveryNotification = @"PLVVodPlaybackRecoveryNotification";
NSString *PLVVodADAndTeasersPlayFinishNotification = @"PLVVodADAndTeasersPlayFinishNotification";

static NSString * const PLVVodMaxPositionKey = @"net.polyv.sdk.vod.maxPosition";

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
@property (nonatomic, assign) double currentVolume;

/// 视频播放判断网络类型功能所需的延迟操作事件
@property (nonatomic, copy) void (^networkTipsConfirmBlock) (void);

/// 是否允许4g网络播放，用于记录用户允许的网络类型
@property (nonatomic, assign) BOOL allow4gNetwork;

/// 是否需要隐藏播放错误提示
@property (nonatomic, assign) BOOL hidePlayError;

// 上次执行播放进度回调 playbackTimeHandler 的播放进度
@property (nonatomic, assign) NSTimeInterval lastPlaybackTime;

/// 是否处于长按快进的状态中，默认为 NO
@property (nonatomic, assign) BOOL longPressForward;
// 长按快进之前播放的倍速，默认为 1.0
@property (nonatomic, assign) double originPlaybackRate;

/// 当前视频在当前设备播放达到的最长进度，用于属性 partlyDragging 对用户未观看部分进行限制拖拽
@property (nonatomic, assign) NSTimeInterval maxPosition;

/// 记录最长播放进度使用的计时器
@property (nonatomic, strong) NSTimer *markMaxPositionTimer;

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
    
    /// 封面图无需关心网络类型
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupCoverWithVideo:video];
    });
    
    /// 因setVideo即会开始请求视频数据，因此需在此判断网络类型
    // 若无需’视频播放判断网络类型‘功能，可将此段判断注释
    if (self.allow4gNetwork == NO && ![self checkVideoWillPlayLocal:video]) {
        AlicloudReachabilityManager * reachability = [AlicloudReachabilityManager shareInstance];
        if (reachability.currentNetworkStatus >= AlicloudReachableVia2G){ // 移动网络
            __weak typeof(self) weakSelf = self;
            self.networkTipsConfirmBlock = ^{
                [weakSelf setVideo:video quality:quality];
            };
            dispatch_async(dispatch_get_main_queue(), ^{
                PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)self.playerControl;
                [skin.loadingIndicator stopAnimating];
                [self networkStatusDidChange:nil];
            });
            return;
        }
    }
	
	[super setVideo:video quality:quality];
	if (!video.available) return;
	dispatch_async(dispatch_get_main_queue(), ^{
        [self setupPlaybackMode];
        [self setupAd];
		[self setupDanmu];
		[self setupExam];
		[self setupSubtitle];
        // 设置播放打点信息
        [self setVideoPlayTips];
        // 皮肤更新
        [self updateSkin];

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

- (NSTimeInterval)maxPosition {
    NSTimeInterval maxPosition = 0.0;
    NSDictionary *maxPositionDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:PLVVodMaxPositionKey];
    if (maxPositionDict.count) {
        maxPosition = [maxPositionDict[self.video.vid] doubleValue];
        if (isnan(maxPosition))
            maxPosition = 0.0;
    }
    return maxPosition;
}

- (void)setMaxPosition:(NSTimeInterval)maxPosition {
    if (self.restrictedDragging == NO) {
        return;
    }
    
    if (maxPosition <= 0 || maxPosition <= self.maxPosition) {
//        NSLog(@"当前进度小于0，或低于历史记录最长播放进度，不保存");
        return;
    }
    
    NSString * vidStr = self.video.vid;
    if (vidStr == nil || ![vidStr isKindOfClass: [NSString class]] || vidStr.length == 0) {
        NSLog(@"vid为空,无法保存播放进度");
        return;
    }
    
    NSMutableDictionary *maxPositionDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:PLVVodMaxPositionKey].mutableCopy;
    if (maxPositionDict == nil) {
        maxPositionDict = [[NSMutableDictionary alloc] init];
    }
    maxPositionDict[vidStr] = @(maxPosition);
    [[NSUserDefaults standardUserDefaults] setObject:maxPositionDict forKey:PLVVodMaxPositionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - view controller

- (void)dealloc {
	[self.playbackTimer cancel];
	self.playbackTimer = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	
    self.longPressPlaybackRate = 2.0;
    self.originPlaybackRate = self.playbackRate;
    
	[self setupSkin];
	
	[self addObserver];
    [self addTimer];
    
	__weak typeof(self) weakSelf = self;
    __block NSInteger repeatCount = 0;
	self.playbackTimer = [PLVTimer repeatWithInterval:0.2 repeatBlock:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			// 同步显示弹幕
            PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)weakSelf.playerControl;
            if (skin.enableDanmu){
                weakSelf.danmuManager.currentTime = weakSelf.currentPlaybackTime;
                [weakSelf.danmuManager synchronouslyShowDanmu];
            }

			/// 同步显示问答
			weakSelf.examViewController.currentTime = weakSelf.currentPlaybackTime;
			if (weakSelf.playbackState == PLVVodPlaybackStatePlaying) {
				[weakSelf.examViewController synchronouslyShowExam];
			}

			/// 同步显示字幕
			[weakSelf.subtitleManager showSubtitleWithTime:weakSelf.currentPlaybackTime];
            
            /// 隐藏播放错误提示
            if (weakSelf.hidePlayError && PLVVodPlaybackStatePlaying == weakSelf.playbackState){
                PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)weakSelf.playerControl;
                [skin hidePlayErrorTips];
                weakSelf.hidePlayError = NO;
            }
            
            // 回调现在播放到第几秒
            if (weakSelf.lastPlaybackTime != weakSelf.currentPlaybackTime) {
                !weakSelf.playbackTimeHandler ?: weakSelf.playbackTimeHandler(weakSelf.currentPlaybackTime);
                weakSelf.lastPlaybackTime = weakSelf.currentPlaybackTime;
            }
            
            // 更新加载速度
            if (!weakSelf.localPlayback){
                repeatCount ++;
                if (0 == repeatCount%2){
                    [weakSelf updateLoadSpeed];
                }
            }
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
    
    PLVMarquee *marquee = [[PLVMarquee alloc] init];
    marquee.type = PLVMarqueeTypeRoll;
    marquee.displayDuration = 10;
    marquee.maxFadeInterval = 5*60;
    marquee.maxRollInterval = 5*60;
//    marquee.maxFadeInterval = 5;
    self.marquee = marquee;
	
	// 错误回调
	self.playerErrorHandler = ^(PLVVodPlayerViewController *player, NSError *error) {
		NSLog(@"player error: %@", error);
        [weakSelf handlePlayError:player error:error];
	};
    
    // 恢复播放
    self.playbackRecoveryHandle = ^(PLVVodPlayerViewController *player) {
        
        // 应用层重试，减小sdk出错概率，降低风险
        [weakSelf setCurrentPlaybackTime:weakSelf.lastPosition];
        // 对于某些场景需要再次调用play函数才能播放
        [weakSelf play];
    };
    
    // 若需投屏功能，请解开以下注释
    // 仅在投屏信息设置有效 及 ‘防录屏’开关为NO 时投屏按钮会显示
#ifdef PLVCastFeature
    if ([PLVCastBusinessManager authorizationInfoIsLegal] && self.videoCaptureProtect == NO) {
        PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
        skin.castButton.hidden = NO;
        skin.castButtonInFullScreen.hidden = NO;
    }
#endif
}

#pragma mark - Timer Related

- (void)addTimer {
    if (self.restrictedDragging && _markMaxPositionTimer == nil) {
        self.markMaxPositionTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(rememberMaxPosition) userInfo:nil repeats:YES];
    }
}

- (void)removeTimer {
    [_markMaxPositionTimer invalidate];
    _markMaxPositionTimer = nil;
}

- (void)stopAndRestartTimer:(BOOL)stop {
    if (stop) {
        [self removeTimer];
    } else {
        [self addTimer];
    }
}

- (void)rememberMaxPosition {
    self.maxPosition = self.currentPlaybackTime;
}

#pragma mark - 播放网络状态判断
- (void)networkStatusDidChange:(NSNotification *)notification {
    if (notification) {
        if ([self.video isKindOfClass:[PLVVodLocalVideo class]]) {
            return;
        }else{
            if ([self checkVideoWillPlayLocal:self.video]) {
                return;
            }
        }
    }
    
    AlicloudReachabilityManager * reachability = [AlicloudReachabilityManager shareInstance];
    
    if (reachability.currentNetworkStatus == AlicloudReachableViaWiFi){ // WiFi
        
        dispatch_async(dispatch_get_main_queue(), ^{
            PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)self.playerControl;
            [skin hideNetworkTips];
            
            [self play];

            if (self.networkTipsConfirmBlock) {
                
                self.networkTipsConfirmBlock();
                self.networkTipsConfirmBlock = nil;
            }
        });
        
    }else if (reachability.currentNetworkStatus >= AlicloudReachableVia2G){ // 移动网络

        if (self.allow4gNetwork) { return; }
        
        // 若播放器播放中
        if (self.playbackState == PLVVodPlaybackStatePlaying) { [self pause]; }
        
        __weak typeof(self) weakSelf = self;
        PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)self.playerControl;
        dispatch_async(dispatch_get_main_queue(), ^{
            PLVVodNetworkTipsView * tipsV = [skin showNetworkTips];
            __weak typeof(tipsV) weakTipsV = tipsV;
            
            if (tipsV.playBtnClickBlock == nil) {
                tipsV.playBtnClickBlock = ^{
                    [weakSelf play];
                    
                    weakSelf.allow4gNetwork = YES;
                    if (weakSelf.networkTipsConfirmBlock) {
                        weakSelf.networkTipsConfirmBlock();
                        weakSelf.networkTipsConfirmBlock = nil;
                    }
                    [weakTipsV hide];
                };
            }
        });
    }
}

#pragma -- 播放重试处理
- (void)handlePlayError:(PLVVodPlayerViewController *)player error:(NSError *)error{
    // 客户可以自定义播放失败的错误逻辑
    
    if (self.localPlayback || [self checkVideoWillPlayLocal:self.video]){
        // 本地视频播放可以不重试
        PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
        [skin.loadingIndicator stopAnimating];
        NSString *errorMsg = [error.userInfo objectForKey:NSHelpAnchorErrorKey];
        [skin showPlayErrorWithTips:errorMsg isLocal:YES];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
            [skin.loadingIndicator stopAnimating];
            NSString *errorMsg = [error.userInfo objectForKey:NSHelpAnchorErrorKey];

            PLVVodNetworkTipsView *tipsView = [skin showPlayErrorWithTips:errorMsg isLocal:NO];
            self.hidePlayError = YES;
            __weak typeof(PLVVodPlayerSkin *) weakSkin = skin;
            __weak typeof(PLVVodNetworkTipsView*) weakTips = tipsView;
            __weak typeof(self) weakSelf = self;
            
            // 播放重试事件
            tipsView.playBtnClickBlock = ^{
                
                AlicloudReachabilityManager *netMgr = [AlicloudReachabilityManager shareInstance];
                if (AlicloudNotReachable == netMgr.currentNetworkStatus){
                    //
                    NSString *errorMsg = @"网络不可用，请检查网络设置";
                    [weakSkin showPlayErrorWithTips:errorMsg isLocal:NO];
                    weakSelf.hidePlayError = YES;
                }
                else{
                    if (!weakSelf.video){
                        //
                        if (![weakSelf.vid isKindOfClass:[NSNull class]] && [weakSelf.vid length]){
                            [weakTips hide];
                            weakSelf.hidePlayError = NO;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSkin.loadingIndicator startAnimating];
                                [PLVVodVideo requestVideoWithVid:weakSelf.vid completion:^(PLVVodVideo *video, NSError *error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSkin.loadingIndicator stopAnimating];
                                        if (error){
                                            if (weakSelf.playerErrorHandler) { weakSelf.playerErrorHandler(weakSelf, error);};
                                        }
                                        else{
                                            weakSelf.video = video;
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:PLVVodPlaybackRecoveryNotification object:nil];
                                        }
                                    });
                                }];
                            });
                        }
                        else{
                            NSLog(@"[Player Error] - 播放重试，请传递正确的vid");
                        }
                    }
                    else{
                        // 重试播放 会自动切换码率/线路
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakTips hide];
                            weakSelf.hidePlayError = NO;
                            [weakSkin.loadingIndicator startAnimating];
                            [weakSelf switchQuality:weakSelf.quality];
                        });
                    }
                }
            };
        });
    }
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
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    self.currentVolume = audioSession.outputVolume;
    
	PLVVodPlayerSkin *skin = [[PLVVodPlayerSkin alloc] initWithNibName:nil bundle:nil];
    skin.enableFloating = self.enableFloating;
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
            if (!weakSelf.localPlayback){
                _skin.loadSpeed.hidden = !isLoading;
            }
            if (weakSelf.longPressForward) { // 更改快进UI文本（"快进x2" -> "Loading"）
                [skin.fastForwardView setLoading:isLoading];
            }
		});
	};
    
    // 配置打点信息回调
    self.videoTipsSelectedHandler = ^(NSUInteger tipIndex) {
        [_skin showVideoPlayTips:tipIndex];
    };
    
    skin.routeLineDidChangeBlock = ^(NSUInteger routeIndex) {
        //
        // TODO: 进行线路切换
        NSLog(@"====== 需要线路切换 =====");
        NSString *routeLine = nil;
        if (weakSelf.playbackMode == PLVVodPlaybackModeAudio){
            routeLine = [weakSelf.video.availableAudioRouteLines objectAtIndex:routeIndex];
        }
        else{
            routeLine = [weakSelf.video.availableRouteLines objectAtIndex:routeIndex];
        }
        [weakSelf setRouteLine:routeLine];
    };
    
    // 为保证封面图正常回收，需调用一次该Block
    self.playbackStateHandler = ^(PLVVodPlayerViewController *player) {
    
    };
}

- (void)updateSkin{
    // 更新线路设置
    [self setRouteLineView];
    
    // 更新清晰度控制
    [self setQualityView];
}

// 线路设置
- (void)setRouteLineView{
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    if (self.video.keepSource){
        // 屏蔽线路切换
        [skin setRouteLineFullScreenBtnHidden:YES];
        [skin setRouteLineShrinkScreenBtnHidden:YES];
    }
    else{
        if ([skin isShowRoutelineInShrinkSreen]){
            [skin setRouteLineShrinkScreenBtnHidden:NO];
        }
        
        [skin setRouteLineFullScreenBtnHidden:NO];
        if (PLVVodPlaybackModeAudio == self.playbackMode){
            [skin setRouteLineCount:self.video.availableAudioRouteLines.count];
        }
        else{
            [skin setRouteLineCount:self.video.availableRouteLines.count];
        }
    }
}

// 清晰度设置
- (void)setQualityView{
    //
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    if (self.video.keepSource){
        // 清晰度不可点击
        [skin setEnableQualityBtn:NO];
    }
    else{
        [skin setEnableQualityBtn:(self.playbackMode != PLVVodPlaybackModeAudio)];
    }
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
			if (skin.enableDanmu) {
                [danmuManager resume];
			} else {
                [danmuManager stop];
			}
			skin.enableDanmuChangeHandler = ^(PLVVodPlayerSkin *skin, BOOL enableDanmu) {
				if (skin.enableDanmu) {
                    [danmuManager resume];
				} else {
                    [danmuManager stop];
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
            
#ifdef PLVSupportCustomQuestion
            // 回答错误，可在这里替换问题
            NSMutableArray *changeArr = [[NSMutableArray alloc] init];
            // TODO: 添加要替换的问题
            
            [weakSelf.examViewController changeExams:changeArr showTime:exam.showTime];;
#endif
            
			weakSelf.currentPlaybackTime = backTime;
		}
        
		[weakSelf play];
	};
    
    [self loadExams];
}

- (void)loadExams{
    // 本地播放，从本地获取问答
    if (self.localPlayback || [self checkVideoWillPlayLocal:self.video]){
        NSArray<PLVVodExam *> *exams = [PLVVodExam localExamsWithVid:self.video.vid
                                                         downloadDir:[PLVVodDownloadManager sharedManager].downloadDir];
        if (exams.count){
            self.examViewController.exams = exams;
            NSLog(@"[player] -- 本地问答");
            return;
        }
    }
    
    // 在线获取问答数据
    if (self.video.interactive){
        // 若使用保利威后台配置的题目，可按以下方式获取并配置配置
        [PLVVodExam requestVideoWithVid:self.video.vid completion:^(NSArray<PLVVodExam *> *exams, NSError *error) {
            self.examViewController.exams = exams;
            NSLog(@"[player] -- 在线问答");
        }];
        
        // 若题目数据另外自行获取，可参考以下方式
        //    // 1、从文件中读取Json，来模拟数据从外部获取
        //    NSString * path = [[NSBundle mainBundle]pathForResource:@"PLVVodExamTestData" ofType:@"json"];
        //    NSData * data = [[NSData alloc]initWithContentsOfFile:path];
        //    NSError * error = nil;
        //    NSArray * examArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        //
        //    // 2、使用SDK的方法转为 PLVVodExam 模型
        //    NSArray * examModelArr = [PLVVodExam createExamArrayWithDicArray:examArr];
        //
        //    // 3、配置题目
        //    self.examViewController.exams = examModelArr;
    }
}

- (void)setupSubtitle {
	PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
//    //srtUrl = @"https://static.polyv.net/usrt/f/f46ead66de/srt/b3ecc235-a47c-4c22-af29-0aab234b1b69.srt";
    
    // 清空数据
    self.subtitleManager = [PLVSubtitleManager managerWithSubtitle:nil
                                                             label:skin.subtitleLabel
                                                          topLabel:skin.subtitleTopLabel
                                                             error:nil];
    
    if (!skin.selectedSubtitleKey) return;

    [self loadSubtitle];
}

- (void)loadSubtitle{
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    
    if (self.localPlayback || [self checkVideoWillPlayLocal:self.video]){
        // 优先获取本地字幕
        NSDictionary *srtDic = [PLVVodLocalVideo localSubtitlesWithVideo:self.video
                                                                     dir:[PLVVodDownloadManager sharedManager].downloadDir];
        if (srtDic.count){
            NSString *fileUrl = [srtDic objectForKey:skin.selectedSubtitleKey];
            if (fileUrl.length){
                NSLog(@"[字幕] -- 本地字幕");
                NSString *strContent = [NSString stringWithContentsOfFile:fileUrl encoding:NSUTF8StringEncoding error:nil];
                self.subtitleManager = [PLVSubtitleManager managerWithSubtitle:strContent
                                                                         label:skin.subtitleLabel
                                                                      topLabel:skin.subtitleTopLabel
                                                                         error:nil];
                return;
            }
        }
    }

    // 获取在线字幕内容并设置字幕
    __weak typeof(self) weakSelf = self;
    NSString *srtUrl = self.video.srts[skin.selectedSubtitleKey];
    [self.class requestStringWithUrl:srtUrl completion:^(NSString *string) {
        NSLog(@"[字幕] -- 在线字幕");
        NSString *srtContent = string;
        weakSelf.subtitleManager = [PLVSubtitleManager managerWithSubtitle:srtContent
                                                                     label:skin.subtitleLabel
                                                                  topLabel:skin.subtitleTopLabel
                                                                     error:nil];
    }];
}

// 设置视频打点信息
- (void)setVideoPlayTips{
    //
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin addVideoPlayTips:self.video];
    
    __weak typeof(self) weakSelf = self;

    // 视频打点,点击播放回调处理
    skin.plvVideoTipsPlayerBlock = ^(NSUInteger playIndex) {
        PLVVodVideoKeyFrameItem *item = [weakSelf.video.videokeyframes objectAtIndex:playIndex];
        [weakSelf setCurrentPlaybackTime:[item.keytime floatValue]];
        [weakSelf play];
    };
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
    if (!cover) return;
    
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

// 设置封面图
- (void)setupCoverWithVideo:(PLVVodVideo *)video{
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin updateCoverView:video];
}

- (void)removeCover{
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin removeCoverView];
}

// 更新加载速率
- (void)updateLoadSpeed{
    //
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    if (!skin.loadSpeed.hidden){
        skin.loadSpeed.text = self.tcpSpeed ? self.tcpSpeed: @"0 KB/s";
    }
}

#pragma mark override -- 播放模式切换回调
// 更新播放模式更新成功回调
- (void)playbackModeDidChange {
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin updatePlayModeContainView:self.video];
    
    // 更新清晰度状态
    [skin setEnableQualityBtn:(self.playbackMode != PLVVodPlaybackModeAudio)];
}

- (void)updateAudioCoverAnimation:(BOOL)isPlaying {
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin updateAudioCoverAnimation:isPlaying];
}

- (void)setPlaybackStateHandler:(void (^)(PLVVodPlayerViewController *))playbackStateHandler{
    __weak typeof(self) weakSelf = self;
    
    super.playbackStateHandler = ^(PLVVodPlayerViewController *player) {
        if (player.playbackState == PLVVodPlaybackStatePlaying) {
            [weakSelf removeCover];
        }
        BOOL stop = (player.playbackState == PLVVodPlaybackStateStopped) || (player.playbackState == PLVVodPlaybackStatePaused) || (player.playbackState == PLVVodPlaybackStateInterrupted);
        [weakSelf stopAndRestartTimer:stop];
        if (playbackStateHandler) {
            playbackStateHandler(player);
        }
    };
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    BOOL allow = NO;
    
    if (self.restrictedDragging &&
        self.allForbidDragging == NO) { // 对进度拖拽进行部分限制
        NSTimeInterval max = MAX(self.maxPosition, self.currentPlaybackTime);
        if (currentPlaybackTime <= max) { // 符合允许拖拽的条件
            allow = YES;
        }
    } else if (self.restrictedDragging == NO) { // 不限制进度拖拽
        allow = YES;
    }
    
    if (allow) {
        [super setCurrentPlaybackTime:currentPlaybackTime];
    }
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
        case PLVVodGestureTypeLongPress:{
            [self forwardWithGesture:recognizer];
        }break;
        case PLVVodGestureTypeLongPressEnd:{
            [self stopForwardWithGesture:recognizer];
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
            [skin showGestureIndicator:YES];
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
            [skin showGestureIndicator:NO];
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
                self.currentVolume -= veloctyPoint.y/10000;
                [self changeVolume:self.currentVolume];
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
                [skin showGestureIndicator:YES];
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
                [skin showGestureIndicator:NO];
            } break;
            default: {} break;
        }
    }
}

- (void)changeVolume:(CGFloat)distance {
    if (distance > 1) { distance = 1; }
    else if (distance < 0) { distance = 0; }
    
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
    if (self.restrictedDragging) { // restrictedDragging 为 YES 时不允许使用手势对进度拖动
        return;
    }
    
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
			[skin showGestureIndicator:YES];
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
			[skin showGestureIndicator:NO];
		} break;
		default: {} break;
	}
}

- (void)forwardWithGesture:(UIGestureRecognizer *)recognizer {
    if (self.disableLongPressGesture || self.playbackState != PLVVodPlaybackStatePlaying) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan && self.playbackRate >= self.longPressPlaybackRate) {
        recognizer.state = UIGestureRecognizerStateCancelled;
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.originPlaybackRate = self.playbackRate;
    }
    
    self.longPressForward = YES;
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    if (skin.selectedPlaybackRateDidChangeBlock) skin.selectedPlaybackRateDidChangeBlock(self.longPressPlaybackRate);
   
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        PLVVodFastForwardView *forwardView = skin.fastForwardView;
        forwardView.rate = weakSelf.longPressPlaybackRate;
        BOOL isLoading = skin.loadingIndicator.animating;
        if (isLoading) { // 更改快进UI文本（"快进x2" -> "Loading"）
            [skin.fastForwardView setLoading:YES];
        }
        [forwardView show];
    });
}

- (void)stopForwardWithGesture:(UIGestureRecognizer *)recognizer {
    if (![recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return;
    }
    
    if (self.longPressForward) {
        self.longPressForward = NO;
        PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
        if (skin.selectedPlaybackRateDidChangeBlock) skin.selectedPlaybackRateDidChangeBlock(self.originPlaybackRate);
    }
    
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    dispatch_async(dispatch_get_main_queue(), ^{
        PLVVodFastForwardView *forwardView = skin.fastForwardView;
        [forwardView hide];
    });
}

#pragma mark - tool

+ (void)requestStringWithUrl:(NSString *)url completion:(void (^)(NSString *string))completion {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (string.length && completion) {
			completion(string);
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
    
    // 网络类型监听
    // 若无需’视频播放判断网络类型‘功能，可将此监听注释
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusDidChange:)
                                                 name:ALICLOUD_NETWOEK_STATUS_NOTIFY
                                               object:nil];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:PLVVodADAndTeasersPlayFinishNotification object:nil];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:PLVVodADAndTeasersPlayFinishNotification object:nil];
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

#pragma mark -- public
- (BOOL)isLockScreen{
    PLVVodPlayerSkin *skinController = (PLVVodPlayerSkin *)self.playerControl;
    return skinController.isLockScreen;
}

@end
