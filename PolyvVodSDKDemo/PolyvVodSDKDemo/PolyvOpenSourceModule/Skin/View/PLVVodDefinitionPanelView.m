//
//  PLVVodDefinitionPanelView.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/26.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodDefinitionPanelView.h"
#import "UIColor+PLVVod.h"

@interface PLVVodDefinitionPanelView ()

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (weak, nonatomic) IBOutlet UIStackView *qualityStackView;

#pragma clang diagnostic pop

@end

@implementation PLVVodDefinitionPanelView

#pragma mark - property

- (void)setQualityCount:(int)qualityCount {
	_qualityCount = qualityCount;
	if (qualityCount < 1) {
		return;
	}
	if (qualityCount > 3) {
		_qualityCount = 3;
	}
	
	UIButton *qualityStandardButton = [self.class buttonWithTitle:@"流畅" target:self];
	UIButton *qualityHighButton = [self.class buttonWithTitle:@"高清" target:self];
	UIButton *qualityUltraButton = [self.class buttonWithTitle:@"超清" target:self];
	
	// 清除控件
	for (UIView *subview in self.qualityStackView.arrangedSubviews) {
		[self.qualityStackView removeArrangedSubview:subview];
		[subview removeFromSuperview];
	}
	switch (qualityCount) {
	case 1:{
		[self.qualityStackView addArrangedSubview:qualityStandardButton];
	}break;
	case 2:{
		[self.qualityStackView addArrangedSubview:qualityStandardButton];
		[self.qualityStackView addArrangedSubview:qualityHighButton];
	}break;
	case 3:{
		[self.qualityStackView addArrangedSubview:qualityStandardButton];
		[self.qualityStackView addArrangedSubview:qualityHighButton];
		[self.qualityStackView addArrangedSubview:qualityUltraButton];
	}break;
	default:{}break;
	}
}

- (void)setQuality:(int)quality {
	_quality = quality;
	if (quality <= 0 || quality > self.qualityStackView.arrangedSubviews.count) {
		return;
	}
	UIButton *qualityButton = self.qualityStackView.arrangedSubviews[quality-1];
	qualityButton.selected = YES;
}

#pragma mark - action

- (IBAction)qualityButtonAction:(UIButton *)sender {
	for (UIButton *button in self.qualityStackView.arrangedSubviews) {
		button.selected = NO;
	}
	NSInteger index = [self.qualityStackView.arrangedSubviews indexOfObject:sender];
	self.quality = (int)index + 1;
	if (self.qualityDidChangeBlock) self.qualityDidChangeBlock(self.quality);
	if (self.qualityButtonDidClick) self.qualityButtonDidClick(sender);
}

#pragma mark - tool

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor colorWithHex:0x00B3F7] forState:UIControlStateSelected];
	button.tintColor = [UIColor whiteColor];
	button.titleLabel.font = [UIFont systemFontOfSize:24];
	button.showsTouchWhenHighlighted = YES;
	[button addTarget:target action:@selector(qualityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

@end
