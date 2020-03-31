//
//  PLVVFloatingWindow.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/2/26.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVFloatingWindowViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 悬浮窗 UIWindow 类单例
/// 负责悬浮窗的位置拖动、尺寸缩放、点击（皮肤显隐）的手势
/// 持有自己的根控制器 rootViewController，根控制器为 PLVVFloatingWindowViewController
/// 悬浮窗比例默认为16:9，可拖动左上角进行缩放，宽度缩放范围为 [160，屏幕宽]，默认宽度为“屏幕宽度的一半”
@interface PLVVFloatingWindow : UIWindow

/// 悬浮窗窗口的根控制器
@property (nonatomic, strong, readonly) PLVVFloatingWindowViewController *contentVctrl;

+ (instancetype)sharedInstance;

/// 悬浮窗回到初始尺寸、初始位置
- (void)reset;

@end

NS_ASSUME_NONNULL_END
