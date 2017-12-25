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

@property (weak, nonatomic) IBOutlet UIStackView *subtitleStackView;
@property (weak, nonatomic) IBOutlet UIStackView *scalingModeStackView;

#pragma clang diagnostic pop

@end

@implementation PLVVodSettingPanelView

#pragma mark - property

- (void)setSubtitleKeys:(NSArray<NSString *> *)subtitleKeys {
	_subtitleKeys = subtitleKeys;
	for (UIView *subview in self.subtitleStackView.arrangedSubviews) {
		[self.subtitleStackView removeArrangedSubview:subview];
		[subview removeFromSuperview];
	}
	if (!subtitleKeys.count) {
		UIButton *button = [self.class buttonWithTitle:@"无字幕"];
		button.enabled = NO;
		[self.subtitleStackView addArrangedSubview:button];
		return;
	}
	for (NSString *subtitleKey in subtitleKeys) {
		UIButton *subtitleButton = [self.class buttonWithTitle:subtitleKey];
		[self.subtitleStackView addArrangedSubview:subtitleButton];
		[subtitleButton addTarget:self action:@selector(subtitleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)setScalingMode:(NSInteger)scalingMode {
	_scalingMode = scalingMode;
	if (self.scalingModeDidChangeBlock) self.scalingModeDidChangeBlock(scalingMode);
}

#pragma mark - action

- (IBAction)subtitleButtonAction:(UIButton *)sender {
	//[self.subtitleStackView.arrangedSubviews makeObjectsPerformSelector:@selector(setSelected:) withObject:@NO];
	for (UIButton *button in self.subtitleStackView.arrangedSubviews) {
		button.selected = NO;
	}
	sender.selected = YES;
	NSInteger index = [self.subtitleStackView.arrangedSubviews indexOfObject:sender];
	self.currentSubtitleKey = self.subtitleKeys[index];
}

- (IBAction)scaleModeButtonAction:(UIButton *)sender {
	//[self.scalingModeStackView.arrangedSubviews makeObjectsPerformSelector:@selector(setSelected:) withObject:@NO];
	for (UIButton *button in self.scalingModeStackView.arrangedSubviews) {
		button.selected = NO;
	}
	sender.selected = YES;
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
