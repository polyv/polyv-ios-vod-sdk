//
//  PLVSimpleDetailController.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2018/3/26.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVSimpleDetailController.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "PLVVodSkinPlayerController.h"
#ifdef PLVCastFeature
#import "PLVCastBusinessManager.h"
#endif
#import "PLVSecureView.h"

@interface PLVSimpleDetailController ()

@property (strong, nonatomic) UIView *playerPlaceholder;
@property (nonatomic, strong) PLVVodSkinPlayerController *player;
#ifdef DEBUG
/// 播放诊断日志弹窗
@property (nonatomic, strong) UIView *playbackDiagnosticsAlertView;
#endif
#ifdef PLVCastFeature
@property (nonatomic, strong) PLVCastBusinessManager * castBM; // 投屏功能管理器
#endif

@end


@implementation PLVSimpleDetailController

// 获取导航栏高度
#define NavHight (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)

#pragma mark - Life Cycle

- (void)dealloc {
#ifdef PLVCastFeature
    [self.castBM quitAllFuntionc];
	//NSLog(@"%s", __FUNCTION__);
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	
    [self setupPlayer];
    /*
    // 需要添加播放器 logo 解开这段注释
    [self addLogo];
     */
    
    // 兼容Demo的下载视频观看页，一般集成时无需添加此段代码
    if (self.playerPlaceholder == nil) {
        UIView * playerPlaceholderV = [[UIView alloc]initWithFrame:CGRectMake(0, 
                                                                              NavHight,
                                                                              PLV_ScreenWidth,
                                                                              PLV_ScreenWidth*9/16)];
        [self.view addSubview:playerPlaceholderV];
        [self.player addPlayerOnPlaceholderView:playerPlaceholderV rootViewController:self];
    }
    
    // 若需投屏功能，则需以下代码来启用投屏
#ifdef PLVCastFeature
    if ([PLVCastBusinessManager authorizationInfoIsLegal]) {
        self.castBM = [[PLVCastBusinessManager alloc] initCastBusinessWithListPlaceholderView:self.view player:self.player];
        [self.castBM setup];
    }
#endif
    
    [self addNotification];
}

- (void)loadView{
    if (self.systemScreenShotProtect){
        PLVSecureView *secureView = [[PLVSecureView alloc] init];
        self.view = secureView.secureView;
    }else{
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
}

- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didBecomeActive:(NSNotification *)notification{
    // 暂停播放器
    if (self.player){
        [self.player resumeTeaserPlayer];
    }
}

#pragma mark - Override

- (BOOL)prefersStatusBarHidden {
	return self.player.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return self.player.preferredStatusBarStyle;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate{
    if (self.player.isLockScreen){
        return NO;
    }
    return YES;
}

#pragma mark - Private

- (void)setupPlayer {
	// 初始化播放器
	PLVVodSkinPlayerController *player = [[PLVVodSkinPlayerController alloc] initWithNibName:nil bundle:nil];
    // 因播放器皮肤的部分控件，需根据'防录屏'开关决定是否显示，因此若需打开，请在addPlayerOnPlaceholderView前设置
    // player.videoCaptureProtect = YES;
    // 对进度拖拽的限制属性 restrictedDragging 和 allForbidDragging，也请在 addPlayerOnPlaceholderView 前设置
//    player.restrictedDragging = YES;
//    player.allForbidDragging = YES;
    
    if (!self.playerPlaceholder){
        self.playerPlaceholder = [[UIView alloc] init];
        self.playerPlaceholder.frame = CGRectMake(0, NavHight, [UIScreen mainScreen].bounds.size.width,  [UIScreen mainScreen].bounds.size.width *9/16);
        [self.view addSubview:self.playerPlaceholder];
    }
    [player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
	self.player = player;
    self.player.rememberLastPosition = NO;
    self.player.enableBackgroundPlayback = YES;
    self.player.enableTeaserBackgroundPlayback = NO;
    self.player.autoplay = YES;
    self.player.enableLocalViewLog = YES;
#ifdef DEBUG
    [self setupPlaybackDiagnosticsDebugLog];
#endif
    
    __weak typeof(self) weakSelf = self;
    self.player.playbackStateHandler = ^(PLVVodPlayerViewController *player) {
        //新版跑马灯的启动暂停控制
        if (player.playbackState == PLVVodPlaybackStatePlaying) {
            [weakSelf.player.marqueeView start];
        }else if (player.playbackState == PLVVodPlaybackStatePaused) {
            [weakSelf.player.marqueeView pause];
        }else if (player.playbackState == PLVVodPlaybackStateStopped) {
            [weakSelf.player.marqueeView stop];
        }
    };
    // 自定义标签点击回调
    self.player.markerViewClick = ^(PLVVodMarkerViewData *markerViewData) {
        NSLog(@"%@", markerViewData);
    };
    
	NSString *vid = self.vid;
    if (self.isOffline){
        // 离线视频播放
        // 根据资源类型设置默认播放模式。本地音频文件设定音频播放模式，本地视频文件设定视频播放模式
        // 只针对开通视频转音频服务的用户
        self.player.playbackMode = self.playMode;
        
        [PLVVodVideo requestVideoPriorityCacheWithVid:self.vid completion:^(PLVVodVideo *video, NSError *error) {
            weakSelf.player.video = video;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.title = video.title;
            });
        }];
    }
    else{
        // 在线视频播放，默认会优先播放本地视频
        [PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
            if (error){
                // 用于播放重试
                self.player.vid = vid;
                if (self.player.playerErrorHandler) {
                    self.player.playerErrorHandler(self.player, error);
                };
            }
            else{
                weakSelf.player.video = video;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.title = video.title;
                });
            }
        }];
	}
}

#ifdef DEBUG
- (void)setupPlaybackDiagnosticsDebugLog {
    __weak typeof(self) weakSelf = self;
    self.player.playbackDiagnosticsLogHandler = ^(PLVVodPlayerViewController *player, NSDictionary *diagnostics) {
        NSString *logString = [weakSelf playbackDiagnosticsDisplayStringWithDictionary:diagnostics];
        NSLog(@"[PlaybackDiagnostics][error/timeout] %@", logString);
        [weakSelf showPlaybackDiagnosticsAlertWithLog:logString];
    };
}

- (NSString *)playbackDiagnosticsDisplayStringWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary) {
        return @"{}";
    }
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        NSString *JSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (JSONString.length) {
            return JSONString;
        }
    }
    return dictionary.description ?: @"{}";
}

- (void)showPlaybackDiagnosticsAlertWithLog:(NSString *)log {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.playbackDiagnosticsAlertView removeFromSuperview];

        UIView *containerView = self.view.window ?: [UIApplication sharedApplication].keyWindow;
        if (!containerView) {
            return;
        }

        UIView *backgroundView = [[UIView alloc] initWithFrame:containerView.bounds];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45];

        CGFloat margin = 20.0;
        CGFloat panelWidth = CGRectGetWidth(containerView.bounds) - margin * 2.0;
        CGFloat panelHeight = MIN(CGRectGetHeight(containerView.bounds) - 120.0, 560.0);
        UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(margin, 60.0, panelWidth, panelHeight)];
        panelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        panelView.backgroundColor = [UIColor whiteColor];
        panelView.layer.cornerRadius = 8.0;
        panelView.layer.masksToBounds = YES;
        [backgroundView addSubview:panelView];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 12.0, panelWidth - 32.0, 24.0)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = @"播放诊断日志";
        [panelView addSubview:titleLabel];

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        closeButton.frame = CGRectMake(panelWidth - 60.0, 8.0, 48.0, 32.0);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closePlaybackDiagnosticsAlert) forControlEvents:UIControlEventTouchUpInside];
        [panelView addSubview:closeButton];

        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(12.0, 48.0, panelWidth - 24.0, panelHeight - 60.0)];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textView.editable = NO;
        textView.alwaysBounceVertical = YES;
        textView.font = [UIFont fontWithName:@"Menlo" size:11.0] ?: [UIFont systemFontOfSize:11.0];
        textView.textColor = [UIColor colorWithWhite:0.12 alpha:1.0];
        textView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
        textView.text = log ?: @"";
        [panelView addSubview:textView];

        self.playbackDiagnosticsAlertView = backgroundView;
        [containerView addSubview:backgroundView];
    });
}

- (void)closePlaybackDiagnosticsAlert {
    [self.playbackDiagnosticsAlertView removeFromSuperview];
    self.playbackDiagnosticsAlertView = nil;
}
#endif

/*
// 需要添加播放器 logo 解开这段注释，在这里自定义需要的logo
- (void)addLogo {
    PLVVodPlayerLogo *playerLogo = [[PLVVodPlayerLogo alloc] init];
    
    PLVVodPlayerLogoParam *vodLogoParam = [[PLVVodPlayerLogoParam alloc] init];
    vodLogoParam.logoWidthScale = 0.2;
    vodLogoParam.logoHeightScale = 0.2;
    vodLogoParam.logoUrl = @"https://wwwimg.polyv.net/assets/dist/images/web3.0/doc-home/logo-vod.png";
    [playerLogo insertLogoWithParam:vodLogoParam];
    
    PLVVodPlayerLogoParam *polyvLogoParam = [[PLVVodPlayerLogoParam alloc] init];
    polyvLogoParam.logoWidthScale = 0.1;
    polyvLogoParam.logoHeightScale = 0.1;
    polyvLogoParam.logoAlpha = 0.5;
    polyvLogoParam.position = PLVVodPlayerLogoPositionLeftDown;
    polyvLogoParam.logoUrl = @"https://wwwimg.polyv.net/assets/certificate/polyv-logo.jpeg";
    [playerLogo insertLogoWithParam:polyvLogoParam];
    
    [self.player addPlayerLogo:playerLogo];
}
*/
@end
