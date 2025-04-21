//
//  PLVPPTBaseViewController.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/7/26.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVPPTBaseViewController.h"
#import "PLVPPTVideoViewController.h"
#import "PLVVodPPTViewController.h"
#import "PLVFloatingView.h"
#import "PLVPPTActionView.h"
#import "PLVPPTLoadFailAlertView.h"
#import <PLVVodSDK/PLVVodSDK.h>
#ifdef PLVCastFeature
#import "PLVCastBusinessManager.h"
#endif
@interface PLVPPTBaseViewController (PPT)

- (void)getPPT;

- (void)reGetPPTData;

@end

@interface PLVPPTBaseViewController ()<
PLVPPTVideoViewControllerProtocol,
PLVFloatingViewProtocol
>

// isLandscape：YES - 横屏，NO - 竖屏
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) PLVFloatingView *floatingView;

@property (nonatomic, strong) PLVPPTVideoViewController *videoController;
@property (nonatomic, strong) PLVVodPPTViewController *pptController;
@property (nonatomic, strong) PLVPPTActionView *actionView;

@property (nonatomic, assign) CGRect lastSafeFrame;

// 当前播放模式
@property (nonatomic, assign) PLVVodPlayMode playMode;
// 属性 playMode 为 PLVVodPlayModePPT 时该属性有效，YES : ppt 在主屏, NO : ppt 在小窗
@property (nonatomic, assign) BOOL pptOneMainView;

@property (nonatomic, strong) PLVVodPPT *ppt;
@property (nonatomic, assign) BOOL failToGetPPT;
@property (nonatomic, assign) BOOL hasAlert;
@property (nonatomic, strong) PLVPPTLoadFailAlertView *alertView;

// 是否播放本地缓存
@property (nonatomic, assign) BOOL localPlay;
#ifdef PLVCastFeature
@property (nonatomic, strong) PLVCastBusinessManager * castBM; // 投屏功能管理器
#endif
@end

@implementation PLVPPTBaseViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initViews];
    [self initObserver];
    
    [self.videoController playWithVid:self.vid offline:self.isOffline];
    
    // 若需投屏功能，则需以下代码来启用投屏
#ifdef PLVCastFeature
    if ([PLVCastBusinessManager authorizationInfoIsLegal]) {
        self.castBM = [[PLVCastBusinessManager alloc] initCastBusinessWithListPlaceholderView:self.view player:self.videoController.player];
        [self.castBM setup];
    }
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.videoController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoController viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    if ([self needRelayout]) {
        [self layoutSubView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_alertView.superview) {
        self.alertView.hidden = !self.isLandscape;
    }
    
    [self alertForPPTLoadFail];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:self.isLandscape];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _videoController.delegate = nil;
    _floatingView.delegate = nil;
    
#ifdef PLVCastFeature
    [self.castBM quitAllFuntionc];
#endif
}

#pragma mark - Getter & Setter

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
    }
    return _mainView;
}

- (PLVFloatingView *)floatingView {
    if (!_floatingView) {
        _floatingView = [[PLVFloatingView alloc] init];
        _floatingView.hidden = YES;
        _floatingView.delegate = self;
    }
    return _floatingView;
}

- (PLVPPTVideoViewController *)videoController {
    if (!_videoController){
        _videoController = [[PLVPPTVideoViewController alloc] init];
        _videoController.delegate = self;
        _videoController.rootViewController = self;
        
        __weak typeof(self) weakSelf = self;
        _videoController.closeSubscreenButtonActionHandler = ^{
            [weakSelf closeSubScreen];
        };
        _videoController.pptCatalogButtonActionHandler = ^{
            [weakSelf showPPTCatalog];
        };
        _videoController.snapshotButtonActionHandler = ^{
            return [weakSelf snapshot];
        };
    }
    return _videoController;
}

- (PLVVodPPTViewController *)pptController {
    if (!_pptController){
        _pptController = [[PLVVodPPTViewController alloc] init];
    }
    return _pptController;
}

- (PLVPPTActionView *)actionView {
    if (!_actionView) {
        _actionView = [[PLVPPTActionView alloc] initWithPPT:self.ppt];
        __weak typeof(self) weakSelf = self;
        _actionView.didSelectCellHandler = ^(NSInteger index) {
            [weakSelf selectPPTAtIndex:index];
        };
    }
    return _actionView;
}

- (PLVPPTLoadFailAlertView *)alertView {
    if (!_alertView) {
        _alertView = [[PLVPPTLoadFailAlertView alloc] init];
        _alertView.frame = self.mainView.bounds;
        __weak typeof(self) weakSelf = self;
        _alertView.didTapButtonHandler = ^{
            [weakSelf reGetPPTData];
        };
    }
    return _alertView;
}

- (void)setVid:(NSString *)vid {
    _vid = vid;
    self.hasAlert = NO;
}
    
- (void)setPlayMode:(PLVVodPlayMode)playMode {
    if (_playMode == playMode) {
        return;
    }
    
    _playMode = playMode;
    
    if (_playMode == PLVVodPlayModeNormal) { // 普通模式
        self.pptController.ppt = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.floatingView.hidden = !(playMode == PLVVodPlayModePPT && self.pptController.ppt);
        self.pptOneMainView = NO;
    });
}

- (void)setPptOneMainView:(BOOL)pptOneMainView {
    if (_playMode == PLVVodPlayModeNormal) {
        pptOneMainView = NO;
    }
    if (_pptOneMainView == pptOneMainView) {
        return;
    }
    _pptOneMainView = pptOneMainView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self switchScreen];
    });
}

- (void)setFailToGetPPT:(BOOL)failToGetPPT {
    _failToGetPPT = failToGetPPT;
    if (failToGetPPT) {
        [self alertForPPTLoadFail];
    }
}

#pragma mark - Override

- (void)getPPTFail {
}

- (void)getPPTSuccess {
}

- (void)interfaceOrientationDidChange {
}

- (BOOL)prefersStatusBarHidden {
    return self.videoController.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.videoController.preferredStatusBarStyle;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return !(self.videoController.isLockScreen);
}

#pragma mark - Private

- (void)initObserver {
    // 横竖屏切换通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interfaceOrientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    // ijkplayer 重建通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ijkPlayerCreate:)
                                                 name:kNotificationIJKPlayerCreateKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(teaserStateDidChange)
                                                 name:PLVVodPlayerTeaserStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackRecovery)
                                                 name:PLVVodPlaybackRecoveryNotification
                                               object:nil];
}

- (void)getPPTDataSuccess:(BOOL)success ppt:(PLVVodPPT *)ppt {
    if (success) {
        self.ppt = ppt;
        self.pptController.ppt = ppt;
        
        [self getPPTSuccess];
        self.failToGetPPT = NO;
    } else {
        [self.pptController loadPPTFail];
        
        [self getPPTFail];
        self.failToGetPPT = YES;
    }
}

- (void)alertForPPTLoadFail {
    if (self.isLandscape && self.failToGetPPT && self.hasAlert == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainView addSubview:self.alertView];
        });
        self.hasAlert = YES;
    }
}

- (void)adPlayingIsPlaying:(BOOL)adPlaying {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.floatingView.hidden = adPlaying ? YES : (self.playMode == PLVVodPlayModeNormal);
    });
}

#pragma mark Private: Subview & Layout

- (void)initViews {
    [self.view addSubview:self.mainView];
    [self.mainView addSubview:self.videoController.view];
    [self.view addSubview:self.floatingView];
    [self.floatingView insertSubview:self.pptController.view atIndex:0];
    
    self.lastSafeFrame = CGRectZero;
}

- (BOOL)needRelayout {
    
    CGRect safeFrame = self.view.frame;
    if (@available(iOS 11.0, *)) {
        safeFrame = self.view.safeAreaLayoutGuide.layoutFrame;
    }
    
    if (self.lastSafeFrame.origin.x == safeFrame.origin.x &&
        self.lastSafeFrame.origin.y == safeFrame.origin.y &&
        self.lastSafeFrame.size.width == safeFrame.size.width &&
        self.lastSafeFrame.size.height == safeFrame.size.height) {
        return NO;
    }
    
    if (@available(iOS 11.0, *)) {
        self.lastSafeFrame = self.view.safeAreaLayoutGuide.layoutFrame;
    } else {
        self.lastSafeFrame = self.view.frame;
    }
    
    return YES;
}

- (void)layoutSubView {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
    
    [self layoutMainViewLandscape:isLandscape];
    [self layoutFloatingViewLandscape:isLandscape];
    [self layoutScreenContentView];
    
    self.isLandscape = isLandscape;
}

- (void)layoutMainViewLandscape:(BOOL)isLandscape {
    
    if (isLandscape){ // 横屏
        self.mainView.frame = CGRectMake(0, 0, PLV_ScreenWidth, PLV_ScreenHeight);
    } else {
        if (@available(iOS 11.0, *)) {
            CGRect viewFrame = self.view.safeAreaLayoutGuide.layoutFrame;
            self.mainView.frame = CGRectMake(0, viewFrame.origin.y, PLV_ScreenWidth, PLV_ScreenWidth * 9 / 16);
        } else {
            CGFloat navigationHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + 44;
            self.mainView.frame = CGRectMake(0, navigationHeight, PLV_ScreenWidth, PLV_ScreenWidth * 9 / 16);
        }
        
    }
}

- (void)layoutFloatingViewLandscape:(BOOL)isLandscape {
    
    CGSize floatingViewSize = [PLVFloatingView viewSize];
    
    if (isLandscape) {
        CGRect viewFrame = self.view.frame;
        if (@available(iOS 11.0, *)) {
            viewFrame = self.view.safeAreaLayoutGuide.layoutFrame;
        }
        CGFloat originX = viewFrame.origin.x + viewFrame.size.width - floatingViewSize.width;
        CGFloat originY = viewFrame.origin.y;
        self.floatingView.fullScreenPoint = CGPointMake(originX, originY);
        
    } else {
        
        CGRect mainViewRect = self.mainView.frame;
        CGFloat originX = mainViewRect.size.width - floatingViewSize.width;
        CGFloat originY = mainViewRect.origin.y + mainViewRect.size.height;
        self.floatingView.originPoint = CGPointMake(originX, originY);
    }
    
    CGPoint originPoint = isLandscape ? self.floatingView.fullScreenPoint : self.floatingView.originPoint;
    self.floatingView.frame = CGRectMake(originPoint.x, originPoint.y, floatingViewSize.width, floatingViewSize.height);
}

- (void)layoutScreenContentView {
    
    self.videoController.view.frame = self.mainView.bounds;
    
    if (self.pptOneMainView) {
        self.videoController.videoView.frame = self.floatingView.bounds;
        self.pptController.view.frame = self.mainView.bounds;
    } else {
        self.videoController.videoView.frame = self.mainView.bounds;
        self.pptController.view.frame = self.floatingView.bounds;
    }
}

- (void)switchScreen {
    if (self.pptOneMainView) {
        [self.videoController insertView:self.pptController.view];
        
        [self.floatingView insertSubview:[self.videoController videoView] atIndex:0];
        self.videoController.videoView.frame =  self.floatingView.bounds;
    } else {
        [self.videoController insertView:[self.videoController videoView]];
        [self.floatingView insertSubview:self.pptController.view atIndex:0];
        self.pptController.view.frame =  self.floatingView.bounds;
    }
    [self changeSkin];
}

- (void)changeSkin {
    if (self.pptOneMainView) {
        [self.floatingView addSubview:self.videoController.skinAnimationCoverView];
        [self.videoController setAudioAniViewCornerRadius:30];
        [self constrainSubview:self.videoController.skinAnimationCoverView toMatchWithSuperview:self.floatingView];
        
        [self.floatingView addSubview:self.videoController.skinCoverView];
        [self constrainSubview:self.videoController.skinCoverView toMatchWithSuperview:self.floatingView];
        
        [self.floatingView addSubview:self.videoController.skinLoadingView];
        [self constrainSubview:self.videoController.skinLoadingView toMatchWithSuperview:self.floatingView];
        
    } else {
        [self.videoController recoverCoverView];
        
        [self.videoController recoverAudioAnimationCoverView];
        
        [self.videoController recoverLoadingView];
    }
}

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

#pragma mark Private: Skin Button Action Related

- (void)closeSubScreen {
    if (self.playMode == PLVVodPlayModeNormal) {
        return;
    }
    self.floatingView.hidden = !self.floatingView.hidden;
}

- (void)showPPTCatalog {
    if (self.ppt) {
        [self.actionView show];
    } else {
        [self.mainView addSubview:self.alertView];
    }
}

- (UIImage *)snapshot {
    
    [self.videoController hiddenSkin:YES];
    
    UIImage *viewImage = nil;
    if (@available(iOS 17.0, *)) {
        UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
        format.opaque = YES;
        format.scale = 0.0;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:[[UIScreen mainScreen] bounds].size format:format];
        viewImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull ref) {
            [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        }];
    } else {
        UIGraphicsBeginImageContextWithOptions([[UIScreen mainScreen] bounds].size, YES, 0.0);
        BOOL success = [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        viewImage = success ? UIGraphicsGetImageFromCurrentImageContext() : nil;
        UIGraphicsEndImageContext();
    }
    
    [self.videoController hiddenSkin:NO];
    
    return viewImage;
}

#pragma mark - Action

- (void)selectPPTAtIndex:(NSInteger)index {
    [self.pptController playPPTAtIndex:index];
    
    PLVVodPPTPage *page = self.ppt.pages[index];
    NSTimeInterval time = (NSTimeInterval)page.timing;
    [self.videoController setCurrentPlaybackTime:time];
}

#pragma mark - NSNotification

- (void)interfaceOrientationDidChange:(NSNotification *)notification {

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
    [self.navigationController setNavigationBarHidden:isLandscape];
    
    if (@available(iOS 11.0, *)) {
        self.lastSafeFrame = self.view.safeAreaLayoutGuide.layoutFrame;
    } else {
        self.lastSafeFrame = self.view.frame;
    }
    
    [self layoutSubView];
    [self interfaceOrientationDidChange];
}

- (void)ijkPlayerCreate:(NSNotification *)notification {
    if (self.pptOneMainView){ // 副屏需要重新加载 videoView 到副屏
        [self.floatingView insertSubview:[self.videoController videoView] atIndex:0];
        self.videoController.videoView.frame =  self.floatingView.bounds;
    }
}

- (void)teaserStateDidChange {
    PLVVodAssetState state = self.videoController.player.teaserState;
    BOOL adPlay = (state == PLVVodAssetStateUnknown || state == PLVVodAssetStateLoading || state == PLVVodAssetStatePlaying);
    [self adPlayingIsPlaying:adPlay];
    if (state == PLVVodAssetStateFinished && self.playMode == PLVVodPlayModePPT) {
        [self getPPT];
    }
}

- (void)playbackRecovery {
    PLVVodVideo *video =self.videoController.player.video;
    [self videoWithVid:video.vid title:video.title hasPPT:video.hasPPT localPlay:NO];
}

#pragma mark - PLVPPTVideoViewControllerProtocol

- (void)videoWithVid:(NSString *)vid title:(NSString *)title hasPPT:(BOOL)hasPPT localPlay:(BOOL)localPlay {
    if (![vid isEqualToString:self.vid]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = title;
    });
    
    self.localPlay = localPlay;
    BOOL showPPT = self.videoController.player.enablePPT ? hasPPT : NO;
    self.playMode = showPPT ? PLVVodPlayModePPT : PLVVodPlayModeNormal;
    
    if (showPPT) {
        if (self.videoController.player.teaserState == PLVVodAssetStateFinished) {
            [self getPPT];
        }
    } else {
        self.ppt = nil;
        self.failToGetPPT = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    self.videoController.player.playbackTimeHandler = ^(NSTimeInterval currentPlaybackTime) {
        [weakSelf.pptController playAtCurrentSecond:(int)currentPlaybackTime];
    };
}

- (PLVVodPlaybackMode)currenPlaybackMode {
    return self.playbackMode;
}

#pragma mark - PLVFloatingViewProtocol

- (void)tapAtFloatingView:(PLVFloatingView *)floatingView {
    self.pptOneMainView = !self.pptOneMainView;
}

@end

#pragma mark -

@implementation PLVPPTBaseViewController (PPT)

#pragma mark - Public

- (void)getPPT {
    if (self.localPlay) { // 获取本地ppt json
        [self getLocalPPTJson];
    } else { // 在线获取 PPT
        [self getPPTJson];
    }
}

- (void)reGetPPTData {
    if (self.localPlay) {
        [self downloadPPT];
    } else {
        [self getPPTJson];
    }
}

- (void)getPPTSuccessCallback:(PLVVodPPT *)ppt {
    [self getPPTDataSuccess:YES ppt:ppt];
}

- (void)getPPTFailCallback {
    [self getPPTDataSuccess:NO ppt:nil];
}

- (void)addLogoWithParam:(NSArray <PLVVodPlayerLogoParam *> *)paramArray {
    [self.videoController addLogoWithParam:paramArray];
}

#pragma mark - Private

- (void)getPPTJson {
    [self.pptController startLoading];
    __weak typeof(self) weakSelf = self;
    [PLVVodPPT requestPPTWithVid:self.vid completion:^(PLVVodPPT * _Nullable ppt, NSError * _Nullable error) {
        if (error == nil && ppt) {
            [weakSelf getPPTSuccessCallback:ppt];
        } else {
            [weakSelf getPPTFailCallback];
        }
    }];
}

- (void)getLocalPPTJson {
    __weak typeof(self) weakSelf = self;
    [PLVVodPPT requestCachePPTWithVid:self.vid completion:^(PLVVodPPT * _Nullable ppt, NSError * _Nullable error) {
        if (error == nil && ppt) {
            [weakSelf getPPTSuccessCallback:ppt];
        } else {
            [weakSelf getPPTFailCallback];
        }
    }];
}

- (void)downloadPPT {
    [self.pptController startDownloading];
    PLVVodVideo *video = self.videoController.player.video;
    [[PLVVodDownloadManager sharedManager] downloadPPTWithVideo:video completion:^(PLVVodDownloadInfo *info) {
        [self handlePPTDownload:info];
    }];
}

- (void)handlePPTDownload:(PLVVodDownloadInfo *)info {
    __weak typeof(self) weakSelf = self;
    PLVVodDownloadInfo *downloadInfo = info;
    downloadInfo.progressDidChangeBlock = ^(PLVVodDownloadInfo *info) {
        NSLog(@"-- %f --", info.progress);
        [weakSelf.pptController setDownloadProgress:info.progress];
    };
    
    downloadInfo.stateDidChangeBlock = ^(PLVVodDownloadInfo *info) {
        NSLog(@"-- %zd --", info.state);
        if (info.state == PLVVodDownloadStateSuccess) {
            [weakSelf getLocalPPTJson];
        } else if (info.state == PLVVodDownloadStateFailed) {
            [weakSelf getPPTFailCallback];
        }
    };
}

@end
