//
//  PLVVFloatingWindow.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/2/26.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import "PLVVFloatingWindow.h"
#import <PLVVodSDK/PLVVodSDK.h>

@interface PLVVFloatingWindowViewController ()

@property (nonatomic, strong) UIView *zoomView;

- (void)hiddenSkin:(BOOL)hidden;

- (BOOL)isSkinHidden;

@end

@interface PLVVFloatingWindow ()

/// 悬浮窗宽度，默认值为设备屏幕宽度的一半
@property (nonatomic, assign) CGFloat windowWidth;
/// 悬浮窗宽高比，默认 16 : 9
@property (nonatomic, assign) CGFloat sizeScale;
/// 悬浮窗初始位置，默认为离屏幕底部 100pt，离屏幕右侧 10pt
@property (nonatomic, assign) CGPoint originPoint;

@property (nonatomic, strong) PLVVFloatingWindowViewController *contentVctrl;
@property (nonatomic, strong) UIPanGestureRecognizer *zoomGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL orientationChanged;

@end

@implementation PLVVFloatingWindow

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        self.hidden = YES;
        self.windowLevel = UIWindowLevelNormal + 1;
        
        [self reset];
        
        self.rootViewController = self.contentVctrl;
        
        // 添加缩放手势
        [self.contentVctrl.zoomView addGestureRecognizer:self.zoomGestureRecognizer];
        // 添加拖动手势
        [self addGestureRecognizer:self.panGestureRecognizer];
        // 添加触碰手势
        [self addGestureRecognizer:self.tapGestureRecognizer];
        // 监听是否有新播放器被创建，若有，销毁悬浮窗上的播放器
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ijkPlayerCreate:)
                                                     name:kNotificationIJKPlayerCreateKey
                                                   object:nil];
        // 横竖屏切换通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(interfaceOrientationDidChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    if (self.orientationChanged) {
        [self reset];
        self.orientationChanged = NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getters & Setters

- (PLVVFloatingWindowViewController *)contentVctrl {
    if (!_contentVctrl) {
        _contentVctrl = [[PLVVFloatingWindowViewController alloc] init];
    }
    return _contentVctrl;
}

- (UIPanGestureRecognizer *)zoomGestureRecognizer {
    if (!_zoomGestureRecognizer) {
        _zoomGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(zoomWindow:)];
    }
    return _zoomGestureRecognizer;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragWindow:)];
    }
    return _panGestureRecognizer;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWindow:)];
    }
    return _tapGestureRecognizer;
}

#pragma mark - Public

+ (instancetype)sharedInstance {
    static PLVVFloatingWindow *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    return _sharedInstance;
}

/// 恢复悬浮窗大小与位置
- (void)reset {
    // 如需修改悬浮窗尺寸、宽高比及初始化位置，可在此修改这三个属性
    self.windowWidth = MIN(PLV_ScreenWidth, PLV_ScreenHeight) / 2.0;
    self.sizeScale = 16.0 / 9.0;
    self.originPoint = CGPointMake(PLV_ScreenWidth - self.windowWidth - 10, PLV_ScreenHeight - self.windowWidth / self.sizeScale - 100);
    
    CGFloat width = self.windowWidth;
    CGFloat height = width / self.sizeScale;
    self.frame = CGRectMake(self.originPoint.x, self.originPoint.y, width, height);
}

#pragma mark - Action

- (void)zoomWindow:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        return;
    }
    
    
    CGPoint location = [gesture locationInView:self];
    if (location.x < -10 || location.x > 42 ||
        location.y < -10 || location.y > 42) { // 触碰点离响应热区超过10pt时取消手势，响应热区大小为 32pt x 32pt
        gesture.state = UIGestureRecognizerStateCancelled;
        return;
    }
    
    CGPoint translatedPoint = [gesture translationInView:[UIApplication sharedApplication].delegate.window];
    CGFloat xZoom = -translatedPoint.x;
    CGFloat yZoom = -translatedPoint.y;
    if (xZoom * yZoom <= 0) {// 不能往左下角或右上角缩放
        [gesture setTranslation:CGPointMake(0, 0) inView:[UIApplication sharedApplication].delegate.window];
        return;
    }
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    CGFloat width = originWidth + xZoom;
    width = MAX(MIN(PLV_ScreenWidth, width), 160); // 小窗宽度范围 [160，屏幕宽]
    CGFloat height = width / self.sizeScale; // 缩放时小窗宽高比保持不变
    
    CGRect rect = self.frame;
    CGFloat originX = rect.origin.x - (width - originWidth);
    CGFloat originY = rect.origin.y - (height - originHeight);
    CGFloat navigationHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + 44;
    if (originX < 0) { // 悬浮窗左边沿不能超过屏幕左侧
        gesture.state = UIGestureRecognizerStateCancelled;
        return;
    }
    if (originY < navigationHeight) { // 悬浮窗上沿不能高于导航栏
        gesture.state = UIGestureRecognizerStateCancelled;
        return;
    }
    
    self.frame = CGRectMake(originX, originY, width, height);
    [gesture setTranslation:CGPointMake(0, 0) inView:[UIApplication sharedApplication].delegate.window];
    
    if (![self.contentVctrl isSkinHidden]) { // 缩放过程中，如果小播放器上的皮肤（控制按钮层）是显示中则不隐藏，重新进行5秒倒计时
        [self resetTimer];
    }
}

- (void)dragWindow:(UIPanGestureRecognizer *)gesture {
    CGPoint translatedPoint = [gesture translationInView:[UIApplication sharedApplication].delegate.window];
    CGFloat x = gesture.view.center.x + translatedPoint.x;
    CGFloat y = gesture.view.center.y + translatedPoint.y;
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        gesture.view.center = CGPointMake(x, y);
        [gesture setTranslation:CGPointMake(0, 0) inView:[UIApplication sharedApplication].delegate.window];
        return;
    }
    
    CGFloat navigationHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + 44;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (x > PLV_ScreenWidth - 0.5 * width) {// 不允许拖离屏幕右侧
        x = PLV_ScreenWidth - 0.5 * width;
    } else if (x < width * 0.5) { // 不允许拖离屏幕左侧
        x = width * 0.5;
    }
    
    if (y > PLV_ScreenHeight - height * 0.5) { // 不允许拖离屏幕底部
        y = PLV_ScreenHeight - height * 0.5;
    } else if (y < height * 0.5 + navigationHeight) { // 不允许往上拖到挡住导航栏
        y = height * 0.5 + navigationHeight;
    }
    
    gesture.view.center = CGPointMake(x, y);
    [gesture setTranslation:CGPointMake(0, 0) inView:[UIApplication sharedApplication].delegate.window];
}

- (void)tapWindow:(UITapGestureRecognizer *)gesture {
    [self.contentVctrl hiddenSkin:NO]; // 触碰悬浮窗时显示小播放器上的皮肤（控制按钮层）并开启5秒计时，5秒后皮肤隐藏
    [self resetTimer];
}

#pragma mark - NSNotification

- (void)ijkPlayerCreate:(NSNotification *)notification {
    [self.contentVctrl destroyPlayer];
}

#pragma mark - Private

// 隐藏控制按钮层并取消倒计时
- (void)hiddenSkin {
    [self.contentVctrl hiddenSkin:YES];
    [self invalidTimer];
}

// 倒计时重置并开启
- (void)resetTimer {
    [self invalidTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hiddenSkin) userInfo:nil repeats:NO];
}

// 取消倒计时
- (void)invalidTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - NSNotification related

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    self.orientationChanged = YES;
}

@end
