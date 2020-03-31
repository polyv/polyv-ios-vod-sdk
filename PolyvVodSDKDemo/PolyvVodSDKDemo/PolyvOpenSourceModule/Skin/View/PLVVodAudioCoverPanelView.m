//
//  PLVVodAudioCoverPanelView.m
//  PolyvVodSDKDemo
//
//  Created by 李长杰 on 2018/5/28.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodAudioCoverPanelView.h"
#import <YYWebImage/YYWebImage.h>

@interface PLVVodAudioCoverPanelView ()

@property (weak, nonatomic) IBOutlet UIView *audioCoverContainerView; // 最外层容器
@property (weak, nonatomic) IBOutlet UIImageView *audioCoverContainerBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIImageView *audioCoverImage; // 封面图
@property (weak, nonatomic) IBOutlet UIImageView *audioCoverBackImg; // 封面底图
@property (weak, nonatomic) IBOutlet UIView *audioCoverImgContainer; // 封面图容器

@end

@implementation PLVVodAudioCoverPanelView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.clipsToBounds = YES;
    
    self.audioCoverImage.layer.cornerRadius = 60;
    self.audioCoverImage.layer.masksToBounds = YES;
    
    self.audioCoverBackImg.contentMode = UIViewContentModeScaleAspectFill;
    
    self.audioCoverImage.contentMode = UIViewContentModeScaleAspectFill;
    self.audioCoverContainerBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setCoverUrl:(NSString *)url {
    [self.audioCoverContainerBackgroundImageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:nil];
    [self.audioCoverImage yy_setImageWithURL:[NSURL URLWithString:url] placeholder:nil];
}

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode {
    if (mode == PLVVodPlaybackModeAudio) {
        self.audioCoverContainerView.hidden = NO;
    } else {
        self.audioCoverContainerView.hidden = YES;
    }
}

- (void)hiddenContainerView:(BOOL)hidden {
    self.audioCoverContainerView.hidden = hidden;
}

- (void)setAniViewCornerRadius:(CGFloat)cornerRadius{
    self.audioCoverImage.layer.cornerRadius = cornerRadius;
    
    self.audioCoverImage.frame = CGRectMake(0, 0, 2 * cornerRadius, 2 * cornerRadius);
    self.audioCoverImage.center = CGPointMake(80, 80);
    
    CGFloat backImgWidth = 2 * cornerRadius + (cornerRadius <= 30 ? 20 : 40);
    self.audioCoverBackImg.frame = CGRectMake(0, 0, backImgWidth, backImgWidth);
    self.audioCoverBackImg.center = CGPointMake(80, 80);
}

- (void)startRotate {
    if ([self.audioCoverImage.layer.animationKeys count] == 0) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.beginTime = CACurrentMediaTime();
        animation.duration = 15;
        animation.repeatCount = HUGE_VALF;
        animation.fromValue = @(0.0);
        animation.toValue = @(2 * M_PI);
        animation.removedOnCompletion = NO;
        [self.audioCoverImage.layer addAnimation:animation forKey:@"rotate"];
    }
}

- (void)stopRotate {
    if ([self.audioCoverImage.layer.animationKeys count] != 0) {
        [self.audioCoverImage.layer removeAllAnimations];
    }
}

@end
