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

@property (weak, nonatomic) IBOutlet UIView *playerPlaceholder;
@property (nonatomic, strong) PLVVodSkinPlayerController *player;
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
	
    [self setupPlayer];
    /*
    // 需要添加播放器 logo 解开这段注释
    [self addLogo];
     */
    
    // 兼容Demo的下载视频观看页，一般集成时无需添加此段代码
    if (self.playerPlaceholder == nil) {
        UIView * playerPlaceholderV = [[UIView alloc]initWithFrame:CGRectMake(0, NavHight, PLV_ScreenWidth, PLV_ScreenHeight - NavHight)];
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
}

- (void)loadView{
    if (self.systemScreenShotProtect){
        PLVSecureView *secureView = [[PLVSecureView alloc] init];
        self.view = secureView.secureView;
    }else{
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
    [player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
	self.player = player;
    self.player.rememberLastPosition = YES;
    self.player.enableBackgroundPlayback = YES;
    self.player.autoplay = YES;
    self.player.enableLocalViewLog = YES;
    
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
