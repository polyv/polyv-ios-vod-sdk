//
//  PLVVodNetworkPlayErrorTipsView.m
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/4/17.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import "PLVVodNetworkPlayErrorTipsView.h"

@interface PLVVodNetworkPlayErrorTipsView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, assign) NSInteger startY;
@property (nonatomic, copy) NSString *tipsMessage;

@end

@implementation PLVVodNetworkPlayErrorTipsView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleButton];
    [self.contentView addSubview:self.closeButton];
}

- (void)updateUI{
    CGRect supreViewBounds = self.superview.bounds;
    if (supreViewBounds.size.width != self.bounds.size.width){
        self.frame = CGRectMake(0, 0, supreViewBounds.size.width, 40);
    }

    NSInteger offsetx = 30;
    if (supreViewBounds.size.width > supreViewBounds.size.height)
        offsetx = 60;
    
    CGSize buttonSize = CGSizeMake(30, 30);
    NSInteger maxTitleWidth = self.bounds.size.width - offsetx*2 - (10 + buttonSize.width);
    NSAttributedString *attributedText = [self createAttributedErrorText];
    [self.titleButton setAttributedTitle:attributedText forState:UIControlStateNormal];

    CGSize textSize = [attributedText boundingRectWithSize:CGSizeMake(maxTitleWidth, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil].size;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(15, 10, 15, 10);
    // 容器视图
    NSInteger contentWidth = textSize.width + 10 + buttonSize.width + inset.left*2;
    NSInteger contentHeight = textSize.height + inset.top*2;
    NSInteger startX = (self.bounds.size.width - contentWidth)/2;
    self.contentView.frame = CGRectMake(startX, self.startY, contentWidth, contentHeight);
    
    // 提示文本
    self.titleButton.frame = CGRectMake(inset.left, 0, textSize.width,contentHeight);

    // 关闭按钮
    self.closeButton.frame = CGRectMake(contentWidth - 30, 10, 20, 20);
}

#pragma mark - Public Methods

- (void)showInView:(UIView *)superView startY:(NSInteger)startY tipsMessage:(nonnull NSString *)tipsMessage{
    if (superView) {
        [superView addSubview:self];
        
        self.tipsMessage = tipsMessage;
        self.startY = startY;
        
        [self updateUI];
    }
}

- (void)hide {
    [self removeFromSuperview];
}

- (void)dismiss {
    [self hide];
}

#pragma mark - Private Methods

- (NSAttributedString *)createAttributedErrorText {
    if (!self.tipsMessage || [self.tipsMessage isKindOfClass:[NSNull class]]){
        self.tipsMessage = @"无法连接网络，可尝试切换线路";
    }
    
    // 默认提示
    NSString *text = self.tipsMessage;
//    NSString *text = @"无法连接网络，可尝试切换线路无法连接网络，可尝试切换线路无法连接网络，可尝试切换线路无法连接网络，可尝试切换线路无法连接网络，可尝试切换线路无法连接网络，可尝试切换线路无法连接网络，可尝试切换线路";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
    // Set color for the entire string
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, text.length)];
    // Set Font
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, text.length)];
    
    // Set color for the "线路" part
    NSRange range = [text rangeOfString:@"线路"];
    self.titleButton.userInteractionEnabled = NO;
    if (range.location != NSNotFound) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.25 green:0.64 blue:1.0 alpha:1.0] range:range];
        
        self.titleButton.userInteractionEnabled = YES;
    }
    
    return attributedString;
}

- (void)closeButtonAction {
    [self hide];
}

- (void)titleButtonClick:(UIButton *)titleBtn{
    if (self.handleSwitchEvent) {
        self.handleSwitchEvent();
    }
    
    [self hide];
}

#pragma mark - Lazy Loading

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 5;
        _contentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    }
    return _contentView;
}
    
- (UIButton *)titleButton{
    if (!_titleButton){
        _titleButton = [[UIButton alloc] init];
        _titleButton.backgroundColor = [UIColor clearColor];
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _titleButton.titleLabel.numberOfLines = 0;
        [_titleButton addTarget:self action:@selector(titleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:@"×" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

@end
