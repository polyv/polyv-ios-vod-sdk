//
//  PLVVodDanmuSendView.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/11/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodDanmuSendView.h"
#import "UIColor+PLVVod.h"
#import "PLVVodDanmu.h"

@interface PLVVodDanmuSendView ()

@property (weak, nonatomic) IBOutlet UITextField *danmuTextField;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputHeightLayout;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
@property (weak, nonatomic) IBOutlet UIStackView *colorButtonStackView;
@property (weak, nonatomic) IBOutlet UIStackView *typeButtonStackView;
@property (weak, nonatomic) IBOutlet UIStackView *fontSizeButtonStackView;
#pragma clang diagnostic pop

@property (nonatomic, assign) NSUInteger danmuColorHex;
@property (nonatomic, assign) int danmuFontSize;
@property (nonatomic, assign) NSInteger danmuMode;

@end

@implementation PLVVodDanmuSendView
{
	NSArray *_colors;
	NSArray *_modes;
	NSArray *_fontSizes;
}

#pragma mark - init & dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		[self commonInit];
	}
	return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	_colors = @[@(0xffffff), @(0xf44436), @(0xe239ff),
				@(0xe239ff), @(0x53c057), @(0xffd758)];
	_modes = @[@(PLVVodDanmuModeRoll), @(PLVVodDanmuModeTop), @(PLVVodDanmuModeBottom)];
	_fontSizes = @[@16, @18, @24];
	
	_danmuColorHex = 0xffffff;
	_danmuFontSize = 16;
	_danmuMode = PLVVodDanmuModeRoll;
}

#pragma mark - property

- (NSString *)danmuContent {
	return self.danmuTextField.text;
}

#pragma mark - view

- (void)awakeFromNib {
	[super awakeFromNib];
	self.danmuTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
	self.danmuTextField.leftViewMode = UITextFieldViewModeAlways;
	
	for (int i = 0; i < _colors.count; i++) {
		UIButton *colorButton = self.colorButtonStackView.arrangedSubviews[i];
		[colorButton setTintColor:[UIColor colorWithHex:[_colors[i] unsignedIntegerValue]]];
		[colorButton addTarget:self action:@selector(colorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	for (UIButton *button in self.typeButtonStackView.arrangedSubviews) {
		[button addTarget:self action:@selector(typeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	for (UIButton *button in self.fontSizeButtonStackView.arrangedSubviews) {
		[button addTarget:self action:@selector(fontSizeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)keyboardWillShow:(NSNotification *)notification {
	if (!self.superview) {
		return;
	}
	NSDictionary *userInfo = [notification userInfo];
	double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	[UIView animateWithDuration:duration animations:^{
		self.inputHeightLayout.constant = keyboardRect.size.height;
		self.settingButton.selected = NO;
	} completion:^(BOOL finished) {
		
	}];
}

- (void)keyboardDidShow:(NSNotification *)notification {
	if (!self.superview) {
		return;
	}
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)notification {}

#pragma mark - action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[self.danmuTextField resignFirstResponder];
}

- (IBAction)settingButtonAction:(UIButton *)sender {
	sender.selected = !sender.selected;
	if (sender.selected) {
		[self.danmuTextField resignFirstResponder];
	} else {
		[self.danmuTextField becomeFirstResponder];
	}
}

- (void)colorButtonAction:(UIButton *)sender {
	for (UIButton *button in self.colorButtonStackView.arrangedSubviews) {
		button.selected = NO;
	}
	sender.selected = !sender.selected;
	NSUInteger index = [self.colorButtonStackView.arrangedSubviews indexOfObject:sender];
	if (index < _colors.count) {
		self.danmuColorHex = [_colors[index] unsignedIntegerValue];
	}
}
- (void)typeButtonAction:(UIButton *)sender {
	for (UIButton *button in self.typeButtonStackView.arrangedSubviews) {
		button.selected = NO;
	}
	sender.selected = !sender.selected;
	NSUInteger index = [self.typeButtonStackView.arrangedSubviews indexOfObject:sender];
	if (index < _modes.count) {
		self.danmuMode = [_modes[index] integerValue];
	}
}
- (void)fontSizeButtonAction:(UIButton *)sender {
	for (UIButton *button in self.fontSizeButtonStackView.arrangedSubviews) {
		button.selected = NO;
	}
	sender.selected = !sender.selected;
	NSUInteger index = [self.fontSizeButtonStackView.arrangedSubviews indexOfObject:sender];
	if (index < _fontSizes.count) {
		self.danmuFontSize = [_fontSizes[index] intValue];
	}
}

- (void)didMoveToSuperview {
	if (self.superview) {
		self.danmuTextField.text = nil;
		[self.danmuTextField becomeFirstResponder];
		[[NSNotificationCenter defaultCenter] postNotificationName:PLVVodDanmuWillSendNotification object:self];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:PLVVodDanmuEndSendNotification object:self];
	}
}

@end
