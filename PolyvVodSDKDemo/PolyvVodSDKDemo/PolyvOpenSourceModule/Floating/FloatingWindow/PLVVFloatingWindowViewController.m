//
//  PLVVFloatingWindowViewController.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/2/27.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import "PLVVFloatingWindowViewController.h"
#import "PLVVodSkinPlayerController.h"
#import "PLVVodPlayerSkin.h"
#import "PLVVFloatingWindowSkin.h"
#import "PLVVFloatingWindow.h"
#import "PLVVFloatingPlayerViewController.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import <YYWebImage/YYWebImage.h>

NSString *PLVVFloatingWindowEnterNotification = @"PLVVFloatingWindowEnterNotification";
NSString *PLVVFloatingWindowLeaveNotification = @"PLVVFloatingWindowLeaveNotification";
NSString *PLVVFloatingPlayerVCLeaveNotification = @"PLVVFloatingPlayerVCLeaveNotification";

@interface PLVVFloatingWindowViewController ()<
PLVVFloatingWindowSkinProtocol
>

/// 悬浮窗拖动手势响应区域
@property (nonatomic, strong) UIView *zoomView;

/// 悬浮窗控制按钮层
@property (nonatomic, strong) PLVVFloatingWindowSkin *windowSkin;

/// 音视频封面，视频播放时隐藏
@property (nonatomic, strong) UIImageView *coverImageView;

/// 当前播放的内容为视频则 isVideo 为 YES，音频为 NO
@property (nonatomic, assign) BOOL isVideo;

@property (nonatomic, strong) NSString *vid;

@property (nonatomic, strong) PLVVodSkinPlayerController *player;

/// 悬浮窗持有的播放器皮肤，悬浮窗没有播放视频时为 nil，默认值为 nil
@property (nonatomic, strong) PLVVodPlayerSkin *playerSkin;

/// 悬浮窗口所在页面是否存在一个主播放器，否的话 partnerViewController 为 nil，是 partnerViewController 为主播放器所在 VC
@property (nonatomic, weak) id<PLVVFloatingWindowProtocol> partnerViewController;
/// 悬浮窗口所在页面是否存在一个主播放器，若是 playInSelfVC 为 YES，默认为 NO
@property (nonatomic, assign) BOOL playInSelfVC;

@end

@implementation PLVVFloatingWindowViewController

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _isVideo = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.windowSkin];
    [self.view addSubview:self.zoomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leavePlayerVC) name:PLVVFloatingPlayerVCLeaveNotification object:nil];
    // 广告或片头播放结束时的广播
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adAndTeasersPlayFinish) name:PLVVodADAndTeasersPlayFinishNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    self.windowSkin.frame = self.view.bounds;
    self.coverImageView.frame = self.view.bounds;
    
    // 悬浮窗拖动手势响应区域一定要位于子视图最顶层，控制按钮层位于次顶层
    [self.view bringSubviewToFront:self.coverImageView];
    [self.view bringSubviewToFront:self.windowSkin];
    [self.view bringSubviewToFront:self.zoomView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getters & Setters

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
    }
    return _coverImageView;
}

- (PLVVFloatingWindowSkin *)windowSkin {
    if (!_windowSkin) {
        _windowSkin = [[PLVVFloatingWindowSkin alloc] initWithFrame:self.view.bounds];
        _windowSkin.delegate = self;
        _windowSkin.hidden = YES;
    }
    return _windowSkin;
}

- (UIView *)zoomView {
    if (!_zoomView) {
        // 可在这里更改缩放响应区域的大小与位置
        _zoomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    }
    return _zoomView;
}

#pragma mark - Public

- (void)addPlayer:(PLVVodSkinPlayerController *)player partnerViewController:(id<PLVVFloatingWindowProtocol>)vctrl {
    self.partnerViewController = vctrl;
    self.playInSelfVC = vctrl ? YES : NO;
    
    [PLVVFloatingWindow sharedInstance].hidden = NO;
    
    if (self.player && self.player != player) {
        [self.player destroyPlayer];
    }
    
    self.player = player;
    self.playerSkin = (PLVVodPlayerSkin *)self.player.playerControl;
    self.playerSkin.view.hidden = YES;
    [self.player addPlayerOnPlaceholderView:self.view rootViewController:self];
    
    self.vid = self.player.video.vid;
    [self updateCoverView];
    [self.windowSkin statusIsPlaying:(self.player.playbackState == PLVVodPlaybackStatePlaying)];
    
    __weak typeof(self) weakSelf = self;
    self.player.playbackStateHandler = ^(PLVVodPlayerViewController *player) {
        [weakSelf.windowSkin statusIsPlaying:(player.playbackState == PLVVodPlaybackStatePlaying)];
        if (weakSelf.isVideo && player.playbackState == PLVVodPlaybackStatePlaying) {
            weakSelf.coverImageView.hidden = YES;
        }
    };
    
    //进入悬浮窗通知事件
    [[NSNotificationCenter defaultCenter] postNotificationName:PLVVFloatingWindowEnterNotification object:nil];
}

- (void)destroyPlayer {
    if (self.player) {
        [self.player destroyPlayer];
        [self.player.view removeFromSuperview];
    }
    
    [self removePlayer];
}

- (void)removePlayer {
    // 隐藏悬浮窗
    [PLVVFloatingWindow sharedInstance].hidden = YES;
    
    // 移除播放器、播放器皮肤、vid 的持有
    self.player = nil;
    self.playerSkin = nil;
    self.vid = nil;
    self.partnerViewController = nil;
    self.playInSelfVC = NO;
    self.isVideo = YES;
    self.coverImageView.image = nil;
    
    //退出悬浮窗通知事件
    [[NSNotificationCenter defaultCenter] postNotificationName:PLVVFloatingWindowLeaveNotification object:nil];
}

#pragma mark - Private

- (void)pushPlayerVC:(PLVVFloatingPlayerViewController *)vctrl {
    UIViewController *currentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([currentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)currentViewController;
        if ([currentViewController presentedViewController]) {
            UIViewController *presentedVC = [currentViewController presentedViewController];
            [presentedVC dismissViewControllerAnimated:NO completion:^{
                [nav pushViewController:vctrl animated:YES];
            }];
        } else {
            [nav pushViewController:vctrl animated:YES];
        }
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vctrl];
        [nav pushViewController:vctrl animated:YES];
        [currentViewController presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark 音视频封面图

- (void)updateCoverView {
    PLVVodVideo *video = self.player.video;
    if (self.player == nil || video == nil) {
        return;
    }

    NSString *coverUrl = video.snapshot;
    if (coverUrl == nil || ![coverUrl isKindOfClass:[NSString class]] || coverUrl.length == 0) {
        return;
    }
    
    NSString * fileUrl = nil;
    if ([video isKindOfClass: [PLVVodLocalVideo class]]) { // 是本地文件
        PLVVodLocalVideo * localVideoModel = (PLVVodLocalVideo *)video;
        fileUrl = localVideoModel.path;
    } else { // 非本地文件
        fileUrl = (video.keepSource == NO) ? video.hlsIndex : video.play_source_url;
    }
    
    if (fileUrl && [fileUrl isKindOfClass:[NSString class]] && fileUrl.length != 0) { // 判断链接是否存在
        self.isVideo = ![fileUrl hasSuffix:@".mp3"];
        
        NSString *coverUrl = video.snapshot;
        [self.coverImageView yy_setImageWithURL:[NSURL URLWithString:coverUrl] options:0];
        self.coverImageView.hidden = YES;
        [self.view insertSubview:self.coverImageView atIndex:1];
    }
}

#pragma mark - Windoe API （用于 PLVVFloatingWindow 窗口类的 API）

/// 隐藏/显示控制按钮层
- (void)hiddenSkin:(BOOL)hidden {
    self.windowSkin.hidden = hidden;
}

/// 返回【控制按钮层是否隐藏】布尔值
- (BOOL)isSkinHidden {
    return self.windowSkin.hidden;
}

#pragma mark - NSNotification

- (void)leavePlayerVC {
    if (self.playInSelfVC) {
        [self destroyPlayer];
    }
}

// 广告或片头播放结束时，播放器皮肤会取消隐藏，需在这里重新隐藏
- (void)adAndTeasersPlayFinish {
    if (self.playerSkin) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playerSkin.view.hidden = YES;
            self.coverImageView.hidden = NO;
        });
    }
}

#pragma mark - PLVVFloatingWindowSkin Protocol （悬浮窗控制按钮响应回调）

- (void)tapCloseButton {
    if (self.partnerViewController) { // 当前页面有主播放器：播放暂停，播放器移除
        [self.player pause];
        [self removePlayer];
    } else { // 当前页面无主播放器：播放停止，播放器销毁
        [self destroyPlayer];
    }
    
    // 悬浮窗回到初始尺寸与位置
    [[PLVVFloatingWindow sharedInstance] reset];
}

- (void)tapExchangeButton {
    if (self.partnerViewController) { // 当前页面有主播放器：通知当前页面响应 exchange 按钮
        if ([self.partnerViewController respondsToSelector:@selector(exchangePlayer)]) {
            [self.partnerViewController exchangePlayer];
        }
    } else { // 当前页面无主播放器：进入播放页面
        PLVVFloatingPlayerViewController *vctrl = [[PLVVFloatingPlayerViewController alloc] initWithPlayer:self.player];
        [self pushPlayerVC:vctrl];
    }
    
    // 此时播放器 self.player 已由播放页面持有，可移除悬浮窗口持有的播放器
    [self removePlayer];
    
    // 悬浮窗回到初始位置
    [[PLVVFloatingWindow sharedInstance] reset];
}

- (void)tapPlayButton:(BOOL)play {
    if (play) {
        [self.player play];
    } else {
        [self.player pause];
    }
}

@end
