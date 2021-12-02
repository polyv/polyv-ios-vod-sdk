//
//  PLVMarqueeView.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/3/3.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVMarqueeView.h"
#import "PLVMarqueeAnimationManager.h"

@interface PLVMarqueeView ()<CAAnimationDelegate>

@property (nonatomic, strong) PLVMarqueeModel *marqueeModel;
@property (nonatomic, strong) CALayer *mainMarqueeLayer;
@property (nonatomic, strong) CALayer *secondMarqueeLayer;

@property (nonatomic, assign) BOOL isRunning;   //!< 是否正在运行跑马灯

@end


@implementation PLVMarqueeView

#pragma mark - Init & Dealloc

-(instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.layer.masksToBounds = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Setter

-(void)setPLVMarqueeModel:(PLVMarqueeModel *)marqueeModel
{
    if (!marqueeModel) {
        [self removeMarquee];
        return;
    }
    
    NSAttributedString *attributedString = [marqueeModel createMarqueeAttributedContent];
    CGSize marqueeSize = [marqueeModel marqueeAttributedContentSize];
    CGRect layerFrame = CGRectMake(-marqueeSize.width, 0, marqueeSize.width, marqueeSize.height);
    
    if (attributedString) {
        self.marqueeModel = marqueeModel;
        [self removeMarquee];
        
        CATextLayer *mainLayer = [CATextLayer layer];
        mainLayer.string = attributedString;
        mainLayer.opacity = marqueeModel.alpha;
        mainLayer.contentsScale = [UIScreen mainScreen].scale;
        mainLayer.frame = layerFrame;
        self.mainMarqueeLayer = mainLayer;
        [self.layer addSublayer:self.mainMarqueeLayer];
        
        //双跑马灯，开启第二个跑马灯layer
        if (marqueeModel.style == PLVMarqueeModelStyleDoubleRoll
            || marqueeModel.style == PLVMarqueeModelStyleDoubleFlash) {

            CATextLayer *secondLayer = [CATextLayer layer];
            secondLayer.string = attributedString;
            secondLayer.opacity = marqueeModel.secondMarqueeAlpha;
            secondLayer.contentsScale = [UIScreen mainScreen].scale;
            secondLayer.frame = layerFrame;
            self.secondMarqueeLayer = secondLayer;
            [self.layer addSublayer:self.secondMarqueeLayer];
        }
    }
}



#pragma mark - Action

/// 启动跑马灯
-(void)start
{
    if (!self.marqueeModel) {
        [self removeMarquee];
        return;
    }
    
    if (self.mainMarqueeLayer) {
        self.isRunning = YES;
        self.mainMarqueeLayer.hidden = NO;
        if ([PLVMarqueeAnimationManager checkLayerHaveMarqueeAnimation:self.mainMarqueeLayer]) {
            //当前已经添加动画,启动动画
            [PLVMarqueeAnimationManager startMarqueeAnimation:self.mainMarqueeLayer];
        }else {
            //没有添加动画，则添加
            [PLVMarqueeAnimationManager addAnimationForLayer:self.mainMarqueeLayer randomOriginInBounds:self.bounds withModel:self.marqueeModel animationDelegate:self];
            return;
        }
    }
    
    if (self.secondMarqueeLayer) {
        self.secondMarqueeLayer.hidden = NO;
        if ([PLVMarqueeAnimationManager checkLayerHaveMarqueeAnimation:self.secondMarqueeLayer]) {
            //当前已经添加动画,启动动画
            [PLVMarqueeAnimationManager startMarqueeAnimation:self.secondMarqueeLayer];
        }else {
            //没有添加动画，则添加
            [PLVMarqueeAnimationManager addDoubleFlashAnimationForSecondLayer:self.secondMarqueeLayer randomOriginInBounds:self.bounds withModel:self.marqueeModel animationDelegate:self];
        }
    }
}

/// 暂停
-(void)pause
{
    if (!self.marqueeModel) {
        [self removeMarquee];
        return;
    }
    
    if (self.mainMarqueeLayer) {
        self.isRunning = NO;
        self.mainMarqueeLayer.hidden = self.marqueeModel.isHiddenWhenPause;
        if ([PLVMarqueeAnimationManager checkLayerHaveMarqueeAnimation:self.mainMarqueeLayer]) {
            //当前已经添加动画，暂停动画
            [PLVMarqueeAnimationManager pauseMarqueeAnimation:self.mainMarqueeLayer];
        }
    }
    
    if (self.secondMarqueeLayer) {
        self.secondMarqueeLayer.hidden = self.marqueeModel.isHiddenWhenPause;
        if ([PLVMarqueeAnimationManager checkLayerHaveMarqueeAnimation:self.secondMarqueeLayer]) {
            //当前已经添加动画，暂停动画
            [PLVMarqueeAnimationManager pauseMarqueeAnimation:self.secondMarqueeLayer];
        }
    }
    
}

/// 停止跑马灯
-(void)stop
{
    if (!self.marqueeModel) {
        [self removeMarquee];
        return;
    }
    
    if (self.mainMarqueeLayer) {
        self.isRunning = NO;
        [self.mainMarqueeLayer removeAllAnimations];
    }
    
    if (self.secondMarqueeLayer) {
        [self.secondMarqueeLayer removeAllAnimations];
    }
    
}

/// 移除跑马灯
-(void)removeMarquee
{
    if (self.mainMarqueeLayer) {
        [self.mainMarqueeLayer removeAllAnimations];
        [self.mainMarqueeLayer removeFromSuperlayer];
        self.mainMarqueeLayer = nil;
    }
    
    if (self.secondMarqueeLayer) {
        [self.secondMarqueeLayer removeAllAnimations];
        [self.secondMarqueeLayer removeFromSuperlayer];
        self.secondMarqueeLayer = nil;
    }
}


#pragma mark - CAAnimationDelegate

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // This flag is NO when the application enters background.
    if (flag && self.isRunning) {
        [self start];
    }
}


#pragma mark - Notifications

- (void)applicationDidBecomeActive {
    if (self.isRunning) {
        [self start];
    }
}

@end
