//
//  PLVToolbar.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/20.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVToolbar.h"
#import "UIColor+PLVVod.h"

@interface PLVToolbar ()

@end

@implementation PLVToolbar

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
	self.barTintColor = [UIColor colorWithHex:0x2196F3];
}

#pragma mark - property

- (void)setButtons:(NSArray<UIButton *> *)buttons {
	_buttons = buttons;
	if (!buttons.count) {
		return;
	}
	NSMutableArray *items = [NSMutableArray array];
	//CGFloat maxButtonWidth = CGRectGetWidth(self.bounds) / buttons.count;
	//CGFloat maxButtonHeight = CGRectGetHeight(self.bounds);
	
	for (int i = 0; i < buttons.count; i++) {
		[items addObject:self.flexibleItem];
		UIButton *button = buttons[i];
		//button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, maxButtonWidth, maxButtonHeight);
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
		[items addObject:buttonItem];
		[items addObject:self.flexibleItem];
		[items addObject:self.separatorItem];
	}
	[items removeLastObject];
	[self setItems:items animated:YES];
	self.clipsToBounds = YES;
}

#pragma mark - public method

+ (void)addToolbarOnView:(UIView *)superview {
	CGFloat width = CGRectGetWidth(superview.bounds);
	CGFloat height = 50;
	CGFloat y = CGRectGetHeight(superview.bounds) - height - 64;
	PLVToolbar *toolbar = [[PLVToolbar alloc] initWithFrame:CGRectZero];
	[superview addSubview:toolbar];
	toolbar.frame = CGRectMake(0, y, width, height);
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
}

+ (UIButton *)buttonWithTitle:(NSString *)title image:(UIImage *)image {
	CGFloat margin = image ? 20 : 0;
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:title forState:UIControlStateNormal];
	[button setImage:image forState:UIControlStateNormal];
	//[button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
	button.showsTouchWhenHighlighted = YES;
	button.titleLabel.font = [UIFont systemFontOfSize:18];
	button.titleEdgeInsets = UIEdgeInsetsMake(0, margin, 0, 0);
	button.tintColor = [UIColor whiteColor];
	CGSize buttonSize = [title sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
	buttonSize.width += margin + buttonSize.height;
	button.bounds = (CGRect){CGPointZero, buttonSize};
	
	return button;
}

- (UIBarButtonItem *)flexibleItem {
	UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	return flexibleItem;
}
- (UIBarButtonItem *)separatorItem {
	UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 24)];
	separatorView.backgroundColor = [UIColor colorWithWhite:1 alpha:.65];
	UIBarButtonItem *separatorItem = [[UIBarButtonItem alloc] initWithCustomView:separatorView];
	return separatorItem;
}

@end
