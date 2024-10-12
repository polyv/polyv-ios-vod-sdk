//
//  PLVSecureView.m
//  PLVVodSDK
//
//  Created by polyv on 2024/8/20.
//  Copyright © 2024 POLYV. All rights reserved.
//

#import "PLVSecureView.h"

@interface PLVSecureView ()

@property (nonatomic, strong) UITextField *field;

@end

@implementation PLVSecureView

#pragma mark [life cycle]
- (instancetype)init{
    if (self = [super init]){
        [self setupUI];
    }
    return self;
}

#pragma mark [init]
- (void)setupUI{
    [self buildSubView];
}

- (void)buildSubView
{
    UIView *secureView = [self makeSecureViewWithSecureEnabled:YES];
    [self.secureView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 原有view 迁移
        [secureView addSubview:obj];
    }];
    self.secureView = secureView;
}

- (UIView *)makeSecureViewWithSecureEnabled:(BOOL)enabled
{
    UITextField *field = [[UITextField alloc] initWithFrame:self.bounds];
    field.secureTextEntry = enabled;
    UIView *secureView = field.subviews.firstObject;
    if (secureView == nil)
    {
        // 普通视图 可以系统截屏
        secureView = [[UIView alloc] initWithFrame:self.bounds];
    }
    secureView.userInteractionEnabled = YES;
    [secureView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    // 保持 防止崩溃
    self.field = field;
    
    return secureView;
}

@end
