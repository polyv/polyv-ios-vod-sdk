//
//  PLVCastBusinessManager.h
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2019/1/7.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <PLVVodSDK/PLVVodSDK.h>
#import "PLVCastManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVCastBusinessManager : NSObject

@property (nonatomic, weak, readonly) UIView * listPlaceholderView;
@property (nonatomic, weak, readonly) PLVVodPlayerViewController * player;

@property (nonatomic, strong, readonly) PLVCastManager * castManager; // 投屏管理器

/**
 初始化

 @param listPlaceholderView 列表选择视图的父视图
 @param player 播放器
 @return 实例对象
 */
- (instancetype)initCastBusinessWithListPlaceholderView:(UIView *)listPlaceholderView
                                                 player:(PLVVodPlayerViewController *)player;

// 启用投屏功能
- (void)setup;

// 获取授权，当可能需要投屏业务时，可提前调用此方法。生命周期中仅第一次调用有效
+ (void)getCastAuthorization;

// 获知注册信息是否具备，将决定是否允许启动注册逻辑
+ (BOOL)authorizationInfoIsLegal;

// 当退出页面时，要调用此方法停止所有功能
- (void)quitAllFuntionc;

@end

NS_ASSUME_NONNULL_END
