//
//  PLVVodDefinitionTipsView.m
//  PolyvVodSDKDemo
//
//  Created by POLYV-UX on 2021/7/19.
//  Copyright © 2021 POLYV. All rights reserved.
//

#import "PLVVodDefinitionTipsView.h"

@interface PLVVodDefinitionTipsView ()<UITextViewDelegate>

/// 是否正在展示
@property (nonatomic, assign) BOOL isShowing;

/// 是否不再提示
@property (nonatomic, assign) BOOL isDoNotShowAgain;

@property (nonatomic, assign) PLVVodQuality switchQuality;

@property (nonatomic, strong) UITextView *tipTextView;

@property (nonatomic, assign) CGFloat tipWidth;

@end

@implementation PLVVodDefinitionTipsView

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)layoutSubviews
{
    self.tipTextView.frame = CGRectMake(self.bounds.size.width - self.tipWidth - 20, self.bounds.size.height - 100, self.tipWidth, 20);
}

#pragma mark - Initialize

- (void)initUI
{
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    [self addSubview:self.tipTextView];
}


#pragma mark - Public

-(void)showSwitchQuality:(PLVVodQuality)quality
{
    if (self.isShowing || self.isDoNotShowAgain) {
        return;
    }
    self.switchQuality = quality;
    
    NSString *qualityString = @"切换到流畅";
    if (quality == PLVVodQualityStandard) {
        qualityString = @"切换到流畅";
    }else if (quality == PLVVodQualityHigh) {
        qualityString = @"切换到高清";
    }else if (quality == PLVVodQualityUltra) {
        qualityString = @"切换到超清";
    }
    NSString *doNotShowString = @"不再提示";
    NSString *tipContentString = [NSString stringWithFormat:@"您的网络环境较差，可尝试%@或者选择%@", qualityString, doNotShowString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tipContentString attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0],
                                                     NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [attributedString addAttribute:NSLinkAttributeName value:@"switchQuality://" range:[tipContentString rangeOfString:qualityString]];
    [attributedString addAttribute:NSLinkAttributeName value:@"doNotShowAgain://" range:[tipContentString rangeOfString:doNotShowString]];
    self.tipTextView.attributedText = attributedString;
    
    self.tipWidth = [attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 15) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    self.tipTextView.frame = CGRectMake(self.bounds.size.width - self.tipWidth - 20, self.bounds.size.height - 100, self.tipWidth, 20);
    
    self.isShowing = YES;
    self.hidden = NO;
}

-(void)showSwitchSuccess:(PLVVodQuality)quality
{
    NSString *qualityString = @"流畅";
    if (quality == PLVVodQualityStandard) {
        qualityString = @"流畅";
    }else if (quality == PLVVodQualityHigh) {
        qualityString = @"高清";
    }else if (quality == PLVVodQualityUltra) {
        qualityString = @"超清";
    }
    NSString *tipContentString = [NSString stringWithFormat:@"已为您切换为%@", qualityString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tipContentString attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0],
                                                     NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [attributedString addAttribute:NSLinkAttributeName value:@"successQuality://" range:[tipContentString rangeOfString:qualityString]];
    self.tipTextView.attributedText = attributedString;
    
    self.tipWidth = [attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 15) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    self.tipTextView.frame = CGRectMake(self.bounds.size.width - self.tipWidth - 20, self.bounds.size.height - 100, self.tipWidth, 20);
    
    self.isShowing = YES;
    self.hidden = NO;
    
    [self performSelector:@selector(hide) withObject:nil afterDelay:1.5];
}

-(void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isShowing = NO;
        self.hidden = YES;
    });
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    if ([URL.scheme isEqualToString:@"switchQuality"]) {
        if (self.clickSwitchQualityBlock) {
            [self hide];
            self.clickSwitchQualityBlock(self.switchQuality);
        }
        return NO;
    }
    if ([URL.scheme isEqualToString:@"doNotShowAgain"]) {
        self.isDoNotShowAgain = YES;
        [self hide];
        return NO;
    }
    
    return YES;
}


#pragma mark - Loadlazy
-(UITextView *)tipTextView
{
    if (_tipTextView == nil) {
        _tipTextView = [[UITextView alloc]init];
        _tipTextView.editable = NO;
        _tipTextView.delegate = self;
        _tipTextView.backgroundColor = [UIColor clearColor];
        _tipTextView.textContainer.lineFragmentPadding = 0.0;
        _tipTextView.textContainerInset = UIEdgeInsetsMake(2, 0, 0, 0);
        UIColor *linkColor = [UIColor colorWithRed:19/255.0 green:126/255.0 blue:188/255.0 alpha:1];
        _tipTextView.linkTextAttributes = @{NSForegroundColorAttributeName:linkColor};
    }
    return _tipTextView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
