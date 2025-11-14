//
//  PLVVodSkinPlayerController.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodSkinPlayerController.h"
#import "PLVVodUtils.h"
#import "PLVVodPlayerSkin.h"
#import "PLVVodDanmu+PLVVod.h"
#import "PLVVodExamViewController.h"
#import "PLVVodNetworkUtil.h"
#import "PLVVodSubtitleManager.h"
#import "NSString+PLVVod.h"
#import <PLVVodSDK/PLVVodExam.h>
#import <MediaPlayer/MediaPlayer.h>
#import <PLVVodSDK/PLVVodReachability.h>
#import <PLVVodSDK/PLVVodDownloadManager.h>
#import <PLVVodSDK/PLVVodLocalVideo.h>
#import <PLVVodSDK/PLVVodSettings.h>
#import <AVFoundation/AVFoundation.h>
#import <PLVMasonry/PLVMasonry.h>
#import "PLVVodOptimizeOptionsPanelView.h"

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

NSString *PLVVodPlaybackRecoveryNotification = @"PLVVodPlaybackRecoveryNotification";
NSString *PLVVodADAndTeasersPlayFinishNotification = @"PLVVodADAndTeasersPlayFinishNotification";

static NSString * const PLVVodMaxPositionKey = @"net.polyv.sdk.vod.maxPosition";

@interface PLVVodSkinPlayerController ()<PLVVodOptimizeOptionsPanelViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *skinView;

/// 弹幕管理
@property (nonatomic, strong) PLVVodDanmuManager *danmuManager;

/// 播放刷新定时器
@property (nonatomic, strong) PLVTimer *playbackTimer;

/// 问答控制器
@property (nonatomic, strong) PLVVodExamViewController *examViewController;

/// 知识清单控制器
@property (nonatomic, strong) PLVKnowledgeListViewController *knowledgeListViewController;

/// 线路优化按钮面板
@property (nonatomic, strong) PLVVodOptimizeOptionsPanelView *optimizeOptionPanelView;

/// 字幕管理器
@property (nonatomic, strong) PLVVodSubtitleManager *subtitleManager;

/// 视频截图
@property (nonatomic, strong) UIImage *coverImage;

/// 滑动进度
@property (nonatomic, assign) NSTimeInterval scrubTime;

/// 视频播放判断网络类型功能所需的延迟操作事件
@property (nonatomic, copy) void (^networkTipsConfirmBlock) (void);

/// 是否允许4g网络播放，用于记录用户允许的网络类型
@property (nonatomic, assign) BOOL allow4gNetwork;

// 上次执行播放进度回调 playbackTimeHandler 的播放进度
@property (nonatomic, assign) NSTimeInterval lastPlaybackTime;

/// 是否处于长按快进的状态中，默认为 NO
@property (nonatomic, assign) BOOL longPressForward;
// 长按快进之前播放的倍速，默认为 1.0
@property (nonatomic, assign) double originPlaybackRate;

/// 记录最长播放进度使用的计时器
@property (nonatomic, strong) NSTimer *markMaxPositionTimer;

/// 禁止拖动提示
@property (nonatomic, strong) UILabel *toastLable;

@end

@implementation PLVVodSkinPlayerController

#pragma mark - property

- (void)setVideo:(PLVVodVideo *)video quality:(PLVVodQuality)quality {
	// !!!: 这部分的功能的控制，由于与每次设置的 video 有关，因此必须在设置 PLVVodVideo 对象之前，或在这里设置。
	{
		// 开启广告
		self.enableAd = YES;
		
		// 开启片头
		self.enableTeaser = YES;
		
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
        PLVVodReachability * reachability = [PLVVodReachability sharedReachability];
        if (reachability.currentReachabilityStatus >= PLVVodReachableViaWWAN){ // 移动网络
            __weak typeof(self) weakSelf = self;
            self.networkTipsConfirmBlock = ^{
                [weakSelf setVideo:video quality:quality];
            };
            dispatch_async(dispatch_get_main_queue(), ^{
                PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)self.playerControl;
                [skin.loadingIndicator stopAnimating];
                [self playVideoOnNetworkType];
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

- (void)setIsVideoToolBox:(BOOL)isVideoToolBox {
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    skin.isVideoToolBox = isVideoToolBox;
    [super setIsVideoToolBox:isVideoToolBox];
}

- (void)setExamViewController:(PLVVodExamViewController *)examViewController {
	if (_examViewController) {
		[_examViewController.view removeFromSuperview];
		[_examViewController removeFromParentViewController];
	}
	_examViewController = examViewController;
}

- (void)setKnowledgeListViewController:(PLVKnowledgeListViewController *)knowledgeListViewController {
    if (_knowledgeListViewController) {
        [_knowledgeListViewController.view removeFromSuperview];
        [_knowledgeListViewController removeFromParentViewController];
    }
    _knowledgeListViewController = knowledgeListViewController;
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


/// 设置知识清单
/// @param knowledgeModel 知识清单model
- (void)setKnowledgeModel:(PLVKnowledgeModel *)knowledgeModel {
    _knowledgeModel = [self dealKnowledgeListData:knowledgeModel];
    
    // 显示 “知识点” 按钮
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    if (_knowledgeModel.buttonName.length > 0 && _knowledgeModel.knowledgeWorkTypes.count > 0) {
        skin.enableKnowledge = YES;
        skin.knowledgeButtonTitle = knowledgeModel.buttonName;
    }else {
        skin.enableKnowledge = NO;
    }
    
    
    if (knowledgeModel.fullScreenStyle) {
        [self.knowledgeListViewController.view plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.view);
        }];
    }else {
        [self.knowledgeListViewController.view plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
            make.right.top.bottom.equalTo(self.view);
            make.width.equalTo(self.view).multipliedBy(0.59);
        }];
    }
    
    // 填充知识点数据到控制器
    self.knowledgeListViewController.knowledgeModel = knowledgeModel;
}


/// 处理知识清单数据
- (PLVKnowledgeModel *)dealKnowledgeListData:(PLVKnowledgeModel *)knowledgeModel {
    
    NSMutableArray *workTypeList = [NSMutableArray arrayWithCapacity:1];
    for (PLVKnowledgeWorkType *workTypeModel in knowledgeModel.knowledgeWorkTypes) {
        //过滤空 知识点 的workkey
        NSMutableArray *workKeyList = [NSMutableArray arrayWithCapacity:1];
        for (PLVKnowledgeWorkKey *workkeyModel in workTypeModel.knowledgeWorkKeys) {
            if (workkeyModel.knowledgePoints.count != 0) {
                [workKeyList addObject:workkeyModel];
            }
        }
        workTypeModel.knowledgeWorkKeys = workKeyList;
        
        // 过滤空 workkey的worktype
        if (workTypeModel.knowledgeWorkKeys.count != 0) {
            [workTypeList addObject:workTypeModel];
        }
    }
    knowledgeModel.knowledgeWorkTypes = workTypeList;
    
    return knowledgeModel;
}

#pragma mark - view controller

- (void)dealloc {
	[self.playbackTimer cancel];
	self.playbackTimer = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume" context:(void *)[AVAudioSession sharedInstance]];
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
    self.allowShowToast = NO;
    
	[self setupSkin];
    [self setupKnowledgeList];
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
            if (PLVVodPlaybackStatePlaying == weakSelf.playbackState){
                PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)weakSelf.playerControl;
                [skin hidePlayErrorTips];
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
    
    // 设置新版跑马灯（2.0）
    self.marqueeView = [[PLVVodMarqueeView alloc]init];
    PLVVodMarqueeModel *marqueeModel = [[PLVVodMarqueeModel alloc] init];
    self.marqueeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.marqueeView.frame = self.customMaskView.bounds;
    [self.marqueeView setPLVVodMarqueeModel:marqueeModel];
    [self.customMaskView addSubview:self.marqueeView];
    
	// 错误回调
	self.playerErrorHandler = ^(PLVVodPlayerViewController *player, NSError *error) {
		NSLog(@"player error: %@", error);
        [weakSelf handlePlayError:player error:error];
	};
    
    // 恢复播放
    self.playbackRecoveryHandle = ^(PLVVodPlayerViewController *player) {
        // 应用层重试
        NSTimeInterval seekTime = weakSelf.lastPosition;

        [weakSelf setCurrentPlaybackTime:seekTime];
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
        
    if (PLVVodReachableViaWiFi == [PLVVodReachability sharedReachability].currentReachabilityStatus){ // WiFi
        dispatch_async(dispatch_get_main_queue(), ^{
            PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)self.playerControl;
            [skin hideNetworkTips];
            
            [self replayWhenNetworkAvailable];
        });
        
    }else if (PLVVodReachableViaWWAN <= [PLVVodReachability sharedReachability].currentReachabilityStatus){ // 移动网络
        if (self.allow4gNetwork) { return; }
        
        // 若播放器播放中
        if (self.playbackState == PLVVodPlaybackStatePlaying) { [self pause]; }
        
        __weak typeof(self) weakSelf = self;
        PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)self.playerControl;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 播放视频 网络类型（wifi 移动流量）提示
            PLVVodNetworkTipsView * tipsV = [skin showNetworkTips];
            __weak typeof(tipsV) weakTipsV = tipsV;
            
            if (tipsV.playBtnClickBlock == nil) {
                tipsV.playBtnClickBlock = ^{
                    [weakSelf replayWhenNetworkAvailable];
                    
                    // 隐藏提示
                    weakSelf.allow4gNetwork = YES;
                    [weakTipsV hide];
                };
            }
        });
    }
}

- (void)replayWhenNetworkAvailable{
    [self retryPlayVideo];
}

- (void)playVideoOnNetworkType{
    if (PLVVodReachableViaWiFi == [PLVVodReachability sharedReachability].currentReachabilityStatus){
        // WiFi
        dispatch_async(dispatch_get_main_queue(), ^{
            PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)self.playerControl;
            [skin hideNetworkTips];

            if (self.networkTipsConfirmBlock) {
                self.networkTipsConfirmBlock();
                self.networkTipsConfirmBlock = nil;
            }
        });
        
    }else if (PLVVodReachableViaWWAN <= [PLVVodReachability sharedReachability].currentReachabilityStatus){
        // 移动网络
        if (self.allow4gNetwork) { return; }
        
        // 若播放器播放中
        if (self.playbackState == PLVVodPlaybackStatePlaying) { [self pause]; }
        
        __weak typeof(self) weakSelf = self;
        PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)self.playerControl;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 播放视频 网络类型（wifi 移动流量）提示
            PLVVodNetworkTipsView * tipsV = [skin showNetworkTips];
            __weak typeof(tipsV) weakTipsV = tipsV;
            
            if (tipsV.playBtnClickBlock == nil) {
                tipsV.playBtnClickBlock = ^{
                    
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
        // 直接显示错误信息
        [skin showPlayErrorWithTips:errorMsg isLocal:YES];
    }
    else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
            [skin.loadingIndicator stopAnimating];
            NSString *errorMsg = [error.userInfo objectForKey:NSHelpAnchorErrorKey];

            __weak typeof(self) weakSelf = self;
            PLVVodNetworkPlayErrorTipsView *errorTipsViw = [skin showPlayErrorWithTips:errorMsg isLocal:NO];
            errorTipsViw.handleSwitchEvent = ^{
                // 弹出线路选择面板
                [weakSelf showOptimizeOptionPanelView];
            };
        });
    }
}

- (BOOL)isNilString:(NSString *)origStr{
    if (!origStr || [origStr isKindOfClass:[NSNull class]] || !origStr.length){
        return YES;
    }
    
    return NO;
}

- (void)retryPlayVideo{
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    if (PLVVodNotReachable == [PLVVodReachability sharedReachability].currentReachabilityStatus){
        //
        NSString *errorMsg = @"网络不可用，请检查网络设置";
        [skin showPlayErrorWithTips:errorMsg isLocal:NO];
    }
    else{
        if (!self.video){
            if (![self isNilString:self.vid]){
                [skin hidePlayErrorTips];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [skin.loadingIndicator startAnimating];
                    // 从videojson 开始播放
                    [PLVVodVideo requestVideoWithVid:self.vid completion:^(PLVVodVideo *video, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [skin.loadingIndicator stopAnimating];
                            if (error){
                                if (self.playerErrorHandler) {
                                    self.playerErrorHandler(self, error);
                                };
                            }
                            else{
                                // 首次播放
                                self.video = video;
                            
                                // 恢复播放通知
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
                [skin hidePlayErrorTips];
                [skin.loadingIndicator startAnimating];
                
                [self switchQuality:self.quality];
            });
        }
    }
}

- (void)viewDidLayoutSubviews {
    //NSLog(@"layout guide: %f - %f", self.topLayoutGuide.length, self.bottomLayoutGuide.length);
    if (@available(iOS 11.0, *)) {
        self.danmuManager.insets = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, self.view.safeAreaInsets.bottom, 0);
    } else {
        self.danmuManager.insets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)setupSkin {
    
	PLVVodPlayerSkin *skin = [[PLVVodPlayerSkin alloc] initWithNibName:nil bundle:nil];
    skin.enableFloating = self.enableFloating;
    skin.deviceOrientationChangedNotSwitchFullscreen = self.deviceOrientationChangedNotSwitchFullscreen;
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
    skin.isVideoToolBox = self.isVideoToolBox;
	
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
    
    // 点击 “知识点” 按钮
    skin.knowledgeButtonTouchHandler = ^{
        [weakSelf.knowledgeListViewController showKnowledgeListView];
    };
    
    skin.videoToolBoxDidChangeBlock = ^(BOOL isVideoToolBox) {
        weakSelf.isVideoToolBox = isVideoToolBox;
        [weakSelf switchVideoToolBox:isVideoToolBox];
    };
    
    // 自定义标签回调
    skin.progressMarkerViewClick = ^(PLVVodMarkerViewData *markerViewData) {
        NSLog(@"%@", markerViewData);
        if (weakSelf.markerViewClick){
            weakSelf.markerViewClick(markerViewData);
        }
    };
    
    // 线路优选按钮回调
    skin.optimizeOptionButtonClickHandler = ^{
        // 弹出线路优选面板
        if (weakSelf.rootViewController){
            //
            [weakSelf showOptimizeOptionPanelView];
        }
    };
}

- (void)showOptimizeOptionPanelView{
    CGRect panelFrame = self.rootViewController.view.frame;
    if (self.optimizeOptionPanelView){
        self.optimizeOptionPanelView.frame = panelFrame;
        [self.optimizeOptionPanelView show];
        [self.optimizeOptionPanelView setupWithHardDecode:self.isVideoToolBox
                                                    lineIndex:self.routeLineIndex
                                                    totalLine:self.video.availableRouteLines.count
                                                    isHttpDns:self.isHttpDNS];
    }
    else{
        self.optimizeOptionPanelView = [[PLVVodOptimizeOptionsPanelView alloc] initWithFrame:panelFrame];
        self.optimizeOptionPanelView.delegate = self;
        [self.rootViewController.view addSubview:self.optimizeOptionPanelView];
        [self.optimizeOptionPanelView setupWithHardDecode:self.isVideoToolBox
                                                    lineIndex:self.routeLineIndex
                                                    totalLine:self.video.availableRouteLines.count
                                                    isHttpDns:self.isHttpDNS];
    }
}

- (NSInteger)routeLineIndex{
    NSInteger routeLineIndex = 0;
    BOOL found = NO;
    NSMutableArray *lineArray = [[NSMutableArray alloc] init];
    if (self.playbackMode == PLVVodPlaybackModeAudio) {
        [lineArray addObjectsFromArray:self.video.availableAudioRouteLines];
    } else {
        [lineArray addObjectsFromArray:self.video.availableRouteLines];
    }
    for (NSString *line in lineArray){
        if ([line isEqualToString:self.routeLine]){
            found = YES;
            break;
        }
        routeLineIndex++;
    }
    return found ? routeLineIndex: 0;
}

- (BOOL)isHttpDNS{
    // 以远端httpdns 为准
    return [PLVVodSettings sharedSettings].enableHttpDNS;
}

- (void)updateSkin{
    // 更新线路设置
    [self setRouteLineView];
    
    // 更新清晰度控制
    [self setQualityView];
    
    // 更新热力图 ,有该业务需求的客户放开注释
//    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin*)self.playerControl;
//    [skin updateHeatMapViewWithData:[PLVVodHeatMapModel defaultTestData]];
    
    // 更新自定义打点数据
//    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin*)self.playerControl;
//    [skin updateMarkerViewWithData:[PLVVodMarkerViewData defautMarkerViewData]];
}

// 线路设置
- (void)setRouteLineView{
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    if (self.video.keepSource || self.localPlayback){
        // 屏蔽线路切换
        [skin setRouteLineFullScreenBtnHidden:YES];
        [skin setRouteLineShrinkScreenBtnHidden:YES];
    }
    else{
        if (PLVVodPlaybackModeAudio == self.playbackMode){
            [skin setRouteLineCount:self.video.availableAudioRouteLines.count];
            [skin setRouteLineFullScreenBtnHidden:self.video.availableAudioRouteLines.count > 1 ? NO : YES];
            if ([skin isShowRoutelineInShrinkSreen]){
                [skin setRouteLineShrinkScreenBtnHidden:self.video.availableAudioRouteLines.count > 1 ? NO : YES];
            }
        }
        else{
            [skin setRouteLineCount:self.video.availableRouteLines.count];
            [skin setRouteLineFullScreenBtnHidden:self.video.availableRouteLines.count > 1 ? NO : YES];
            if ([skin isShowRoutelineInShrinkSreen]){
                [skin setRouteLineShrinkScreenBtnHidden:self.video.availableRouteLines.count > 1 ? NO : YES];
            }
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ad.address] 
                                           options:[NSDictionary dictionary]
                                 completionHandler:^(BOOL success) {
        }];
	};
	
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
		__block PLVVodDanmuManager *danmuManager = [[PLVVodDanmuManager alloc] initWithDanmus:danmus inView:skin.skinMaskView/*weakSelf.customMaskView*/];
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
        [weakSelf pauseWithoutAd];
	};
	self.examViewController.examDidCompleteHandler = ^(PLVVodExam *exam, NSTimeInterval backTime, NSArray<NSNumber *> *anwserIndexs) {
		if (backTime >= 0) {
            
#ifdef PLVSupportCustomQuestion
            // 回答错误，可在这里替换问题
            NSMutableArray *changeArr = [[NSMutableArray alloc] init];
            // TODO: 添加要替换的问题
            
            [weakSelf.examViewController changeExams:changeArr showTime:exam.showTime];;
#endif
            
			weakSelf.currentPlaybackTime = backTime;          
		}
        // 上报答题统计
        [weakSelf saveExamStatitics:exam answer:anwserIndexs];
        
		[weakSelf play];
	};
    
    [self loadExams];
}

- (void)saveExamStatitics:(PLVVodExam *)exam answer:(NSArray<NSNumber *> *)answerIndexs{
    if (answerIndexs.count){
        NSMutableString *strAnswer = [[NSMutableString alloc] init];
        for (NSNumber *index in answerIndexs){
            NSString *answerText = [exam.options objectAtIndex:[index integerValue]];
            [strAnswer appendString:answerText];
            [strAnswer appendString:@","];
        }
        if (strAnswer.length == 0) return;
        NSRange range = NSMakeRange(strAnswer.length-1, 1);
        [strAnswer deleteCharactersInRange:range];
        NSString *playerId = [self getPlayId];
        [PLVVodExam saveExamStatisticsWithPid:playerId
                                          eid:exam.examId
                                          uid:exam.userId
                                    quesition:exam.question
                                          vid:exam.vid
                                      correct:exam.correct
                                       anwser:strAnswer
                                   completion:^(NSError *error) {
            if (error){
                NSLog(@"[保存答题记录失败]");
            }
        }];
    }
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

- (void)setupKnowledgeList {
    PLVKnowledgeListViewController *knowledgeController = [[PLVKnowledgeListViewController alloc] init];
    [self.view addSubview:knowledgeController.view];
    [knowledgeController.view plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    [self addChildViewController:knowledgeController];
    self.knowledgeListViewController = knowledgeController;
    __weak typeof(self) weakSelf = self;
    self.knowledgeListViewController.selectKnowledgePointBlock = ^(PLVKnowledgePoint * _Nonnull point) {
        if (point.time >= 0) {
            weakSelf.currentPlaybackTime = point.time;
        }
    };
}


- (void)setupSubtitle {
	PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
//    //srtUrl = @"https://static.polyv.net/usrt/f/f46ead66de/srt/b3ecc235-a47c-4c22-af29-0aab234b1b69.srt";
    
    // 清空数据
    self.subtitleManager = [PLVVodSubtitleManager managerWithSubtitle:nil style:nil error:nil subtitle2:nil style2:nil error2:nil label:skin.subtitleLabel topLabel:skin.subtitleTopLabel label2:skin.subtitleLabel2 topLabel2:skin.subtitleTopLabel2];
    
    if (!skin.selectedSubtitleKey) return;

    [self loadSubtitle];
}

- (void)loadSubtitle{
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    PLVVodSubtitleItemStyle *topStyle;
    PLVVodSubtitleItemStyle *bottomStyle;
    PLVVodSubtitleItemStyle *singleStyle;
    // 获取字幕样式
    for (PLVVodVideoSubtitlesStyle *style in self.video.player.subtitles) {
        if ([style.style isEqualToString:@"double"] && [style.position isEqualToString:@"top"]) {
            topStyle = [PLVVodSubtitleItemStyle styleWithTextColor:[self colorFromHexString:style.fontColor] bold:style.fontBold italic:style.fontItalics backgroundColor:[self colorFromRGBAString:style.backgroundColor]];
        } else if ([style.style isEqualToString:@"double"] && [style.position isEqualToString:@"bottom"]) {
            bottomStyle = [PLVVodSubtitleItemStyle styleWithTextColor:[self colorFromHexString:style.fontColor] bold:style.fontBold italic:style.fontItalics backgroundColor:[self colorFromRGBAString:style.backgroundColor]];
        } else if ([style.style isEqualToString:@"single"]) {
            singleStyle = [PLVVodSubtitleItemStyle styleWithTextColor:[self colorFromHexString:style.fontColor] bold:style.fontBold italic:style.fontItalics backgroundColor:[self colorFromRGBAString:style.backgroundColor]];
        }
    }
    PLVVodVideoDoubleSubtitleItem *firstItem;
    PLVVodVideoDoubleSubtitleItem *secondItem;
    BOOL doubleSubtitleNeedShow = [skin.selectedSubtitleKey isEqualToString:@"双语"] && self.video.match_srt.count == 2;
    BOOL firstItemAtTop = NO;
    if (doubleSubtitleNeedShow) {
        firstItem = self.video.match_srt[0];
        secondItem = self.video.match_srt[1];
        firstItemAtTop = [firstItem.position isEqualToString:@"topSubtitles"];
    }
    
    if (self.localPlayback || [self checkVideoWillPlayLocal:self.video]){
        // 优先获取本地字幕
        NSDictionary *srtDic = [PLVVodLocalVideo localSubtitlesWithVideo:self.video
                                                                     dir:[PLVVodDownloadManager sharedManager].downloadDir];

        if (srtDic.count){
            if (doubleSubtitleNeedShow) { // 本地双字幕
                NSString *firstFileUrl = [srtDic objectForKey:firstItem.title];
                NSString *secondFileUrl = [srtDic objectForKey:secondItem.title];
                if (firstFileUrl.length && secondFileUrl.length) {
                    NSLog(@"[字幕] -- 本地双字幕");
                    NSString *srtContent = [NSString stringWithContentsOfFile:firstFileUrl encoding:NSUTF8StringEncoding error:nil];
                    NSString *srtContent2 = [NSString stringWithContentsOfFile:secondFileUrl encoding:NSUTF8StringEncoding error:nil];
                    self.subtitleManager = [PLVVodSubtitleManager managerWithSubtitle:firstItemAtTop ? srtContent : srtContent2
                                                                             style:topStyle
                                                                             error:nil
                                                                         subtitle2:firstItemAtTop ? srtContent2 : srtContent
                                                                            style2:bottomStyle
                                                                            error2:nil
                                                                             label:skin.subtitleLabel
                                                                          topLabel:skin.subtitleTopLabel
                                                                            label2:skin.subtitleLabel2
                                                                         topLabel2:skin.subtitleTopLabel2];
                }
            } else { // 本地单字幕
                NSString *fileUrl = [srtDic objectForKey:skin.selectedSubtitleKey];
                if (fileUrl.length){
                    NSLog(@"[字幕] -- 本地单字幕");
                    NSString *srtContent = [NSString stringWithContentsOfFile:fileUrl encoding:NSUTF8StringEncoding error:nil];
                    self.subtitleManager = [PLVVodSubtitleManager managerWithSubtitle:srtContent style:singleStyle error:nil subtitle2:nil style2:nil error2:nil label:skin.subtitleLabel topLabel:skin.subtitleTopLabel label2:skin.subtitleLabel2 topLabel2:skin.subtitleTopLabel2];
                    return;
                }
            }
        }
    }

    // 获取在线字幕内容并设置字幕
    // TODO: 支持双字幕
    __weak typeof(self) weakSelf = self;
    if (doubleSubtitleNeedShow) { // 在线双字幕
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSString *srtContent;
        __block NSString *srtContent2;
        [self.class requestStringWithUrl:firstItem.url completion:^(NSString *string) {
            NSLog(@"[字幕] -- 在线双字幕第一部分");
            srtContent = string;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [self.class requestStringWithUrl:secondItem.url completion:^(NSString *string) {
            NSLog(@"[字幕] -- 在线双字幕第二部分");
            srtContent2 = string;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        BOOL firstItemAtTop = [firstItem.position isEqualToString:@"topSubtitles"];
        self.subtitleManager = [PLVVodSubtitleManager managerWithSubtitle:firstItemAtTop ? srtContent : srtContent2
                                                                 style:topStyle
                                                                 error:nil
                                                             subtitle2:firstItemAtTop ? srtContent2 : srtContent
                                                                style2:bottomStyle
                                                                error2:nil
                                                                 label:skin.subtitleLabel
                                                              topLabel:skin.subtitleTopLabel
                                                                label2:skin.subtitleLabel2
                                                             topLabel2:skin.subtitleTopLabel2];
        
    } else { // 在线单字幕
        NSString *srtUrl = nil;
        if (!skin.selectedSubtitleKey || ![skin.selectedSubtitleKey isKindOfClass:NSString.class] || !skin.selectedSubtitleKey.length) {
            NSLog(@"[字幕] -- 在线单字幕，字幕名称为空！");
            return;
        }
        
        for (PLVVodVideoSubtitleItem *item in self.video.srts) {
            if ([item.title isEqualToString:skin.selectedSubtitleKey]) {
                srtUrl = item.url;
                break;
            }
        }

        [self.class requestStringWithUrl:srtUrl completion:^(NSString *string) {
            NSLog(@"[字幕] -- 在线单字幕");
            NSString *srtContent = string;
            weakSelf.subtitleManager = [PLVVodSubtitleManager managerWithSubtitle:srtContent style:singleStyle error:nil subtitle2:nil style2:nil error2:nil label:skin.subtitleLabel topLabel:skin.subtitleTopLabel label2:skin.subtitleLabel2 topLabel2:skin.subtitleTopLabel2];
        }];
    }
    
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
    // 设置雪碧图（进度条预览图）
    [skin updateSpriteChartWithVideo:video];
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

// 禁止拖动提示
- (void)showToastWithMessage:(NSString *)message inView:(UIView *)view {
    if (!view || !self.allowShowToast) return;

    if (!self.toastLable) {
        self.toastLable = [[UILabel alloc]init];
        self.toastLable.text = message;
        self.toastLable.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.toastLable.layer.cornerRadius = 20;
        self.toastLable.layer.masksToBounds = YES;
        self.toastLable.font = [UIFont systemFontOfSize:14.0];
        self.toastLable.textColor = [UIColor whiteColor];
        self.toastLable.textAlignment = NSTextAlignmentCenter;
        [view addSubview:self.toastLable];
        CGFloat width = [self.toastLable sizeThatFits:CGSizeMake(MAXFLOAT, 40.0)].width + 20;
        [self.toastLable plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.centerX.plv_offset(0);
            make.bottom.plv_offset(-40);
            make.size.plv_equalTo(CGSizeMake(width, 40));
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.toastLable removeFromSuperview];
            self.toastLable = nil;
        });
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
        
        if (player.playbackState == PLVVodPlaybackStatePlaying) {
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        }
        
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
        } else {
            [self showToastWithMessage:@"只能拖拽到已播放过的进度" inView:[UIApplication sharedApplication].keyWindow];
        }
    } else if (self.restrictedDragging && self.allForbidDragging) {
        [self showToastWithMessage:@"已设置禁止拖拽" inView:[UIApplication sharedApplication].keyWindow];
    } else if (self.restrictedDragging == NO) { // 不限制进度拖拽
        allow = YES;
    }
    
    // 断网的情况下不能进行seek操作
    if (PLVVodNotReachable == [PLVVodReachability sharedReachability].currentReachabilityStatus &&
        !self.localPlayback) {
        allow = NO;
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
            if (self.knowledgeListViewController && self.knowledgeListViewController.showing) {
                [self.knowledgeListViewController hideKnowledgeListView];
            }
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
    
    BOOL isSystemVolume = self.adjustSystemVolume;
    if (isSystemVolume){
        // 系统音量调节
        switch (pan.state) {
            case UIGestureRecognizerStateBegan: {
            } break;
            case UIGestureRecognizerStateChanged: {
                self.playbackVolume -= veloctyPoint.y/10000;
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

- (UIColor *)colorFromHexString:(NSString *)hexString {
    return [self colorFromHexString:hexString alpha:1.0];
}

- (UIColor *)colorFromHexString:(NSString *)hexString alpha:(float)alpha {
    if (!hexString || hexString.length < 6) {
        return [UIColor whiteColor];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    if ([hexString rangeOfString:@"#"].location == 0) {
        [scanner setScanLocation:1]; // bypass '#' character
    }
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

- (UIColor *)colorFromRGBAString:(NSString *)rgbaString {
    // 去除字符串两端的空白字符
    rgbaString = [rgbaString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // 判断字符串是否符合 rgba() 格式
    if ([rgbaString hasPrefix:@"rgba("] && [rgbaString hasSuffix:@")"]) {
        // 去除 "rgba(" 和 ")"
        NSString *valuesString = [rgbaString substringWithRange:NSMakeRange(5, rgbaString.length - 6)];
        
        // 拆分颜色值
        NSArray *components = [valuesString componentsSeparatedByString:@","];
        if (components.count == 4) {
            CGFloat red = [[components objectAtIndex:0] floatValue] / 255.0;
            CGFloat green = [[components objectAtIndex:1] floatValue] / 255.0;
            CGFloat blue = [[components objectAtIndex:2] floatValue] / 255.0;
            CGFloat alpha = [[components objectAtIndex:3] floatValue];
            
            return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        }
    }
    
    // 如果字符串格式不正确,返回 nil
    return nil;
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
                                                 name:kPLVVodReachabilityChangedNotification
                                               object:nil];
    
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(void *)[AVAudioSession sharedInstance]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(context == (__bridge void *)[AVAudioSession sharedInstance] &&
       [keyPath isEqualToString:@"outputVolume"]){
        float newValue = [[change objectForKey:@"new"] floatValue];
        self.playbackVolume = newValue;
    }
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
    [self pauseWithoutAd];
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

#pragma mark - Override：override 的方法请不要删除，如不需要，清空里面的代码也不能删除

- (void)addPlayerOnPlaceholderView:(UIView *)placeholderView rootViewController:(UIViewController *)rootViewController {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.rootViewController = rootViewController;
    [rootViewController addChildViewController:self];
    self.placeholderView = placeholderView;
    [rootViewController.view addSubview:self.view];
    
    [self updatePlayerConstraints];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    if (self.deviceOrientationChangedNotSwitchFullscreen) {
        //设备旋转，不影响全半屏状态
    }else {
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if ([self fullscreenMustBeLandscape]) {
            [self playInFullscreen:(interfaceOrientation != UIInterfaceOrientationPortrait)];
        }
        
        [self updatePlayerConstraints];
    }
}

#pragma mark - Override Related Private Method

- (void)playInFullscreen:(BOOL)full {
    self.fullscreen = full;
    
    if (self.deviceOrientationChangedNotSwitchFullscreen) {
        // 点击全半屏切换，不旋转屏幕方向
    }else {
        if (self.fullscreen == NO) {// 非全屏时一定是竖屏状态
            [PLVVodUtils changeDeviceOrientation:UIInterfaceOrientationPortrait];
        } else if ([self fullscreenMustBeLandscape]) {// 必须旋转屏幕才能实现全屏
            UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                [PLVVodUtils changeDeviceOrientation:UIInterfaceOrientationLandscapeLeft];
            } else {
                [PLVVodUtils changeDeviceOrientation:UIInterfaceOrientationLandscapeRight];
            }
        }
    }
    
    if (self.didFullScreenSwitch) {
        self.didFullScreenSwitch(self.fullscreen);
    }

    [self updatePlayerConstraints];
}

- (void)updatePlayerConstraints {
    [self.adPlayer viewDidLayoutSubviews];
    if (self.placeholderView == nil) {
        return;
    }
    
    if (self.deviceOrientationChangedNotSwitchFullscreen) {
        if (self.fullscreen) {
            [self.view plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
                make.edges.plv_equalTo(self.rootViewController.view);
            }];
        }else {
            [self.view plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
                make.edges.plv_equalTo(self.placeholderView);
            }];
        }
        
    }else {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
        if (isPortrait && !self.fullscreen) {
            [self.view plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
                make.edges.plv_equalTo(self.placeholderView);
            }];
        } else {
            [self.view plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
                make.edges.plv_equalTo(self.rootViewController.view);
            }];
        }
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
    if (isPortrait && self.knowledgeListViewController.showing) {
        [self.knowledgeListViewController hideKnowledgeListView];
    }
}

- (BOOL)fullscreenMustBeLandscape {
    CGSize videoSize = [self getVideoSize];
    BOOL must = (self.fullScreenOrientation == PLVVodFullScreenOrientationLandscape ||
            (self.fullScreenOrientation == PLVVodFullScreenOrientationAuto && videoSize.width >= videoSize.height));
    return !self.placeholderView || must;
}

#pragma mark - PLVVodOptimizeOptionsPanelViewDelegate

- (void)optimizeOptionsPanel:(PLVVodOptimizeOptionsPanelView *)panel didSelectDecodeOption:(BOOL)hardDecode {
    [self handleDecodeOption:hardDecode];
}

- (void)handleDecodeOption:(BOOL)hardDecode{
    if ([self checkVideoWillPlayLocal:self.video]){
        // 本地视频播放
        self.isVideoToolBox = hardDecode;
        [self switchVideoToolBox:hardDecode];
    }
    else{
        // 在线视频播放
        //
        if (self.video){
            self.isVideoToolBox = hardDecode;
            [self switchVideoToolBox:hardDecode];
        }
        else{
            [self retryPlayVideo];
        }
    }
}

- (void)optimizeOptionsPanel:(PLVVodOptimizeOptionsPanelView *)panel didSelectLineOption:(NSInteger)lineIndex {
    // 切换线路
    [self handleLineOption:lineIndex];
}

- (void)handleLineOption:(NSInteger )lineIndex{
    if ([self checkVideoWillPlayLocal:self.video]){
        // 本地视频播放
        return;
    }
    else{
        // 切换线路
        if (self.video){
            NSString *routeLine = nil;
            if (self.playbackMode == PLVVodPlaybackModeAudio) {
                if (lineIndex >= self.video.availableAudioRouteLines.count) return;
                routeLine = [self.video.availableAudioRouteLines objectAtIndex:lineIndex];
            } else {
                if (lineIndex >= self.video.availableRouteLines.count) return;
                routeLine = [self.video.availableRouteLines objectAtIndex:lineIndex];
            }
            [self setRouteLine:routeLine];
        }
        else{
            [self retryPlayVideo];
        }
    }
}

- (void)optimizeOptionsPanel:(PLVVodOptimizeOptionsPanelView *)panel didSelectDnsOption:(BOOL)isHttpDns {
    if ([self checkVideoWillPlayLocal:self.video]){
        // 本地视频播放
        return;
    }
    else{
        // 在线视频播放
        // 切换DNS解析方式
        [PLVVodSettings sharedSettings].enableHttpDNS = isHttpDns;
        // 重试播放
        [self retryPlayVideo];
    }
}

#pragma mark - 进度条拖动事件（重写父类方法以添加雪碧图预览功能）

/// 播放进度滑杆 TouchDown Action
- (IBAction)playbackSliderTouchDownAction:(UISlider *)sender {
    // 调用父类方法，保持原有功能
    [super playbackSliderTouchDownAction:sender];
    
    // 显示雪碧图预览
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin showSpriteChartView];
    [skin updateSpriteChartViewWithSlider:sender];
}

/// 播放进度滑杆 ValueChange Action
- (IBAction)playbackSliderValueChangeAction:(UISlider *)sender {
    // 调用父类方法，保持原有功能（更新时间显示等）
    [super playbackSliderValueChangeAction:sender];
    
    // 更新雪碧图预览位置和内容
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin updateSpriteChartViewWithSlider:sender];
}

/// 播放进度滑杆 TouchUpCancel Action
- (IBAction)playbackSliderTouchUpCancelAction:(UISlider *)sender {
    // 调用父类方法，保持原有功能（执行 seek 操作等）
    [super playbackSliderTouchUpCancelAction:sender];
    
    // 隐藏雪碧图预览
    PLVVodPlayerSkin *skin = (PLVVodPlayerSkin *)self.playerControl;
    [skin hideSpriteChartView];
}

@end
