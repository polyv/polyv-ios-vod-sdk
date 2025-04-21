//
//  PLVVodOptimizeOptionView.m
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/4/9.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import "PLVVodOptimizeOptionView.h"
#import "UIColor+PLVVod.h"

@interface PLVVodOptimizeOptionView ()

@property (nonatomic, strong) UILabel *mainTitle;
@property (nonatomic, strong) UILabel *subTitle;
@property (nonatomic, assign) BOOL selectState;

@end

@implementation PLVVodOptimizeOptionView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Public Methods

- (void)setMainTitleText:(NSString *)mainTitleText {
    _mainTitleText = [mainTitleText copy];
    self.mainTitle.text = mainTitleText;
    [self setNeedsLayout];
}

- (void)setSubTitleText:(NSString *)subTitleText {
    _subTitleText = [subTitleText copy];
    self.subTitle.text = subTitleText;
    [self setNeedsLayout];
}

#pragma mark - Override

- (void)setSelected:(BOOL)selected {
    _selectState = selected;
    [self updateViewState];
}

- (BOOL)isSelected {
    return _selectState;
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    // Layout mainTitle
    [self.mainTitle sizeToFit];
    CGFloat mainTitleX = 12;
    CGFloat mainTitleY = 10.0;
    CGFloat mainTitleWidth = self.bounds.size.width - 2*mainTitleX;
    CGFloat mainTitleHeight = self.mainTitle.frame.size.height;
    self.mainTitle.frame = CGRectMake(mainTitleX, mainTitleY, mainTitleWidth, mainTitleHeight);
    
    // Layout subTitle
    [self.subTitle sizeToFit];
    CGFloat subTitleX = 12;
    CGFloat subTitleY = CGRectGetMaxY(self.mainTitle.frame) + 5.0;
    CGFloat subTitleWidth = self.bounds.size.width - 2*subTitleX;
    CGFloat subTitleHeight = self.subTitle.frame.size.height;
    self.subTitle.frame = CGRectMake(subTitleX, subTitleY, subTitleWidth, subTitleHeight);
}

#pragma mark - Private

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 4.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
    
    [self addSubview:self.mainTitle];
    [self addSubview:self.subTitle];
    
    [self updateViewState];
}

- (void)updateViewState {
    if (self.selected) {
        self.backgroundColor = [UIColor colorWithHex:0x3F76FC alpha:0.1];
        self.mainTitle.textColor = [UIColor colorWithHex:0x3F76FC alpha:1];
        self.subTitle.textColor = [UIColor colorWithHex:0x3F76FC alpha:1];
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.mainTitle.textColor = [UIColor colorWithHex:0x00000 alpha:0.8];
        self.subTitle.textColor = [UIColor colorWithHex:0x000000 alpha:0.4];
    }
}

#pragma mark - Lazy Load

- (UILabel *)mainTitle {
    if (!_mainTitle) {
        _mainTitle = [[UILabel alloc] init];
        _mainTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _mainTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _mainTitle;
}

- (UILabel *)subTitle {
    if (!_subTitle) {
        _subTitle = [[UILabel alloc] init];
        _subTitle.font = [UIFont systemFontOfSize:12];
        _subTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _subTitle;
}

@end
