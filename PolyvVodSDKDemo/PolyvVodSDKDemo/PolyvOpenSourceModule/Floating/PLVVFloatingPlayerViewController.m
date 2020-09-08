//
//  PLVVFloatingPlayerViewController.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/2/25.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import "PLVVFloatingPlayerViewController.h"
#import "PLVVodPlayerSkin.h"
#import "PLVVodSkinPlayerController.h"
#import "PLVVFloatingWindow.h"
#import "PLVVodUtils.h"
#ifdef PLVCastFeature
#import "PLVCastBusinessManager.h" // 投屏功能管理器
#endif

// 获取导航栏高度
#define NavHight (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)

@interface PLVVFloatingPlayerViewController ()<
UIScrollViewDelegate,
PLVVFloatingWindowProtocol
>

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, strong) UIScrollView *scrollView;
// 主播放器所在视图
@property (nonatomic, strong) UIView *playerPlaceholder;
@property (nonatomic, strong) PLVVodPlayerSkin *skinView;
@property (nonatomic, strong) PLVVodSkinPlayerController *player;

@property (nonatomic, assign) BOOL playInFloatingView;

#ifdef PLVCastFeature
@property (nonatomic, strong) PLVCastBusinessManager * castBM; // 投屏功能管理器
#endif

@end


@implementation PLVVFloatingPlayerViewController

#pragma mark - Life Cycle

- (void)dealloc {
#ifdef PLVCastFeature
    // 若需投屏功能，则需以下代码
    [self.castBM quitAllFuntionc];
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PLVVFloatingPlayerVCLeaveNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"视频悬浮小窗播放Demo页";
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.playerPlaceholder];
    
    if (_player == nil) { // 使用 vid 初始化时
        self.player = [[PLVVodSkinPlayerController alloc] init];
        self.player.rememberLastPosition = YES;
        self.player.enableBackgroundPlayback = YES;
        self.player.autoplay = YES;
        self.player.enableFloating = YES;

        [self setupPlayer];
    } else { // 使用 player 初始化时
        self.vid = self.player.video.vid;
        if (self.navigationController) {
            [self.navigationController setNavigationBarHidden:self.player.playerControl.shouldHideNavigationBar animated:NO];
        }
    }

    [self.player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
    /*
    // 需要添加播放器 logo 解开这段注释
    [self addLogo];
     */
    
    // self.player.playerControl 要在调用完 '-addPlayerOnPlaceholderView:rootViewController:' 后才有值
    self.skinView = (PLVVodPlayerSkin *)self.player.playerControl;
    self.skinView.view.hidden = NO;
    
    __weak typeof (self) weakSelf = self;
    self.skinView.floatingButtonTouchHandler = ^{
        // 首先切换到竖屏
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            [PLVVodUtils changeDeviceOrientation:UIInterfaceOrientationPortrait];
        }
        
        [[PLVVFloatingWindow sharedInstance].contentVctrl addPlayer:weakSelf.player partnerViewController:nil];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    // 若需投屏功能，则需以下代码来启用投屏
#ifdef PLVCastFeature
    if ([PLVCastBusinessManager authorizationInfoIsLegal]) {
        self.castBM = [[PLVCastBusinessManager alloc] initCastBusinessWithListPlaceholderView:self.view player:self.player];
        [self.castBM setup];
    }
#endif
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
    return !self.player.isLockScreen;
}

#pragma mark - Getter & Setter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGFloat screenWidth = MIN(PLV_ScreenWidth, PLV_ScreenHeight);
        CGFloat screenHeight = MAX(PLV_ScreenWidth, PLV_ScreenHeight);
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NavHight, screenWidth, screenHeight - NavHight)];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height * 2);
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIView *)playerPlaceholder {
    if (!_playerPlaceholder) {
        CGFloat width = self.scrollView.frame.size.width;
        _playerPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, NavHight, width, width * 9 / 16)];
    }
    return _playerPlaceholder;
}

#pragma mark - Initialize

- (instancetype)initWithVid:(NSString *)vid {
    self = [self init];
    if (self) {
        _vid = vid;
    }
    return self;
}

- (instancetype)initWithPlayer:(PLVVodSkinPlayerController *)player {
    self = [self init];
    if (self) {
        _player = player;
        // 播放器从悬浮窗转移到页面上时，需将悬浮窗上的播放器移走
        [[PLVVFloatingWindow sharedInstance].contentVctrl removePlayer];
    }
    return self;
}

- (void)setupPlayer {
    // 当前页面只考虑在线视频播放方式，离线播放参考 PLVSimpleDetailController 页面
    NSString *vid = self.vid;
    
    __weak typeof(self) weakSelf = self;
    [PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) { // 在线视频播放，默认会优先播放本地视频
        if (error) {
            weakSelf.player.vid = vid; // 用于播放重试
            if (weakSelf.player.playerErrorHandler) {
                weakSelf.player.playerErrorHandler(weakSelf.player, error);
            };
        } else {
            weakSelf.player.video = video;
        }
    }];
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

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 按照 SDK 的布局方式，只有改变 playerPlaceholder 的 frame 才能让播放器跟随 scrollView 滚动
    CGRect playerHolderRect = self.playerPlaceholder.frame;
    playerHolderRect.origin.y =  self.scrollView.frame.origin.y - scrollView.contentOffset.y;
    self.playerPlaceholder.frame = playerHolderRect;
    
    // 当主播放器移出设备界面时，在小播放器上继续播放
    if (self.playerPlaceholder.frame.origin.y + self.playerPlaceholder.frame.size.height <= NavHight && !self.playInFloatingView) {
        self.playInFloatingView = YES;
        
        [[PLVVFloatingWindow sharedInstance].contentVctrl addPlayer:self.player partnerViewController:self];
    } else if (self.playerPlaceholder.frame.origin.y + self.playerPlaceholder.frame.size.height > NavHight && self.playInFloatingView) {
        self.playInFloatingView = NO;
        
        [self.player addPlayerOnPlaceholderView:self.playerPlaceholder rootViewController:self];
        [[PLVVFloatingWindow sharedInstance].contentVctrl removePlayer];
        if (self.player.teaserState != PLVVodAssetStatePlaying &&
            self.player.adPlayer.state != PLVVodAssetStatePlaying) {
            self.skinView.view.hidden = NO;
        }
    }
}

#pragma mark - PLVVFloatingWindow Protocol

// 点击悬浮窗上的 exchange 按钮回调事件
- (void)exchangePlayer {
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

@end
