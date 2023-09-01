//
//  PLVMarqueeAnimation.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/3/3.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVMarqueeAnimationManager.h"

static NSString * const PLVMarqueeAnimationKey = @"PLVMarqueeAnimationKey";

@implementation PLVMarqueeAnimationManager

#pragma mark - Public

/// 给layer添加动画
/// @param layer 要添加动画的layer
/// @param bounds 随机位置的范围
/// @param model 描述动画细节的model
/// @param delegate 动画代理
+(void)addAnimationForLayer:(CALayer *)layer
       randomOriginInBounds:(CGRect)bounds
                  withModel:(PLVMarqueeModel *)model
          animationDelegate:(id)delegate
{
    switch (model.style) {
        case PLVMarqueeModelStyleRoll:
        {
            [PLVMarqueeAnimationManager addRollAnimation:layer randomOriginInBounds:bounds withModel:model animationDelegate:delegate];
            break;
        }
        case PLVMarqueeModelStyleFlash:
        {
            [PLVMarqueeAnimationManager addFlashAnimation:layer randomOriginInBounds:bounds withModel:model animationDelegate:delegate isSecondLayer:NO];
            break;
        }
        case PLVMarqueeModelStyleRollFade:
        {
            [PLVMarqueeAnimationManager addRollFadeAnimation:layer randomOriginInBounds:bounds withModel:model animationDelegate:delegate];
            break;
        }
        case PLVMarqueeModelStylePartRoll:
        {
            [PLVMarqueeAnimationManager addPartRollAnimation:layer randomOriginInBounds:bounds withModel:model animationDelegate:delegate];
            break;
        }
        case PLVMarqueeModelStylePartFlash:
        {
            [PLVMarqueeAnimationManager addPartFlashAnimation:layer randomOriginInBounds:bounds withModel:model animationDelegate:delegate];
            break;
        }
        case PLVMarqueeModelStyleDoubleRoll:
        {
            [PLVMarqueeAnimationManager addRollAnimation:layer randomOriginInBounds:bounds withModel:model animationDelegate:delegate];
            break;
        }
        case PLVMarqueeModelStyleDoubleFlash:
        {
            [PLVMarqueeAnimationManager addFlashAnimation:layer randomOriginInBounds:bounds withModel:model animationDelegate:delegate isSecondLayer:NO];
            break;
        }
        default:
            break;
    }
}

/// 给闪烁双跑马灯中第二个跑马灯添加动画
/// @param layer 要添加动画的layer
/// @param bounds 随机位置的范围
/// @param model 描述动画细节的model
/// @param delegate 动画代理
+ (void)addDoubleFlashAnimationForSecondLayer:(CALayer *)layer
                         randomOriginInBounds:(CGRect)bounds
                                    withModel:(PLVMarqueeModel *)model
                            animationDelegate:(id)delegate {
    [PLVMarqueeAnimationManager addFlashAnimation:layer randomOriginInBounds:bounds withModel:model animationDelegate:delegate isSecondLayer:YES];
}

#pragma mark - 检查layer是否包含跑马灯动画
/// 检查layer是否包含跑马灯动画
/// @param layer layer
+(BOOL)checkLayerHaveMarqueeAnimation:(CALayer *)layer
{
    if ([layer animationForKey:PLVMarqueeAnimationKey]) {
        return YES;
    }
    return NO;
}

#pragma mark - 开启跑马灯动画
/// 开启跑马灯动画
/// @param layer 要开启动画的layer
+(void)startMarqueeAnimation:(CALayer *)layer
{
    if (layer.speed) {
        //动画正在执行，不作处理
    }else {
        //动画为暂停状态，让动画执行
        layer.speed = 1;
        CFTimeInterval pauseTime = layer.timeOffset;
        layer.timeOffset = 0;
        layer.beginTime = 0;
        layer.beginTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
    }
}

#pragma mark - 暂停跑马灯动画
/// 暂停跑马灯动画
/// @param layer 要暂停动画的layer
+(void)pauseMarqueeAnimation:(CALayer *)layer
{
    if (layer.speed) {
        //动画正在执行，暂停动画
        layer.timeOffset = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0;
    }
}


#pragma mark - Privates

#pragma mark - 闪烁
/// 给layer添加随机位置闪烁的动画
/// @param layer 要添加动画的layer
/// @param bounds 随机位置的范围
/// @param model 描述闪烁细节的model
/// @param delegate 动画代理
+(void)addFlashAnimation:(CALayer *)layer
    randomOriginInBounds:(CGRect)bounds
               withModel:(PLVMarqueeModel *)model
       animationDelegate:(id)delegate
           isSecondLayer:(BOOL)isSecondLayer {
    //获取随机位置
    CGFloat displayWidth = CGRectGetWidth(bounds);
    CGFloat displayHeight = CGRectGetHeight(bounds);
    CGFloat displayMaxX = displayWidth - layer.frame.size.width;
    CGFloat displayMaxY = displayHeight - layer.frame.size.height;
    CGFloat randomX = displayMaxX < 0.0 ? 0.0 : [PLVMarqueeAnimationManager randomDoubleFrom:0.0 to:displayMaxX accuracy:2];
    CGFloat randomY = displayMaxY < 0.0 ? 0.0 : [PLVMarqueeAnimationManager randomDoubleFrom:20.0 to:displayMaxY accuracy:2];
    
    //给layer设置随机位置
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    layer.frame = CGRectMake(randomX, randomY, layer.frame.size.width, layer.frame.size.height);
    [CATransaction commit];
    
    //给layer添加闪烁动画
    CAKeyframeAnimation *opacityAnimation;
    if (isSecondLayer) {
        opacityAnimation = [PLVMarqueeAnimationManager createFlashAnimationForSecondMarqueeWithModel:model];
    }else {
        opacityAnimation = [PLVMarqueeAnimationManager createFlashAnimationWithModel:model];
    }
    if (opacityAnimation) {
        layer.opacity = 0;
        opacityAnimation.delegate = delegate;
        [layer addAnimation:opacityAnimation forKey:PLVMarqueeAnimationKey];
    }
}

#pragma mark - 滚动
/// 给layer添加随机Y坐标的滚动动画
/// @param layer 要添加动画的layer
/// @param bounds 随机位置的范围
/// @param model 描述滚动细节的model
/// @param delegate 动画代理
+(void)addRollAnimation:(CALayer *)layer
   randomOriginInBounds:(CGRect)bounds
              withModel:(PLVMarqueeModel *)model
   animationDelegate:(id)delegate
{
    //获取随机坐标
    CGFloat displayWidth = CGRectGetWidth(bounds);
    CGFloat displayHeight = CGRectGetHeight(bounds);
    CGFloat displayMinY = 20.0;
    CGFloat displayMaxY = displayHeight - layer.frame.size.height * 0.5;
    CGFloat randomY = [PLVMarqueeAnimationManager randomDoubleFrom:displayMinY to:displayMaxY accuracy:2];
    if (displayHeight < layer.frame.size.height) {
        randomY = 0.0;
    }
    CGFloat rollFromPsitionX = displayWidth + layer.frame.size.width * 0.5;
    CGFloat rollToPsitionX = -layer.frame.size.width * 0.5;
    if (model.isAlwaysShowWhenRun) {
        rollFromPsitionX = displayWidth - layer.frame.size.width * 0.5;
        rollToPsitionX = layer.frame.size.width * 0.5;
    }
    
    //给layer添加滚动动画
    CGPoint startPoint = CGPointMake(rollFromPsitionX, randomY);
    CGPoint endPoint = CGPointMake(rollToPsitionX, randomY);
    
    CAKeyframeAnimation *positionAnimation = [PLVMarqueeAnimationManager createRollAnimationWithModel:model startPoint:startPoint endPoint:endPoint];
    if (positionAnimation) {
        positionAnimation.delegate = delegate;
        [layer addAnimation:positionAnimation forKey:PLVMarqueeAnimationKey];
    }
}

#pragma mark - 闪烁 + 滚动
/// 给layer添加滚动 + 闪烁动画
/// @param layer 要添加动画的layer
/// @param bounds 随机位置的范围
/// @param model 描述滚动细节的model
/// @param delegate 动画代理
+(void)addRollFadeAnimation:(CALayer *)layer
       randomOriginInBounds:(CGRect)bounds
                  withModel:(PLVMarqueeModel *)model
       animationDelegate:(id)delegate
{
    [PLVMarqueeAnimationManager addRollAnimation:layer randomOriginInBounds:bounds withModel:model animationDelegate:delegate];
    
    NSUInteger interval = model.isAlwaysShowWhenRun ? 0 : model.interval;
    NSTimeInterval duration = model.tweenTime * 2 + model.lifeTime + interval;
    if (duration <= 0) {
        return;
    }
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@0
                                ,@(model.alpha)
                                ,@(model.alpha)
                                ,@0
                                ,@0];
    opacityAnimation.keyTimes = @[@0
                                  ,@(model.tweenTime / duration)
                                  ,@((model.tweenTime + model.lifeTime) / duration)
                                  ,@((model.tweenTime * 2 + model.lifeTime) / duration)
                                  ,@1];
    opacityAnimation.duration = duration;
    opacityAnimation.repeatCount = MAXFLOAT;
    [layer addAnimation:opacityAnimation forKey:@"fade"];
}

#pragma mark - 局部滚动
/// 给layer添加局部滚动动画
/// @param layer 要添加动画的layer
/// @param bounds 随机位置的范围
/// @param model 描述滚动细节的model
/// @param delegate 动画代理
+(void)addPartRollAnimation:(CALayer *)layer
       randomOriginInBounds:(CGRect)bounds
                  withModel:(PLVMarqueeModel *)model
       animationDelegate:(id)delegate
{
    //获取随机坐标
    CGFloat displayWidth = CGRectGetWidth(bounds);
    CGFloat displayHeight = CGRectGetHeight(bounds);
    CGFloat displayMinY = layer.frame.size.height * 0.5;
    CGFloat displayMaxY = displayHeight - layer.frame.size.height * 0.5;
    CGFloat randomY = [PLVMarqueeAnimationManager randomDoubleFrom:displayMinY to:displayHeight * 0.15 accuracy:2];
    if (arc4random()%2) {
        randomY = [PLVMarqueeAnimationManager randomDoubleFrom:displayHeight * 0.85 to:displayMaxY accuracy:2];
    }
    
    CGFloat rollFromPsitionX = displayWidth + layer.frame.size.width * 0.5;
    CGFloat rollToPsitionX = -layer.frame.size.width * 0.5;
    if (model.isAlwaysShowWhenRun) {
        rollFromPsitionX = displayWidth - layer.frame.size.width * 0.5;
        rollToPsitionX = layer.frame.size.width * 0.5;
    }
    
    //给layer添加滚动动画
    CGPoint startPoint = CGPointMake(rollFromPsitionX, randomY);
    CGPoint endPoint = CGPointMake(rollToPsitionX, randomY);
    
    CAKeyframeAnimation *positionAnimation = [PLVMarqueeAnimationManager createRollAnimationWithModel:model startPoint:startPoint endPoint:endPoint];
    if (positionAnimation) {
        positionAnimation.delegate = delegate;
        [layer addAnimation:positionAnimation forKey:PLVMarqueeAnimationKey];
    }
}

#pragma mark - 局部闪烁
/// 给layer添加局部闪烁动画
/// @param layer 要添加动画的layer
/// @param bounds 随机位置的范围
/// @param model 描述闪烁细节的model
/// @param delegate 动画代理
+(void)addPartFlashAnimation:(CALayer *)layer
        randomOriginInBounds:(CGRect)bounds
                   withModel:(PLVMarqueeModel *)model
        animationDelegate:(id)delegate
{
    //获取随机位置
    CGFloat displayWidth = CGRectGetWidth(bounds);
    CGFloat displayHeight = CGRectGetHeight(bounds);
    CGFloat displayMaxX = displayWidth - layer.frame.size.width;
    CGFloat displayMaxY = displayHeight - layer.frame.size.height;
    CGFloat randomX = [PLVMarqueeAnimationManager randomDoubleFrom:0.0 to:displayMaxX accuracy:2];
    CGFloat randomY = [PLVMarqueeAnimationManager randomDoubleFrom:0.0 to:displayHeight * 0.15 accuracy:2];
    if (arc4random()%2) {
        randomY = [PLVMarqueeAnimationManager randomDoubleFrom:displayHeight * 0.85 to:displayMaxY accuracy:2];
    }
    
    //给layer设置随机位置
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    layer.frame = CGRectMake(randomX, randomY, layer.frame.size.width, layer.frame.size.height);
    [CATransaction commit];
    
    //给layer添加闪烁动画
    CAKeyframeAnimation *opacityAnimation = [PLVMarqueeAnimationManager createFlashAnimationWithModel:model];
    if (opacityAnimation) {
        layer.opacity = 0;
        opacityAnimation.delegate = delegate;
        [layer addAnimation:opacityAnimation forKey:PLVMarqueeAnimationKey];
    }
}


#pragma mark - Tool

/// 按照model参数生成闪烁动画
/// @param model model
+(CAKeyframeAnimation *)createFlashAnimationWithModel:(PLVMarqueeModel *)model
{
    NSUInteger interval = model.isAlwaysShowWhenRun ? 0 : model.interval;
    NSTimeInterval duration = model.tweenTime * 2 + model.lifeTime + interval;
    if (duration <= 0) {
        return nil;
    }
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@0
                                ,@(model.alpha)
                                ,@(model.alpha)
                                ,@0
                                ,@0];
    opacityAnimation.keyTimes = @[@0
                                  ,@(model.tweenTime / duration)
                                  ,@((model.tweenTime + model.lifeTime) / duration)
                                  ,@((model.tweenTime * 2 + model.lifeTime) / duration)
                                  ,@1];
    opacityAnimation.duration = duration;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = YES;
    
    return opacityAnimation;
}

/// 为双跑马灯中第二个跑马灯按照model参数生成闪烁动画
/// @param model model
+ (CAKeyframeAnimation *)createFlashAnimationForSecondMarqueeWithModel:(PLVMarqueeModel *)model {
    NSUInteger interval = model.isAlwaysShowWhenRun ? 0 : model.interval;
    NSTimeInterval duration = model.tweenTime * 2 + model.lifeTime + interval;
    if (duration <= 0) {
        return nil;
    }
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@0
                                ,@(model.secondMarqueeAlpha)
                                ,@(model.secondMarqueeAlpha)
                                ,@0
                                ,@0];
    opacityAnimation.keyTimes = @[@0
                                  ,@(model.tweenTime / duration)
                                  ,@((model.tweenTime + model.lifeTime) / duration)
                                  ,@((model.tweenTime * 2 + model.lifeTime) / duration)
                                  ,@1];
    opacityAnimation.duration = duration;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = YES;
    
    return opacityAnimation;
}

/// 生成滚动动画
/// @param model model
/// @param startPoint 起点
/// @param endPoint 终点
+(CAKeyframeAnimation *)createRollAnimationWithModel:(PLVMarqueeModel *)model startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    NSUInteger interval = model.isAlwaysShowWhenRun ? 0 : model.interval;
    NSTimeInterval duration = model.speed + interval;
    if (duration <= 0) {
        return nil;
    }

    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    NSValue *value1 = [NSValue valueWithCGPoint:startPoint];
    NSValue *value2 = [NSValue valueWithCGPoint:endPoint];
    NSValue *value3 = [NSValue valueWithCGPoint:endPoint];
    positionAnimation.values = @[value1,
                                 value2,
                                 value3];
    positionAnimation.keyTimes = @[@0,
                                   @(model.speed / duration),
                                   @1];
    positionAnimation.duration = duration;
    positionAnimation.fillMode = kCAFillModeForwards;
    positionAnimation.removedOnCompletion = YES;
    
    return positionAnimation;
}

/// 获取随机数
/// @param fromValue 随机数范围起点
/// @param toValue 随机数范围终点
/// @param accuracy 精确位数
+(double)randomDoubleFrom:(double)fromValue to:(double)toValue accuracy:(NSInteger)accuracy
{
    accuracy = (NSInteger)pow(10, accuracy);
    fromValue = fromValue * accuracy;
    toValue = toValue * accuracy;
    double randomValue = 1.0 * (arc4random() % (NSInteger)(toValue - fromValue + 1) + fromValue) / accuracy;
    return randomValue;
}

@end
