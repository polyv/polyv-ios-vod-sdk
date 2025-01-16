//
//  PLVVodHeatMapView.m
//  PolyvVodSDKDemo
//
//  Created by polyv on 2024/12/31.
//  Copyright © 2024 POLYV. All rights reserved.
//

#import "PLVVodHeatMapView.h"
#import "PLVVodHeatMapContentView.h"

@interface PLVVodHeatMapView ()

@property (nonatomic, strong) CAGradientLayer *backMaskLayer;
@property (nonatomic, strong) PLVVodHeatMapContentView *contentView;

@end

@implementation PLVVodHeatMapView

- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = [UIColor clearColor];
        
        //
        [self.layer addSublayer:self.backMaskLayer];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.backMaskLayer.frame = self.bounds;
    self.contentView.frame = CGRectMake(0, self.bounds.size.height/2, self.bounds.size.width, self.bounds.size.height/2);
}

#pragma mark --getter

- (CAGradientLayer *)backMaskLayer{
    if (!_backMaskLayer){
        _backMaskLayer = [CAGradientLayer layer];
        _backMaskLayer.colors = @[(__bridge  id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor,
                                  (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0].CGColor];
        // 底部向上渐变
        _backMaskLayer.startPoint = CGPointMake(0.5, 1.0);
        _backMaskLayer.endPoint = CGPointMake(0.5, 0.0);
        _backMaskLayer.locations = @[@0.0, @1.0];
    }
    return _backMaskLayer;
}

- (PLVVodHeatMapContentView *)contentView{
    if (!_contentView){
        _contentView = [[PLVVodHeatMapContentView alloc] init];
    }
    
    return _contentView;
}

#pragma mark -- public
- (void)updateWithData:(PLVVodHeatMapModel *)data{
    [self.contentView updateWithData:data];
}


@end
