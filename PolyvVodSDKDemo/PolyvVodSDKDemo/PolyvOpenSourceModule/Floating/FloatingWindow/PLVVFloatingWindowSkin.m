//
//  PLVVFloatingWindowSkin.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/2/27.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import "PLVVFloatingWindowSkin.h"
#import <PLVMasonry/PLVMasonry.h>

@interface PLVVFloatingWindowSkin ()

@property (nonatomic, strong) UIImageView *topBarImageView;
@property (nonatomic, strong) UIImageView *zoomImageView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *exchangeButton;
@property (nonatomic, strong) UIButton *playButton;

@end

@implementation PLVVFloatingWindowSkin

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.topBarImageView];
        [self.topBarImageView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.top.and.left.and.right.plv_equalTo(0);
            make.height.plv_equalTo(32);
        }];
        
        [self addSubview:self.zoomImageView];
        [self.zoomImageView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.top.and.left.plv_equalTo(0);
            make.size.plv_equalTo(CGSizeMake(32, 32));
        }];
        
        [self addSubview:self.closeButton];
        [self.closeButton plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.top.and.right.plv_equalTo(0);
            make.size.plv_equalTo(CGSizeMake(32, 32));
        }];
        
        [self addSubview:self.exchangeButton];
        [self.exchangeButton plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.size.plv_equalTo(CGSizeMake(44, 44));
            make.centerX.plv_offset(-34);
            make.centerY.plv_equalTo(0);
        }];
        
        [self addSubview:self.playButton];
        [self.playButton plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.size.plv_equalTo(CGSizeMake(44, 44));
            make.centerX.plv_offset(34);
            make.centerY.plv_equalTo(0);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter

- (UIImageView *)topBarImageView {
    if (!_topBarImageView) {
        _topBarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plv_floating_topbar"]];
    }
    return _topBarImageView;
}

- (UIImageView *)zoomImageView {
    if (!_zoomImageView) {
        _zoomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plv_floating_btn_zoom"]];
    }
    return _zoomImageView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"plv_floating_btn_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)exchangeButton {
    if (!_exchangeButton) {
        _exchangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exchangeButton setImage:[UIImage imageNamed:@"plv_floating_btn_exchange"] forState:UIControlStateNormal];
        [_exchangeButton addTarget:self action:@selector(exchangeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exchangeButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"plv_floating_btn_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"plv_floating_btn_pause"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

#pragma mark - Action

- (void)closeButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapCloseButton)]) {
        [self.delegate tapCloseButton];
    }
}

- (void)exchangeButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapExchangeButton)]) {
        [self.delegate tapExchangeButton];
    }
}

- (void)playButtonAction {
    self.playButton.selected = !self.playButton.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapPlayButton:)]) {
        [self.delegate tapPlayButton:self.playButton.selected];
    }
}

#pragma mark - Public

- (void)statusIsPlaying:(BOOL)playing {
    self.playButton.selected = playing;
}

@end
