//
//  PLVVodSkinPlayerController.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <PLVVodSDK/PLVVodPlayerViewController.h>
#import "PLVKnowledgeListViewController.h"
#import "PLVKnowledgeModel.h"
#import "PLVMarqueeView.h"

extern NSString *PLVVodPlaybackRecoveryNotification;
extern NSString *PLVVodADAndTeasersPlayFinishNotification;

@class PLVVodExamViewController;

@interface PLVVodSkinPlayerController : PLVVodPlayerViewController

@property (nonatomic, assign, readonly) BOOL isLockScreen;
@property (nonatomic, copy) NSString *vid;
// 播放进度回调
@property (nonatomic, copy) void (^playbackTimeHandler)(NSTimeInterval currentPlaybackTime);

// 问答控制器
@property (nonatomic, strong, readonly) PLVVodExamViewController *examViewController;

/// 知识清单控制器
@property (nonatomic, strong, readonly) PLVKnowledgeListViewController *knowledgeListViewController;

/// 知识清单model, 设置此mode即为开启知识清单功能，请在调用方法 ‘-addPlayerOnPlaceholderView:rootViewController:’ 之后设置
@property (nonatomic, strong) PLVKnowledgeModel *knowledgeModel;
/// 跑马灯2.0 View
@property (nonatomic, strong) PLVMarqueeView *marqueeView;

// 是否屏蔽长按倍速快进手势，默认为 NO
@property (nonatomic, assign) BOOL disableLongPressGesture;

// 长按快进时的倍速，默认为 2.0
@property (nonatomic, assign) double longPressPlaybackRate;

/// 是否限制拖拽进度功能，默认为 NO，可随意拖拽进度
@property (nonatomic, assign) BOOL restrictedDragging;

/// 在属性 restrictedDragging 为 YES 的基础上，是否允许对已播放的进度进行拖拽，
/// YES：全部进度不允许拖拽；NO：允许对已播放的进度进行拖拽，默认为 NO
@property (nonatomic, assign) BOOL allForbidDragging;

/// 是否启动悬浮窗功能，默认为 NO，若需打开，请在调用方法 ‘-addPlayerOnPlaceholderView:rootViewController:’ 之前设置
@property (nonatomic, assign) BOOL enableFloating;

/// 当前视频在当前设备播放达到的最长进度，用于属性 partlyDragging 对用户未观看部分进行限制拖拽
@property (nonatomic, assign) NSTimeInterval maxPosition;


/// 设备旋转的时候是否不影响全/半屏状态，默认NO，若需打开，请在调用方法 ‘-addPlayerOnPlaceholderView:rootViewController:’ 之前设置
@property (nonatomic, assign) BOOL deviceOrientationChangedNotSwitchFullscreen;


- (void)playInFullscreen:(BOOL)full;

@end
