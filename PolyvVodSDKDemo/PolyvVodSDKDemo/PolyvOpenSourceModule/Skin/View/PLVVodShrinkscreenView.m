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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (weak, nonatomic) IBOutlet UIStackView *rightToolStackView;

#pragma clang diagnostic pop

@end

@implementation PLVVodShrinkscreenView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self initUIControl];
}

- (void)initUIControl{
    // 默认隐藏清晰度
    self.isShowQuality = NO;
    self.definitionButton.hidden = !self.isShowQuality;

    // 默认隐藏播放速率
    self.isShowRate = NO;
    self.playbackRateButton.hidden = !self.isShowRate;

    //  默认隐藏线路切换
    self.isShowRouteline = NO;
    self.routeButton.hidden = !self.isShowRouteline;
}

- (void)layoutSubviews{
    
    // 客户可以具体需求，调整布局
    if (self.frame.size.width <= PLV_Min_ScreenWidth){
        self.rightToolStackView.spacing = 10;
    }
    else{
        self.rightToolStackView.spacing = 15;
    }
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

- (void)setEnableQualityBtn:(BOOL)enableQualityBtn{
    self.definitionButton.enabled = enableQualityBtn;
    if (enableQualityBtn){
        self.definitionButton.alpha = 1.0;
    }
    else{
        self.definitionButton.alpha = 0.5;
    }
}

- (NSString *)description {
	NSMutableString *description = [super.description stringByAppendingString:@":\n"].mutableCopy;
	[description appendFormat:@" playPauseButton: %@;\n", _playPauseButton];
	return description;
}

@end
