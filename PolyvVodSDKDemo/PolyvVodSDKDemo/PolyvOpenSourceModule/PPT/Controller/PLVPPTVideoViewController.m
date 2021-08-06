//
//  PLVPPTVideoViewController.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/7/26.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVPPTVideoViewController.h"
#import "PLVVodPlayerSkin.h"
#import "PLVVodAudioCoverPanelView.h"
#import "PLVVodExamViewController.h"

@interface PLVPPTVideoViewController ()<
PLVVodPlayerSkinPPTVideoProtocol
>

@property (nonatomic, strong) PLVVodSkinPlayerController *player;
@property (nonatomic, strong) PLVVodPlayerSkin *skinView;

@end

@implementation PLVPPTVideoViewController

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.player viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.player.view];
    self.skinView = (PLVVodPlayerSkin *)self.player.playerControl;
    self.skinView.pptVideoDelegate = self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.player.view.frame = self.view.bounds;
}

- (void)dealloc {
    self.skinView.pptVideoDelegate = nil;
}

#pragma mark - Getter & Setter

- (PLVVodSkinPlayerController *)player {
    if (!_player){
        _player = [[PLVVodSkinPlayerController alloc] init];
        _player.rememberLastPosition = YES;
        _player.enableBackgroundPlayback = YES;
        _player.autoplay = YES;
        _player.enablePPT = YES;
        //_player.enableLocalViewLog = YES;
    }
    return _player;
}

- (UIView *)videoView {
    UIView *playerView = [self.player videoView];;
    return playerView;
}

- (UIView *)skinLoadingView {
//    UIView *view = self.skinView.loadingIndicator;
    UIView *view = self.skinView.loadingContainerView;
    return view;
}

- (UIView *)skinCoverView {
    UIView *coverView = (UIView *)self.skinView.coverView;
    return coverView;
}

- (UIView *)skinAnimationCoverView {
    UIView *coverAudioView = (UIView *)self.skinView.audioCoverPanelView;
    return coverAudioView;
}

- (BOOL)isLockScreen {
    return self.player.isLockScreen;
}

#pragma mark - Public

- (void)playWithVid:(NSString *)vid offline:(BOOL)isOffline {
    
    __weak typeof(self) weakSelf = self;
    
    if (isOffline) { // 离线视频播放
        // 根据资源类型设置默认播放模式。本地音频文件设定音频播放模式，本地视频文件设定视频播放模式
        // 只针对开通视频转音频服务的用户
        self.player.playbackMode = self.delegate ? [self.delegate currenPlaybackMode] : PLVVodPlaybackModeDefault;
        
        [PLVVodVideo requestVideoPriorityCacheWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
            if (video && error == nil) {
                weakSelf.player.video = video;
                if (weakSelf.delegate) {
                    [weakSelf.delegate videoWithVid:vid title:video.title hasPPT:(video.hasPPT && video.available) localPlay:YES];
                }
            }
        }];
    } else { // 在线视频播放，默认会优先播放本地视频
        [PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
            if (error) { // 用于播放重试
                weakSelf.player.vid = vid;
                if (weakSelf.player.playerErrorHandler) {
                    weakSelf.player.playerErrorHandler(weakSelf.player, error);
                }
            } else {
                weakSelf.player.video = video;
                BOOL localPlay = [weakSelf.player checkVideoWillPlayLocal:video];
                if (weakSelf.delegate) {
                    [weakSelf.delegate videoWithVid:vid title:video.title hasPPT:(video.hasPPT && video.available) localPlay:localPlay];
                }
            }
        }];
    }
}

- (void)insertView:(UIView *)subView {
    subView.frame = self.player.view.bounds;
    [self.player.view insertSubview:subView atIndex:0];
}

- (void)hiddenSkin:(BOOL)hidden {
    self.skinView.view.hidden = hidden;
}

- (void)recoverCoverView {
    [self.skinView.view addSubview:self.skinCoverView];
    [self.skinView.view sendSubviewToBack:self.skinCoverView];
    [self constrainSubview:self.skinCoverView toMatchWithSuperview:self.skinView.view];
}

- (void)recoverAudioAnimationCoverView {
    [self.skinView.view addSubview:self.skinAnimationCoverView];
    [self.skinView.view sendSubviewToBack:self.skinAnimationCoverView];
    [self constrainSubview:self.skinAnimationCoverView toMatchWithSuperview:self.skinView.view];
    
    [self.skinView.audioCoverPanelView setAniViewCornerRadius:60];
}

- (void)recoverLoadingView {
    [self.skinView.view addSubview:self.skinLoadingView];
    [self.skinView.view sendSubviewToBack:self.skinLoadingView];
    [self constrainSubview:self.skinLoadingView toMatchWithSuperview:self.skinView.view];
}

- (void)setAudioAniViewCornerRadius:(CGFloat)cornerRadius {
    [self.skinView.audioCoverPanelView setAniViewCornerRadius:cornerRadius];
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    if (self.player.examViewController.showing) {
        return;
    }
    [self.player setCurrentPlaybackTime:currentPlaybackTime];
}

- (void)addLogoWithParam:(NSArray <PLVVodPlayerLogoParam *> *)paramArray {
    PLVVodPlayerLogo *playerLogo = self.player.logoView;
    if (!playerLogo) {
        playerLogo = [[PLVVodPlayerLogo alloc] init];
        [self.player addPlayerLogo:playerLogo];
    }
    for (PLVVodPlayerLogoParam *param in paramArray) {
        [playerLogo insertLogoWithParam:param];
    }
}

#pragma mark - Private

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

#pragma mark - Override

- (BOOL)prefersStatusBarHidden {
    return self.skinView.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.skinView.preferredStatusBarStyle;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return !(self.player.isLockScreen);
}

#pragma mark - PLVVodPlayerSkinPPTVideoProtocol

- (void)tapSubScreenButton:(PLVVodPlayerSkin *)skin {
    if (self.closeSubscreenButtonActionHandler) {
        self.closeSubscreenButtonActionHandler();
    }
}

- (void)tapPPTCatalogButton:(PLVVodPlayerSkin *)skin {
    if (self.pptCatalogButtonActionHandler) {
        self.pptCatalogButtonActionHandler();
    }
}

- (UIImage *)tapSnapshotButton:(PLVVodPlayerSkin *)skin {
    if (self.snapshotButtonActionHandler) {
        return self.snapshotButtonActionHandler();
    }
    return nil;
}

@end
