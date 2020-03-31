//
//  PLVDemoPlayerViewController.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/3/30.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import "PLVDemoPlayerViewController.h"
#import <PLVMasonry/PLVMasonry.h>

@interface PLVDemoPlayerViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation PLVDemoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.button];
    [self.button plv_makeConstraints:^(PLVMASConstraintMaker *make) {
        make.size.plv_equalTo(CGSizeMake(100, 50));
        make.center.plv_equalTo(0);
    }];
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _button.backgroundColor = [UIColor whiteColor];
        _button.layer.borderWidth = 1;
        _button.layer.borderColor = [UIColor grayColor].CGColor;
        [_button setTitle:@"横竖屏切换" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _button;
}

- (void)buttonAction {
    [self setPlayerFullScreen:!self.fullscreen];
}

@end
