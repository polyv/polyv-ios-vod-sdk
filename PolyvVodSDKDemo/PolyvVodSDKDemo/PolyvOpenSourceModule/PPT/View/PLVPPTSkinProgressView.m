//
//  PLVPPTSkinProgressView.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/20.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVPPTSkinProgressView.h"
#import "UIColor+PLVVod.h"

static CGFloat kLineWidth = 4.0;
static NSUInteger kRingColor = 0x2196f4;
static NSUInteger kBackColor = 0x444444;

@interface PLVPPTSkinProgressView ()

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) CAShapeLayer *backLayer;
@property (nonatomic, strong) CAShapeLayer *ringLayer;
@property (nonatomic, assign) CGFloat ringRadius;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, assign) BOOL active;

@end

@implementation PLVPPTSkinProgressView

#pragma mark - Public

- (instancetype)initWithRadius:(CGFloat)radius {
    self = [[PLVPPTSkinProgressView alloc] initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)];
    self.backgroundColor = [UIColor clearColor];
    self.ringRadius = radius;
    
    return self;
}

- (void)changeRadius:(CGFloat)radius {
    if (radius == self.ringRadius) {
        return;
    }
    self.frame = CGRectMake(0, 0, radius * 2, radius * 2);
    self.ringRadius = radius;
    
    if (self.active == NO) {
        return;
    }
    
    [self removeAllSublayer];
    
    if (self.downloading) {
        [self updateProgress:self.progress];
    } else {
        [self startLoading];
    }
}

- (void)startLoading {
    self.active = YES;
    self.downloading = NO;
    
    [self addBackLayerToSuperLayer];
    [self addLoopLayerToSuperLayer];
}

- (void)stopLoading {
    self.active = NO;
    
    [self resetData];
    [self removeAllSublayer];
}

- (void)startDownloading {
    self.active = YES;
    self.downloading = YES;
    
    [self addBackLayerToSuperLayer];
    [self addRingLayerToSuperLayer];
    
    [self updateProgress:0];
}

- (void)updateProgress:(CGFloat)progrss {
    if (progrss < 0) {
        _progress = 0;
    } else if (progrss < 1) {
        _progress = progrss;
    } else {
        _progress = 1;
    }
    
    self.ringLayer.strokeEnd = progrss;
}

#pragma mark - Private

- (void)addBackLayerToSuperLayer {
    if (_backLayer.superlayer) {
        [_backLayer removeFromSuperlayer];
        _backLayer = nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.ringRadius, self.ringRadius) radius:self.ringRadius startAngle:-M_PI_2 endAngle:3*M_PI_2 clockwise:YES];
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    layer.lineWidth = kLineWidth;
    layer.strokeColor = [UIColor colorWithHex:kBackColor].CGColor;
    layer.path = path.CGPath;
    layer.bounds = (CGRect){0, 0, self.ringRadius * 2, self.ringRadius * 2};
    
    // 填充颜色，默认为black，nil为不填充
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.position = CGPointMake(self.ringRadius, self.ringRadius);
    layer.strokeEnd = 1;
    [self.layer addSublayer:layer];
    _backLayer = layer;
}

- (void)addRingLayerToSuperLayer {
    if (_ringLayer.superlayer) {
        [_ringLayer removeFromSuperlayer];
        _ringLayer = nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.ringRadius, self.ringRadius) radius:self.ringRadius startAngle:-M_PI_2 endAngle:3*M_PI_2 clockwise:YES];
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    layer.lineWidth = kLineWidth;
    layer.strokeColor = [UIColor colorWithHex:kRingColor].CGColor;
    layer.path = path.CGPath;
    layer.bounds = (CGRect){0, 0, self.ringRadius * 2, self.ringRadius * 2};
    
    // 填充颜色，默认为black，nil为不填充
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.position = CGPointMake(self.ringRadius, self.ringRadius);
    layer.strokeEnd = 0;
    [self.layer addSublayer:layer];
    _ringLayer = layer;
}

- (void)addLoopLayerToSuperLayer {
    if (_ringLayer.superlayer) {
        [_ringLayer removeFromSuperlayer];
        _ringLayer = nil;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.ringRadius, self.ringRadius) radius:self.ringRadius startAngle:-M_PI_2 endAngle:3*M_PI_2 clockwise:YES];
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    layer.lineWidth = 4.0;
    layer.strokeColor = [UIColor colorWithHex:kRingColor].CGColor;
    layer.path = path.CGPath;
    layer.bounds = (CGRect){0, 0, self.ringRadius * 2, self.ringRadius * 2};
    
    // 填充颜色，默认为black，nil为不填充
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.position = CGPointMake(self.ringRadius, self.ringRadius);
    layer.strokeEnd = 0.75;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue = [NSNumber numberWithDouble:-M_PI_2];
    animation.toValue = [NSNumber numberWithDouble:3 * M_PI_2];
    animation.duration = 1;
    // 线性匀速
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = NO;
    animation.repeatCount = INFINITY;
    // 保持动画的结束状态
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:@"animateTransform"];
    layer.frame = CGRectMake(0, 0, self.ringRadius * 2, self.ringRadius * 2);
    [self.layer addSublayer:layer];
    _ringLayer = layer;
}

- (void)resetData {
    self.downloading = NO;
    self.progress = 0;
}

- (void)removeAllSublayer {
    if (_ringLayer.superlayer) {
        [_ringLayer removeFromSuperlayer];
        _ringLayer = nil;
        
        [_backLayer removeFromSuperlayer];
        _backLayer = nil;
    }
}

@end
