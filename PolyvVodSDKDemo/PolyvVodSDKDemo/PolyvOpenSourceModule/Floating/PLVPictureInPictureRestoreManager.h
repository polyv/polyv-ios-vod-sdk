//
//  PLVPictureInPictureRestoreManager.h
//  PolyvVodSDKDemo
//
//  Created by junotang on 2022/4/8.
//  Copyright © 2022 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVPictureInPictureManager.h>

NS_ASSUME_NONNULL_BEGIN

/// 画中画恢复功能管理
@interface PLVPictureInPictureRestoreManager : NSObject<PLVPictureInPictureRestoreDelegate>

#pragma mark - [ 属性 ]

/// 用于开启画中画后离开页面时，持有原来的页面
@property (nonatomic, strong, nullable) UIViewController *holdingViewController;

#pragma mark - [ 方法 ]

/// 单例方法
+ (instancetype)sharedInstance;

/// 清空恢复管理器的内部属性，在画中画关闭的时候调用，防止内存泄漏
- (void)cleanRestoreManager;


@end

NS_ASSUME_NONNULL_END
