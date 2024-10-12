//
//  PLVSimpleDetailController.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2018/3/26.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodConstans.h>

@interface PLVSimpleDetailController : UIViewController

@property (nonatomic, copy) NSString *vid;
@property (nonatomic, assign) BOOL isOffline;
@property (nonatomic, assign) PLVVodPlaybackMode playMode;
/// 系统截屏保护 防止系统截屏
@property (nonatomic, assign) BOOL systemScreenShotProtect;

@end
