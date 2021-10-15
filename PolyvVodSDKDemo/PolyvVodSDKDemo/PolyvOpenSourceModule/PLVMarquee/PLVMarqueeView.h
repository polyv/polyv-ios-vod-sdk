//
//  PLVMarqueeView.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/3/3.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVMarqueeModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 跑马灯，适用于防录屏功能使用
@interface PLVMarqueeView : UIView

/// 设置跑马灯样式(需要手动启动跑马灯动画)
/// @param marqueeModel model
-(void)setPLVMarqueeModel:(PLVMarqueeModel *)marqueeModel;

/// 启动跑马灯
-(void)start;

/// 暂停跑马灯
-(void)pause;

/// 停止跑马灯
-(void)stop;

@end

NS_ASSUME_NONNULL_END
