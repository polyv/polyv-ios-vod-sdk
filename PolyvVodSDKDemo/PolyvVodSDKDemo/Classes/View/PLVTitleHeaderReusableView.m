//
//  PLVTitleHeaderReusableView.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/25.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVTitleHeaderReusableView.h"

@interface PLVTitleHeaderReusableView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *decorateView;

@end

@implementation PLVTitleHeaderReusableView

#pragma mark - property

- (UILabel *)titleLabel {
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] init];
	}
	return _titleLabel;
}
- (UIView *)decorateView {
	if (!_decorateView) {
		_decorateView = [[UIView alloc] init];
	}
	return _decorateView;
}

- (void)setTitle:(NSString *)title {
	_title = title;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.titleLabel.text = title;
		[self.titleLabel sizeToFit];
		[self setNeedsLayout];
	});
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setupUI];
	}
	return self;
}

- (void)setupUI {
	[self addSubview:self.decorateView];
	self.decorateView.backgroundColor = [UIColor colorWithRed:0.565 green:0.643 blue:0.682 alpha:1.000];
	[self addSubview:self.titleLabel];
	self.titleLabel.textColor = [UIColor blackColor];
	self.titleLabel.font = [UIFont systemFontOfSize:17];
}

- (void)layoutSubviews {
	CGSize titleSize = self.titleLabel.bounds.size;
	CGFloat xMargin = 10;
	CGFloat yMargin = 24;
	self.decorateView.frame = CGRectMake(xMargin, yMargin, 4, titleSize.height);
	self.titleLabel.frame = (CGRect){{CGRectGetMaxX(self.decorateView.frame) + xMargin, yMargin}, titleSize};
}

@end
