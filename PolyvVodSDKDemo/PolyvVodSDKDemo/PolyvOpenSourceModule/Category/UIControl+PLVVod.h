//
//  UIControl+PLVVod.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2018/3/2.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (PLVVod)

/// 时间接收间隔
@property (nonatomic, assign) NSTimeInterval acceptEventInterval;

/// 是否忽略事件
@property (nonatomic, assign) BOOL ignoreEvent;

@end
