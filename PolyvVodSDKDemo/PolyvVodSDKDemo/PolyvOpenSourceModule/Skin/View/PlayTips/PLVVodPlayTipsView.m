//
//  PLVVodPlayTipsView.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2019/1/14.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVVodPlayTipsView.h"
#import <Masonry.h>

@implementation PLVVodPlayTipsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init{
    if (self = [super init]){
        
        self.layer.cornerRadius = 20;
        self.backgroundColor = [UIColor whiteColor];
        
        [self initSubview];
    }
    
    return self;
}

- (void)initSubview{
    [self addSubview:self.showDescribe];
    
    [self addSubview:self.playBtn];
    
    [self.showDescribe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset (10);
        make.centerY.offset (0);
        make.right.equalTo (self.playBtn.mas_left).offset (-10);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset (-10);
        make.centerY.offset (0);
        make.size.mas_equalTo (CGSizeMake(20, 20));
    }];
}

#pragma mark -- getter
- (UILabel *)showDescribe{
    if (!_showDescribe){
        _showDescribe = [[UILabel alloc] init];
        _showDescribe.font = [UIFont systemFontOfSize:15.0];
        _showDescribe.text = @"";
    }
    
    return _showDescribe;
}

- (UIButton *)playBtn{
    if (!_playBtn){
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"plv_play_tips"] forState:UIControlStateNormal];
    }
    
    return _playBtn;
}

@end
