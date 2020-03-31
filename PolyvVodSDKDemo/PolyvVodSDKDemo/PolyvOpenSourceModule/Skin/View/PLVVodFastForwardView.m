//
//  PLVVodFastForwardView.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/3/9.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import "PLVVodFastForwardView.h"

@interface PLVVodFastForwardView ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSArray *animationImagesArray;

@end

@implementation PLVVodFastForwardView

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _rate = 2.0;
        [self initUI];
    }
    return self;
}

- (void)layoutSubviews {
    float boundsW = self.bounds.size.width;
    float boundsH = self.bounds.size.height;
    
    self.bgView.frame = CGRectMake((boundsW - 140) / 2.0, boundsH * 0.064, 140, 40);
    self.imageView.frame = CGRectMake(24, 0, 40, 40);
    self.label.frame = CGRectMake(70, 0, 70, 40);
}

#pragma mark - Initialize

- (void)initUI {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.imageView];
    [self.bgView addSubview:self.label];
}

#pragma mark - Getter & Setter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _bgView.layer.cornerRadius = 20.0;
    }
    return _bgView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.animationImages = self.animationImagesArray;
        _imageView.animationDuration = 0.6;
    }
    return _imageView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:14];
        _label.text = [NSString stringWithFormat:@"快进x%.1f", self.rate];
    }
    return _label;
}

- (void)setRate:(double)rate {
    _rate = rate;
    self.label.text = [NSString stringWithFormat:@"快进x%.1f", rate];
}

- (NSArray *)animationImagesArray {
    if (!_animationImagesArray) {
        NSMutableArray<UIImage *> *imageArr = [NSMutableArray array];
        for (int i = 0; i < 5; i++) {
            NSString *imageName = [NSString stringWithFormat:@"plv_vod_icon_fastforward_%02d", i];
            UIImage *image = [UIImage imageNamed:imageName];
            [imageArr addObject:image];
        }
        _animationImagesArray = [imageArr mutableCopy];
    }
    return _animationImagesArray;
}

#pragma mark - Public

- (void)show {
    self.alpha = 1;
    self.hidden = NO;
    self.isShow = YES;
    [self.imageView startAnimating];
}

- (void)hide {
    self.alpha = 0;
    self.hidden = YES;
    self.isShow = NO;
    [self.imageView stopAnimating];
}

- (void)setLoading:(BOOL)load {
    NSString *text = load ? @"Loading" : [NSString stringWithFormat:@"快进x%.1f", self.rate];
    self.label.text = text;
}

#pragma mark - Private
@end
