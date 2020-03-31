//
//  PLVVFloatingPlayerViewController.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/2/25.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVVodSkinPlayerController;

NS_ASSUME_NONNULL_BEGIN

/// 视频悬浮小窗播放 Demo 页
/// 初始化时需判断当前悬浮窗是否正在播放同一个视频
/// 如果是：使用 '-initWithPlayer:'
/// 如果否：使用 '-initWithVid:'
@interface PLVVFloatingPlayerViewController : UIViewController

/// 初始化方法 1：会创建一个新的播放器
- (instancetype)initWithVid:(NSString *)vid;

/// 初始化方法 2：悬浮窗已有播放器并且正在播放同一个 vid 的视频，这时候会使用悬浮窗的播放器进行初始化，并继续播放悬浮窗的视频
- (instancetype)initWithPlayer:(PLVVodSkinPlayerController *)player;

@end

NS_ASSUME_NONNULL_END
