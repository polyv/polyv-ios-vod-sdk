//
//  PLVPPTLoadFailAlertView.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/8/6.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVPPTLoadFailAlertView.h"
#import "PLVPPTFailView.h"
#import <PLVMasonry/PLVMasonry.h>

@interface PLVPPTLoadFailAlertView ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) PLVPPTFailView *failView;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRcog;

@end

@implementation PLVPPTLoadFailAlertView

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.bgView];
        [self.bgView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.edges.plv_equalTo(0);
        }];
        
        [self.bgView addGestureRecognizer:self.gestureRcog];
        
        [self addSubview:self.failView];
        [self.failView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.center.plv_equalTo(0);
            make.size.plv_equalTo(CGSizeMake(165, 208));
        }];
    }
    return self;
}

#pragma mark - Getter & Setter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.7;
    }
    return _bgView;
}

- (PLVPPTFailView *)failView {
    if (!_failView) {
        _failView = [[PLVPPTFailView alloc] init];
        [_failView.button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _failView;
}

- (UITapGestureRecognizer *)gestureRcog {
    if (!_gestureRcog) {
        _gestureRcog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmiss)];
        _gestureRcog.numberOfTapsRequired = 1;
        _gestureRcog.numberOfTouchesRequired = 1;
    }
    return _gestureRcog;
}

#pragma mark - Action

- (void)buttonAction {
    if (self.didTapButtonHandler) {
        self.didTapButtonHandler();
    }
    [self dissmiss];
}

- (void)dissmiss {
    [self removeFromSuperview];
}

@end
