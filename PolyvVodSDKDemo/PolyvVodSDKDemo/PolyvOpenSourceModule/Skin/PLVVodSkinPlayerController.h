//
//  PLVVodSkinPlayerController.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <PLVVodSDK/PLVVodPlayerViewController.h>

extern NSString *PLVVodPlaybackRecoveryNotification;

@class PLVVodExamViewController;

@interface PLVVodSkinPlayerController : PLVVodPlayerViewController

@property (nonatomic, assign, readonly) BOOL isLockScreen;
@property (nonatomic, copy) NSString *vid;
// 播放进度回调
@property (nonatomic, copy) void (^playbackTimeHandler)(NSTimeInterval currentPlaybackTime);

// 问答控制器
@property (nonatomic, strong, readonly) PLVVodExamViewController *examViewController;

@end
