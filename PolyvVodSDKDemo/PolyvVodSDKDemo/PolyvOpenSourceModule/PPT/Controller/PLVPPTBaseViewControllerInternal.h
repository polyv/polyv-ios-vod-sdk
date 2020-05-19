#ifdef PLVPPTBASEVIEWCONTROLLER_PROTECTED_ACCESS
//
//  PLVPPTBaseViewControllerInternal.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/1.
//  Copyright © 2019 POLYV. All rights reserved.
//
// 暴露给子类的私有属性和私有方法
// 限制使用此头文件，防止被别的类误用

#import "PLVPPTBaseViewController.h"
#import "PLVPPTVideoViewController.h"
#import "PLVVodPPTViewController.h"
#import "PLVFloatingView.h"
#import <PLVVodSDK/PLVVodPPT.h>

@interface PLVPPTBaseViewController ()

@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) PLVFloatingView *floatingView;

@property (nonatomic, strong) PLVPPTVideoViewController *videoController;
@property (nonatomic, strong) PLVVodPPTViewController *pptController;

@property (nonatomic, assign) CGRect lastSafeFrame;

// 当前播放模式
@property (nonatomic, assign) PLVVodPlayMode playMode;
// 属性 playMode 为 PLVVodPlayModePPT 时该属性有效，YES : ppt 在主屏, NO : ppt 在小窗
@property (nonatomic, assign) BOOL pptOneMainView;

@property (nonatomic, strong) PLVVodPPT *ppt;

// 是否播放本地缓存
@property (nonatomic, assign) BOOL localPlay;

// 进行 ppt 切换
- (void)selectPPTAtIndex:(NSInteger)index;

// 加载 ppt 失败时可使用该方法进行再次获取
- (void)reGetPPTData;

// 添加播放器 logo
- (void)addLogoWithParam:(NSArray <PLVVodPlayerLogoParam *> *)paramArray;

@end

#else
#error Only be included by subclass or category!
#endif
