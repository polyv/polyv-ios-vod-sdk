//
//  PLVVodSettingPanelView.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodSettingPanelView.h"
#import <PLVVodSDK/PLVVodPlayerViewController.h>
#import "UIColor+PLVVod.h"

@interface PLVVodSettingPanelView ()

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (weak, nonatomic) IBOutlet UIStackView *subtitleStackView;    // 字幕设置
@property (weak, nonatomic) IBOutlet UIStackView *scalingModeStackView; // 视频填充
@property (weak, nonatomic) IBOutlet UIStackView *subtitleSeparateStackView; // 字幕分割
@property (weak, nonatomic) IBOutlet UIStackView *containerStackView; // 容器视图

#pragma clang diagnostic pop

@end

@implementation PLVVodSettingPanelView

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode {
    
    if (mode == PLVVodPlaybackModeAudio) {
        
        // 隐藏视频相关配置 todo
        NSLog(@"hide video setting");
        
        if (!self.scalingModeStackView.hidden)
        {
            [self clearContainerStackView];

            [self.containerStackView addArrangedSubview:self.brightnessSlider];
            [self.containerStackView addArrangedSubview:self.volumeSlider];
            
            self.containerStackView.axis = UILayoutConstraintAxisVertical;
            self.containerStackView.spacing = 60;
            
            self.scalingModeStackView.hidden = YES;
            self.subtitleSeparateStackView.hidden = YES;
            self.subtitleStackView.hidden = YES;
        }
        
    } else {
        // 显示视频相关配置 todo
        NSLog(@"show video setting");
        
        if (self.scalingModeStackView.hidden)
        {
            [self clearContainerStackView];
            
            [self.containerStackView addArrangedSubview:self.brightnessSlider];
            [self.containerStackView addArrangedSubview:self.volumeSlider];
            [self.containerStackView addArrangedSubview:self.scalingModeStackView];
            [self.containerStackView addArrangedSubview:self.subtitleSeparateStackView];
            [self.containerStackView addArrangedSubview:self.subtitleStackView];
            
            self.containerStackView.axis = UILayoutConstraintAxisVertical;
            self.containerStackView.spacing = 40;
            
            self.scalingModeStackView.hidden = NO;
            self.subtitleSeparateStackView.hidden = NO;
            self.subtitleStackView.hidden = NO;
        }
    }
}

- (void)clearContainerStackView
{
    [self.containerStackView removeArrangedSubview:self.brightnessSlider];
    [self.containerStackView removeArrangedSubview:self.volumeSlider];
    [self.containerStackView removeArrangedSubview:self.scalingModeStackView];
    [self.containerStackView removeArrangedSubview:self.subtitleSeparateStackView];
    [self.containerStackView removeArrangedSubview:self.subtitleStackView];
}

#pragma mark - property

- (void)setSubtitleKeys:(NSArray<NSString *> *)subtitleKeys {
	_subtitleKeys = subtitleKeys;
	
	// 无字幕按钮
	UIButton *noSubtitleButton = [self.class buttonWithTitle:@"无"];
	noSubtitleButton.selected = YES;
	[noSubtitleButton addTarget:self action:@selector(subtitleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	
	// 清除控件
	for (UIView *subview in self.subtitleStackView.arrangedSubviews) {
		[self.subtitleStackView removeArrangedSubview:subview];
		[subview removeFromSuperview];
	}
	
	if (!subtitleKeys.count) {
		noSubtitleButton.userInteractionEnabled = NO;
		[self.subtitleStackView addArrangedSubview:noSubtitleButton];
		return;
	}
	for (NSString *subtitleKey in subtitleKeys) {
		UIButton *subtitleButton = [self.class buttonWithTitle:subtitleKey];
		[self.subtitleStackView addArrangedSubview:subtitleButton];
		[subtitleButton addTarget:self action:@selector(subtitleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	[self.subtitleStackView addArrangedSubview:noSubtitleButton];
}

- (void)setScalingMode:(NSInteger)scalingMode {
	_scalingMode = scalingMode;
	if (self.scalingModeDidChangeBlock) self.scalingModeDidChangeBlock(scalingMode);
	
	// 拉伸模式
	UIButton *selectedScalingButton = self.scalingModeStackView.arrangedSubviews[self.scalingMode];
	selectedScalingButton.selected = YES;
}

#pragma mark - action

- (IBAction)subtitleButtonAction:(UIButton *)sender {
	for (UIButton *button in self.subtitleStackView.arrangedSubviews) {
		button.selected = NO;
	}
	sender.selected = YES;
	NSInteger index = [self.subtitleStackView.arrangedSubviews indexOfObject:sender];
	self.selectedSubtitleKey = index >= self.subtitleKeys.count ? nil : self.subtitleKeys[index];
	if (self.selectedSubtitleKeyDidChangeBlock) self.selectedSubtitleKeyDidChangeBlock(self.selectedSubtitleKey);
}

- (IBAction)scaleModeButtonAction:(UIButton *)sender {
	for (UIButton *button in self.scalingModeStackView.arrangedSubviews) {
		button.selected = NO;
	}
	NSInteger mode = [self.scalingModeStackView.arrangedSubviews indexOfObject:sender];
	self.scalingMode = mode;
}

+ (UIButton *)buttonWithTitle:(NSString *)title {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor colorWithHex:0x00B3F7] forState:UIControlStateSelected];
	button.tintColor = [UIColor whiteColor];
	button.titleLabel.font = [UIFont systemFontOfSize:16];
	button.showsTouchWhenHighlighted = YES;
	return button;
}

@end
