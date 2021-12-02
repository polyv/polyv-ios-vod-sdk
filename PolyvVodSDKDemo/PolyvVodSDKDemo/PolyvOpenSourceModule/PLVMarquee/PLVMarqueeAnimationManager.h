//
//  PLVMarqueeAnimation.h
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/3/3.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PLVMarqueeModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 负责给跑马灯提供动画
@interface PLVMarqueeAnimationManager : NSObject

/// 给layer添加动画
/// @param layer 要添加动画的layer
/// @param bounds 随机位置的范围
/// @param model 描述动画细节的model
/// @param delegate 动画代理
+(void)addAnimationForLayer:(CALayer *)layer
       randomOriginInBounds:(CGRect)bounds
                  withModel:(PLVMarqueeModel *)model
          animationDelegate:(id)delegate;

/// 给闪烁双跑马灯中第二个跑马灯添加动画
/// @param layer 要添加动画的layer
/// @param bounds 随机位置的范围
/// @param model 描述动画细节的model
/// @param delegate 动画代理
+ (void)addDoubleFlashAnimationForSecondLayer:(CALayer *)layer
                         randomOriginInBounds:(CGRect)bounds
                                    withModel:(PLVMarqueeModel *)model
                            animationDelegate:(id)delegate;


#pragma mark - 检查layer是否包含跑马灯动画
/// 检查layer是否包含跑马灯动画
/// @param layer layer
+(BOOL)checkLayerHaveMarqueeAnimation:(CALayer *)layer;

#pragma mark - 开启跑马灯动画
/// 开启跑马灯动画
/// @param layer 要开启动画的layer
+(void)startMarqueeAnimation:(CALayer *)layer;

#pragma mark - 暂停跑马灯动画
/// 暂停跑马灯动画
/// @param layer 要暂停动画的layer
+(void)pauseMarqueeAnimation:(CALayer *)layer;

@end

NS_ASSUME_NONNULL_END
