//
//  PLVVodShrinkscreenView.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodShrinkscreenView.h"

@interface PLVVodShrinkscreenView ()

@property (weak, nonatomic) IBOutlet UIImageView *videoModeSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoModeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *audioModeSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *audioModeLabel;

@end

@implementation PLVVodShrinkscreenView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    
}

#pragma mark getter

// 清晰度切换
- (UIButton *)qualitySwitchBtn{
    if (!_qualitySwitchBtn){
        _qualitySwitchBtn = [[UIButton alloc] init];
        [_qualitySwitchBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
    return _qualitySwitchBtn;
}

// 播放倍速切换
- (UIButton *)rateSwitchBtn{
    if (!_rateSwitchBtn){
        _rateSwitchBtn = [[UIButton alloc] init];
        [_rateSwitchBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
    return _rateSwitchBtn;
}

// 线路切换
- (UIButton *)lineSwitchBtn{
    if (!_lineSwitchBtn){
        _lineSwitchBtn = [[UIButton alloc] init];
        [_lineSwitchBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
    return _lineSwitchBtn;
}

#pragma mark button action

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode {
    if (mode == PLVVodPlaybackModeAudio) {
        self.videoModeSelectedImageView.hidden = YES;
        self.videoModeLabel.highlighted = NO;
        self.audioModeSelectedImageView.hidden = NO;
        self.audioModeLabel.highlighted = YES;
    } else {
        self.videoModeSelectedImageView.hidden = NO;
        self.videoModeLabel.highlighted = YES;
        self.audioModeSelectedImageView.hidden = YES;
        self.audioModeLabel.highlighted = NO;
    }
}

- (NSString *)description {
	NSMutableString *description = [super.description stringByAppendingString:@":\n"].mutableCopy;
	[description appendFormat:@" playPauseButton: %@;\n", _playPauseButton];
	return description;
}

@end
