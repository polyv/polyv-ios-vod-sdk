//
//  PLVVodRouteLineView.h
//  _PolyvVodSDK
//
//  Created by mac on 2019/2/13.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodRouteLineView : UIView

// 线路数量
@property (nonatomic, assign) NSUInteger routeLineCount;

// 线路选择回调
@property (nonatomic, copy) void (^routeLineDidChangeBlock)(NSUInteger routeIndex);
@property (nonatomic, copy) void (^routeLineBtnDidClick)(UIButton *sender);

@end

NS_ASSUME_NONNULL_END
