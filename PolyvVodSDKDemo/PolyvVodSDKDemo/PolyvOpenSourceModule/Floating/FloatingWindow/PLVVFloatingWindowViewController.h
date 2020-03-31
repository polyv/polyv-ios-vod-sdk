//
//  PLVVFloatingWindowViewController.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/2/27.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
/// 大播放器所在页面遵循协议，用于响应悬浮窗控制按钮
@class PLVVodSkinPlayerController;

@protocol PLVVFloatingWindowProtocol <NSObject>

/// 悬浮窗【exchange】按钮响应回调
- (void)exchangePlayer;

@end

NS_ASSUME_NONNULL_BEGIN

// 进入悬浮窗模式广播事件
extern NSString *PLVVFloatingWindowEnterNotification;
// 退出悬浮窗模式广播事件
extern NSString *PLVVFloatingWindowLeaveNotification;
// 退出播放页面广播事件
extern NSString *PLVVFloatingPlayerVCLeaveNotification;

/// 悬浮窗 PLVVFloatingWindow 的根控制器
/// 持有悬浮窗的控制按钮视图（也称悬浮窗皮肤）、视频播放器、播放器皮肤
/// 控制悬浮窗的显示与隐藏
@interface PLVVFloatingWindowViewController : UIViewController

/// 悬浮窗正在播放视频 vid，悬浮窗没有播放视频时为 nil，默认值为 nil
@property (nonatomic, strong, readonly) NSString * _Nullable vid;

/// 悬浮窗持有的视频播放器，悬浮窗没有播放视频时为 nil，默认值为 nil
@property (nonatomic, strong, readonly) PLVVodSkinPlayerController * _Nullable player;

/// 将页面上的播放器放置到悬浮窗上继续播放
/// vctrl 为持有大播放器的页面，当退出当前播放页面进行悬浮窗播放时 vctrl 为 nil
- (void)addPlayer:(PLVVodSkinPlayerController *)player partnerViewController:(id<PLVVFloatingWindowProtocol> _Nullable)vctrl;

/// 销毁并移除悬浮窗口持有的播放器
- (void)destroyPlayer;

/// 将悬浮窗上的播放器移走，但是不销毁
/// 播放从悬浮窗转移到大播放器时调用
- (void)removePlayer;

@end

NS_ASSUME_NONNULL_END
