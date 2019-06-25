//
//  PLVVodNetworkTipsView.m
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2019/3/14.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVVodNetworkTipsView.h"

@interface PLVVodNetworkTipsView ()

@end

@implementation PLVVodNetworkTipsView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)layoutSubviews{
    float boundsW = self.bounds.size.width;
    float boundsH = self.bounds.size.height;
    
    self.playBtn.bounds = CGRectMake(0, 0, 130, 46);
    self.playBtn.center = CGPointMake(boundsW / 2, boundsH / 2 - 8);
    
    self.tipsLb.bounds = CGRectMake(0, 0, boundsW, 20);
    self.tipsLb.center = CGPointMake(boundsW / 2, self.playBtn.center.y + 8 + (self.playBtn.bounds.size.height/2) + (20/2));
}

- (void)createUI{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    [self addSubview:self.playBtn];
    [self addSubview:self.tipsLb];
}

- (UIButton *)playBtn{
    if (_playBtn == nil) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setTitle:@"流量播放" forState:UIControlStateNormal];
        [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"plv_vod_btn_play"] forState:UIControlStateNormal];
        _playBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _playBtn.layer.cornerRadius = 23;
        _playBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10.0, 0, 0);
        _playBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UILabel *)tipsLb{
    if (_tipsLb == nil) {
        _tipsLb = [[UILabel alloc]init];
        _tipsLb.text = @"您正在使用非WiFi网络，继续播放将产生流量。";
        _tipsLb.textColor = [UIColor whiteColor];
        _tipsLb.font = [UIFont systemFontOfSize:14];
        _tipsLb.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLb;
}

- (void)playBtnClick:(UIButton *)btn{
    if (self.playBtnClickBlock) {
        self.playBtnClickBlock();
    }
}

- (void)show{
    self.userInteractionEnabled = YES;
    self.alpha = 1;
    self.isShow = YES;
}

- (void)hide{
    self.userInteractionEnabled = NO;
    self.alpha = 0;
    self.isShow = NO;
}

@end
