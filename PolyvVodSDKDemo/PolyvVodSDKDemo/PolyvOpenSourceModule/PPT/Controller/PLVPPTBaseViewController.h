//
//  PLVPPTBaseViewController.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/7/26.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodConstans.h>

NS_ASSUME_NONNULL_BEGIN

// 点播播放模式
typedef NS_ENUM(NSInteger, PLVVodPlayMode) {
    PLVVodPlayModeNormal = 0,// 默认，普通模式
    PLVVodPlayModePPT // 三分屏模式
};

@interface PLVPPTBaseViewController : UIViewController

@property (nonatomic, copy) NSString *vid;

/**
  是否离线播放，默认为 NO
 YES: 从本地获取视频资源，没有网络时只要本地有缓存就可以播放
 NO: 调用接口获取视频资源，没有网络时即使本地有缓存也无法播放
 */
@property (nonatomic, assign) BOOL isOffline;

// 播放模式：默认、视频、音频三种
// 在线播放时会自动设置播放模式
// 离线时根据本地资源类型手动设置播放模式
@property (nonatomic, assign) PLVVodPlaybackMode playbackMode;

// 获取课件异常时，会执行这个方法，子类需要时可覆写
- (void)getPPTFail;

// ppt 的值更新时，获得 ppt 模型，或者置 nil 会执行这个方法，子类需要时可覆写
- (void)getPPTSuccess;

// 横竖屏切换时会执行这个方法，子类需要时可覆写
- (void)interfaceOrientationDidChange;

@end

NS_ASSUME_NONNULL_END
