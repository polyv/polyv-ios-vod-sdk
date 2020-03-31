//
//  PLVVFloatingWindowSkin.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/2/27.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 悬浮窗播放器控制按钮层响应事件回调
@protocol PLVVFloatingWindowSkinProtocol <NSObject>

- (void)tapCloseButton;

- (void)tapExchangeButton;

- (void)tapPlayButton:(BOOL)play;

@end

/// 悬浮窗的控制按钮视图，也称悬浮窗皮肤
@interface PLVVFloatingWindowSkin : UIView

@property (nonatomic, weak) id<PLVVFloatingWindowSkinProtocol> delegate;

/// 根据播放器的播放状态更新悬浮窗皮肤
- (void)statusIsPlaying:(BOOL)playing;

@end

NS_ASSUME_NONNULL_END
