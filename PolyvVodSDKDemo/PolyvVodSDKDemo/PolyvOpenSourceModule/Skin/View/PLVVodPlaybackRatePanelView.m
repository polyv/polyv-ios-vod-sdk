//
//  PLVVodPlaybackRatePanelView.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/26.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodPlaybackRatePanelView.h"
#import "UIColor+PLVVod.h"

@interface PLVVodPlaybackRatePanelView ()

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (weak, nonatomic) IBOutlet UIStackView *playbackRateStackView;

#pragma clang diagnostic pop

@property (nonatomic, strong) NSArray<NSNumber *> *playbackRates;

@end

@implementation PLVVodPlaybackRatePanelView

- (void)awakeFromNib {
	[super awakeFromNib];
	for (UIView *subview in self.playbackRateStackView.arrangedSubviews) {
		[self.playbackRateStackView removeArrangedSubview:subview];
		[subview removeFromSuperview];
	}
	self.playbackRates = @[@0.5, @1.0, @1.2, @1.5, @2];
	for (NSNumber *playbackRateNumber in self.playbackRates) {
		double playbackRate = playbackRateNumber.doubleValue;
		NSString *title = [NSString stringWithFormat:@"%.1fx", playbackRate];
		UIButton *rateButton = [self.class buttonWithTitle:title target:self];
		[self.playbackRateStackView addArrangedSubview:rateButton];
	}
}

- (void)setCurRate:(float)curRate{
    
    _curRate = curRate;
    for (UIButton *button in self.playbackRateStackView.arrangedSubviews) {
        if ([button.titleLabel.text floatValue] == self.curRate){
            button.selected = YES;
        }
        else{
            button.selected = NO;
        }
    }
}

#pragma mark - action

- (IBAction)rateButtonAction:(UIButton *)sender {
	for (UIButton *button in self.playbackRateStackView.arrangedSubviews) {
		button.selected = NO;
	}
	sender.selected = YES;
	NSInteger index = [self.playbackRateStackView.arrangedSubviews indexOfObject:sender];
	double playbackRate = self.playbackRates[index].doubleValue;
	if (self.selectedPlaybackRateDidChangeBlock) self.selectedPlaybackRateDidChangeBlock(playbackRate);
	if (self.playbackRateButtonDidClick) self.playbackRateButtonDidClick(sender);
}

#pragma mark - tool

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor colorWithHex:0x00B3F7] forState:UIControlStateSelected];
	button.tintColor = [UIColor whiteColor];
	button.titleLabel.font = [UIFont systemFontOfSize:24];
	button.showsTouchWhenHighlighted = YES;
	[button addTarget:target action:@selector(rateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

@end
