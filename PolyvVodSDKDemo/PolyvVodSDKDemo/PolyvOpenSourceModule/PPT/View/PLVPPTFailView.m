//
//  PLVPPTFailView.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/6.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVPPTFailView.h"
#import <PLVMasonry/PLVMasonry.h>

@interface PLVPPTFailView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *lineOneLabel;
@property (nonatomic, strong) UILabel *lineTwoLabel;

@end

@implementation PLVPPTFailView

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *image = [UIImage imageNamed:@"plv_icon_attent"];
        self.iconImageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:self.iconImageView];
        [self.iconImageView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.size.plv_equalTo(CGSizeMake(64, 64));
            make.top.plv_equalTo(0);
            make.centerX.plv_equalTo(0);
        }];
        
        [self addSubview:self.lineOneLabel];
        [self.lineOneLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.left.and.right.plv_equalTo(0);
            make.top.plv_equalTo(self.iconImageView.plv_bottom).with.offset(25);
            make.height.plv_equalTo(19);
        }];
        
        [self addSubview:self.lineTwoLabel];
        [self.lineTwoLabel plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.left.and.right.plv_equalTo(0);
            make.top.plv_equalTo(self.iconImageView.plv_bottom).with.offset(50);
            make.height.plv_equalTo(15);
        }];
        
        [self addSubview:self.button];
        [self.button plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.size.plv_equalTo(CGSizeMake(152, 48));
            make.centerX.plv_equalTo(0);
            make.bottom.plv_equalTo(0);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter

- (UILabel *)lineOneLabel {
    if (!_lineOneLabel) {
        _lineOneLabel = [[UILabel alloc] init];
        _lineOneLabel.font = [UIFont systemFontOfSize:18];
        _lineOneLabel.textColor = [UIColor whiteColor];
        _lineOneLabel.textAlignment = NSTextAlignmentCenter;
        _lineOneLabel.text = @"课件获取异常";
    }
    return _lineOneLabel;
}

- (UILabel *)lineTwoLabel {
    if (!_lineTwoLabel) {
        _lineTwoLabel = [[UILabel alloc] init];
        _lineTwoLabel.font = [UIFont systemFontOfSize:14];
        _lineTwoLabel.textColor = [UIColor whiteColor];
        _lineTwoLabel.textAlignment = NSTextAlignmentCenter;
        _lineTwoLabel.text = @"请点击下方按钮重新获取";
    }
    return _lineTwoLabel;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"获取课件" forState:UIControlStateNormal];
        UIColor *blueColor = [UIColor colorWithRed:0x21/255.0 green:0x96/255.0 blue:0xf3/255.0 alpha:1.0];
        [_button setTitleColor:blueColor forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont systemFontOfSize:16];
        _button.layer.borderWidth = 0.5;
        _button.layer.borderColor = blueColor.CGColor;
        _button.layer.cornerRadius = 24.0;
    }
    return _button;
}

#pragma mark - Public

- (void)setLabelTextColor:(UIColor *)color {
    self.lineOneLabel.textColor = color;
    self.lineTwoLabel.textColor = color;
}

@end
