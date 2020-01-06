//
//  PLVVodPPTViewController.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/7/25.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PLVVodPPT;

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodPPTViewController : UIViewController

@property (nonatomic, strong) PLVVodPPT * _Nullable ppt;

/**
 将文档切换到特定播放时间点的特定页
 @param second 当前视频播放时间点，单位：秒
 */
- (void)playAtCurrentSecond:(NSInteger)second;

/**
 将文档切换到特定页
 @param index 文档的第 index 页
 */
- (void)playPPTAtIndex:(NSInteger)index;

@end

@interface PLVVodPPTViewController (PLVPPTSkin)

/**
 开始加载 ppt
 */
- (void)startLoading;

/**
 加载 ppt 失败
 */
- (void)loadPPTFail;

/**
 开始下载 ppt
 */
- (void)startDownloading;

/**
 下载 ppt 进度变化
 @param progress ppt 下载进度
 */
- (void)setDownloadProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
