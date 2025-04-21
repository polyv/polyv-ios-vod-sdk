//
//  PLVVodOptimizeOptionsPanelView.m
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/4/9.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import "PLVVodOptimizeOptionsPanelView.h"
#import "PLVVodOptimizeOptionView.h"

@interface PLVVodOptimizeOptionsPanelView ()

@property (nonatomic, strong) UIView *gestureView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) PLVVodOptimizeOptionView *hardCodeOption;
@property (nonatomic, strong) PLVVodOptimizeOptionView *softCodeOption;

@property (nonatomic, strong) PLVVodOptimizeOptionView *lineOneOption;
@property (nonatomic, strong) PLVVodOptimizeOptionView *lineTwoOption;
@property (nonatomic, strong) PLVVodOptimizeOptionView *lineThreeOption;

@property (nonatomic, strong) PLVVodOptimizeOptionView *httpDnsOption;
@property (nonatomic, strong) PLVVodOptimizeOptionView *localDnsOption;

@property (nonatomic, strong) UILabel *decodeLabel;
@property (nonatomic, strong) UILabel *lineLabel;
@property (nonatomic, strong) UILabel *dnsLabel;

@property (nonatomic, assign) NSInteger totalLine;

@end

@implementation PLVVodOptimizeOptionsPanelView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.gestureView];
    [self addSubview:self.contentView];
    
    [self.contentView addSubview:self.titleLable];
    [self.contentView addSubview:self.closeButton];
    [self.contentView addSubview:self.scrollView];
    
    // 解码部分
    [self.scrollView addSubview:self.decodeLabel];
    [self.scrollView addSubview:self.hardCodeOption];
    [self.scrollView addSubview:self.softCodeOption];
    
    // 线路部分
    [self.scrollView addSubview:self.lineLabel];
    [self.scrollView addSubview:self.lineOneOption];
    [self.scrollView addSubview:self.lineTwoOption];
    [self.scrollView addSubview:self.lineThreeOption];
    
    // 解析部分
    [self.scrollView addSubview:self.dnsLabel];
    [self.scrollView addSubview:self.httpDnsOption];
    [self.scrollView addSubview:self.localDnsOption];
    
    // Add tap gesture to hide the panel
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.gestureView addGestureRecognizer:tapGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL isFullScreen = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
    self.gestureView.frame = self.bounds;
    
    CGFloat contentWidth = self.bounds.size.width;
    CGFloat contentHeight = self.bounds.size.width;
    CGFloat start_x = 0;
    CGFloat start_y = self.bounds.size.height - contentHeight;
    if (isFullScreen){
        contentWidth = self.bounds.size.height;
        contentHeight = self.bounds.size.height;
        start_x = self.bounds.size.width - contentWidth;
        start_y = 0;
    }
    self.contentView.frame = CGRectMake(start_x,
                                        start_y,
                                        contentWidth, contentHeight);
    
    // 标题和关闭按钮
    self.titleLable.frame = CGRectMake(0, 15, contentWidth, 20);
    self.closeButton.frame = CGRectMake(contentWidth - 40, 10, 30, 30);
    
    // 可滚动区域
    CGFloat sectionPadding = 20;
    CGFloat currentY = CGRectGetMaxY(self.titleLable.frame) + sectionPadding;
    CGFloat scrollViewH = contentHeight - currentY;
    self.scrollView.frame = CGRectMake(0, currentY, contentWidth, scrollViewH);
    
    // 解码部分
    currentY = 0;
    self.decodeLabel.frame = CGRectMake(15, currentY, 100, 20);
    
    CGFloat optionPadding = 15;
    NSInteger optionWidth = (contentWidth - 3*optionPadding)/2;
    CGFloat optionHeight = 60;
    
    currentY = CGRectGetMaxY(self.decodeLabel.frame) + 10;
    self.hardCodeOption.frame = CGRectMake(optionPadding, currentY, optionWidth, optionHeight);
    self.softCodeOption.frame = CGRectMake(CGRectGetMaxX(self.hardCodeOption.frame) + optionPadding, 
                                          currentY, optionWidth, optionHeight);
    
    // 线路部分
    currentY = CGRectGetMaxY(self.hardCodeOption.frame) + sectionPadding;
    self.lineLabel.frame = CGRectMake(15, currentY, 100, 20);

    if (self.totalLine == 0){
        self.lineLabel.hidden = YES;
        self.lineOneOption.hidden = YES;
        self.lineTwoOption.hidden = YES;
        self.lineThreeOption.hidden = YES;
    }
    else if (self.totalLine == 1){
        self.lineLabel.hidden = NO;
        self.lineOneOption.hidden = NO;
        self.lineTwoOption.hidden = YES;
        self.lineThreeOption.hidden = YES;

        currentY = CGRectGetMaxY(self.lineLabel.frame) + 10;
        self.lineOneOption.frame = CGRectMake(optionPadding, currentY, optionWidth, optionHeight);

        currentY = CGRectGetMaxY(self.lineOneOption.frame) + sectionPadding;
    }
    else if (self.totalLine == 2){
        self.lineLabel.hidden = NO;
        self.lineOneOption.hidden = NO;
        self.lineTwoOption.hidden = NO;
        self.lineThreeOption.hidden = YES;

        currentY = CGRectGetMaxY(self.lineLabel.frame) + 10;
        self.lineOneOption.frame = CGRectMake(optionPadding, currentY, optionWidth, optionHeight);
        self.lineTwoOption.frame = CGRectMake(CGRectGetMaxX(self.lineOneOption.frame) + optionPadding, currentY, optionWidth, optionHeight);
        currentY = CGRectGetMaxY(self.lineOneOption.frame) + sectionPadding;
    }
    else if (self.totalLine == 3){
        self.lineLabel.hidden = NO;
        self.lineOneOption.hidden = NO;
        self.lineTwoOption.hidden = NO;
        self.lineThreeOption.hidden = NO;

        currentY = CGRectGetMaxY(self.lineLabel.frame) + 10;
        self.lineOneOption.frame = CGRectMake(optionPadding, currentY, optionWidth, optionHeight);
        self.lineTwoOption.frame = CGRectMake(CGRectGetMaxX(self.lineOneOption.frame) + optionPadding, currentY, optionWidth, optionHeight);
        currentY = CGRectGetMaxY(self.lineOneOption.frame) + 10;
        self.lineThreeOption.frame = CGRectMake(optionPadding, currentY, optionWidth, optionHeight);
        currentY = CGRectGetMaxY(self.lineThreeOption.frame) + 10;
    }
    
    // 解析部分
    self.dnsLabel.frame = CGRectMake(15, currentY, 100, 20);
    currentY = CGRectGetMaxY(self.dnsLabel.frame) + 10;
    
    self.httpDnsOption.frame = CGRectMake(optionPadding, currentY, optionWidth, optionHeight);
    self.localDnsOption.frame = CGRectMake(CGRectGetMaxX(self.httpDnsOption.frame) + optionPadding, 
                                          currentY, optionWidth, optionHeight);
    // 调整内容区域
    NSInteger contentSizeH = CGRectGetMaxY(self.httpDnsOption.frame) + 34;
    self.scrollView.contentSize = CGSizeMake(contentWidth, contentSizeH);
}

#pragma mark - Public Methods

- (void)setupWithHardDecode:(BOOL)hardDecode lineIndex:(NSInteger)lineIndex totalLine:(NSInteger)totalLine isHttpDns:(BOOL)isHttpDns {
    // 设置解码方式
    [self.hardCodeOption setSelected:hardDecode];
    [self.softCodeOption setSelected:!hardDecode];
    
    // 设置线路
    [self.lineOneOption setSelected:lineIndex == 0];
    [self.lineTwoOption setSelected:lineIndex == 1];
    [self.lineThreeOption setSelected:lineIndex == 2];
    
    // 设置DNS解析方式
    [self.httpDnsOption setSelected:isHttpDns];
    [self.localDnsOption setSelected:!isHttpDns];
    
    self.totalLine = totalLine;
    
    [self layoutIfNeeded];
}

- (void)show {
    self.hidden = NO;
    
    // 添加动画效果
    self.contentView.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 1.0;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 0;
//        self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        self.hidden = YES;
//        self.contentView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - Actions

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    [self hide];
}

- (void)closeButtonAction {
    [self hide];
}

- (void)handleDecodeOptionClick:(PLVVodOptimizeOptionView *)sender {
    BOOL isHardDecode = (sender == self.hardCodeOption);
    
    [self.hardCodeOption setSelected:isHardDecode];
    [self.softCodeOption setSelected:!isHardDecode];
    
    if ([self.delegate respondsToSelector:@selector(optimizeOptionsPanel:didSelectDecodeOption:)]) {
        [self.delegate optimizeOptionsPanel:self didSelectDecodeOption:isHardDecode];
    }
    
    [self hide];
}

- (void)handleLineOptionClick:(PLVVodOptimizeOptionView *)sender {
    NSInteger lineIndex = 0;
    if (sender == self.lineTwoOption)
        lineIndex = 1;
    else if (sender == self.lineThreeOption)
        lineIndex = 2;
    
    [self.lineOneOption setSelected:lineIndex == 0];
    [self.lineTwoOption setSelected:lineIndex == 1];
    [self.lineTwoOption setSelected:lineIndex == 2];
    
    if ([self.delegate respondsToSelector:@selector(optimizeOptionsPanel:didSelectLineOption:)]) {
        [self.delegate optimizeOptionsPanel:self didSelectLineOption:lineIndex];
    }
    
    [self hide];
}

- (void)handleDnsOptionClick:(PLVVodOptimizeOptionView *)sender {
    BOOL isHttpDns = (sender == self.httpDnsOption);
    
    [self.httpDnsOption setSelected:isHttpDns];
    [self.localDnsOption setSelected:!isHttpDns];
    
    if ([self.delegate respondsToSelector:@selector(optimizeOptionsPanel:didSelectDnsOption:)]) {
        [self.delegate optimizeOptionsPanel:self didSelectDnsOption:isHttpDns];
    }
    
    [self hide];
}

#pragma mark - Lazy Load

- (UIView *)gestureView {
    if (!_gestureView) {
        _gestureView = [[UIView alloc] init];
        _gestureView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _gestureView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 8.0;
        _contentView.clipsToBounds = YES;
    }
    return _contentView;
}

- (UIScrollView *)scrollView{
    if (!_scrollView){
        _scrollView = [[UIScrollView alloc] init];
        
    }
    return _scrollView;
}

- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [[UILabel alloc] init];
        _titleLable.text = @"播放线路";
        _titleLable.textColor = [UIColor blackColor];
        _titleLable.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _titleLable.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLable;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"plv_vod_btn_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)decodeLabel {
    if (!_decodeLabel) {
        _decodeLabel = [[UILabel alloc] init];
        _decodeLabel.text = @"解码";
        _decodeLabel.textColor = [UIColor darkGrayColor];
        _decodeLabel.font = [UIFont systemFontOfSize:14];
    }
    return _decodeLabel;
}

- (UILabel *)lineLabel {
    if (!_lineLabel) {
        _lineLabel = [[UILabel alloc] init];
        _lineLabel.text = @"线路";
        _lineLabel.textColor = [UIColor darkGrayColor];
        _lineLabel.font = [UIFont systemFontOfSize:14];
    }
    return _lineLabel;
}

- (UILabel *)dnsLabel {
    if (!_dnsLabel) {
        _dnsLabel = [[UILabel alloc] init];
        _dnsLabel.text = @"解析";
        _dnsLabel.textColor = [UIColor darkGrayColor];
        _dnsLabel.font = [UIFont systemFontOfSize:14];
    }
    return _dnsLabel;
}

- (PLVVodOptimizeOptionView *)hardCodeOption {
    if (!_hardCodeOption) {
        _hardCodeOption = [[PLVVodOptimizeOptionView alloc] init];
        _hardCodeOption.mainTitleText = @"硬解";
        _hardCodeOption.subTitleText = @"更省电(推荐)";
        [_hardCodeOption addTarget:self action:@selector(handleDecodeOptionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hardCodeOption;
}

- (PLVVodOptimizeOptionView *)softCodeOption {
    if (!_softCodeOption) {
        _softCodeOption = [[PLVVodOptimizeOptionView alloc] init];
        _softCodeOption.mainTitleText = @"软解";
        _softCodeOption.subTitleText = @"兼容性更好";
        [_softCodeOption addTarget:self action:@selector(handleDecodeOptionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _softCodeOption;
}

- (PLVVodOptimizeOptionView *)lineOneOption {
    if (!_lineOneOption) {
        _lineOneOption = [[PLVVodOptimizeOptionView alloc] init];
        _lineOneOption.mainTitleText = @"线路一";
        _lineOneOption.subTitleText = @"推荐线路，请优先尝试";
        [_lineOneOption addTarget:self action:@selector(handleLineOptionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lineOneOption;
}

- (PLVVodOptimizeOptionView *)lineTwoOption {
    if (!_lineTwoOption) {
        _lineTwoOption = [[PLVVodOptimizeOptionView alloc] init];
        _lineTwoOption.mainTitleText = @"线路二";
        _lineTwoOption.subTitleText = @"主线路不畅时切换";
        [_lineTwoOption addTarget:self action:@selector(handleLineOptionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lineTwoOption;
}

- (PLVVodOptimizeOptionView *)lineThreeOption{
    if (!_lineThreeOption){
        _lineThreeOption = [[PLVVodOptimizeOptionView alloc] init];
        _lineThreeOption.mainTitleText = @"线路三";
        _lineThreeOption.subTitleText = @"主线路不畅时切换";
        [_lineThreeOption addTarget:self action:@selector(handleLineOptionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lineThreeOption;
}

- (PLVVodOptimizeOptionView *)httpDnsOption {
    if (!_httpDnsOption) {
        _httpDnsOption = [[PLVVodOptimizeOptionView alloc] init];
        _httpDnsOption.mainTitleText = @"httpDns";
        _httpDnsOption.subTitleText = @"一般网络环境下更稳定";
        [_httpDnsOption addTarget:self action:@selector(handleDnsOptionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _httpDnsOption;
}

- (PLVVodOptimizeOptionView *)localDnsOption {
    if (!_localDnsOption) {
        _localDnsOption = [[PLVVodOptimizeOptionView alloc] init];
        _localDnsOption.mainTitleText = @"localDns";
        _localDnsOption.subTitleText = @"网络受限环境下可使用";
        [_localDnsOption addTarget:self action:@selector(handleDnsOptionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _localDnsOption;
}

@end
