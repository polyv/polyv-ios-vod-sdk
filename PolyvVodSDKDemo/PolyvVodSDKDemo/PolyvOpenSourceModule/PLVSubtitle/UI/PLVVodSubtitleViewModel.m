//
//  PLVVodSubtitleViewModel.m
//  PLVVodSubtitleDemo
//
//  Created by Bq Lin on 2017/12/4.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodSubtitleViewModel.h"
#import "PLVVodSubtitleLaTeXHelper.h"

static const double PLVVodSubtitleAnimationDuration = 0.15;

@interface PLVVodSubtitleItemStyle ()

@end

@implementation PLVVodSubtitleItemStyle

+ (instancetype)styleWithTextColor:(UIColor *)textColor bold:(BOOL)bold italic:(BOOL)italic backgroundColor:(UIColor *)backgroundColor {
    PLVVodSubtitleItemStyle *style = [[PLVVodSubtitleItemStyle alloc] init];
    style.textColor = textColor;
    style.bold = bold;
    style.italic = italic;
    style.backgroundColor = backgroundColor;
    return style;
}

@end

@interface PLVVodSubtitleViewModel ()

@end

@implementation PLVVodSubtitleViewModel

#pragma mark - dealloc & init


#pragma mark - property

- (void)setEnable:(BOOL)enable {
	_enable = enable;
	[self performSelectorOnMainThread:@selector(hideSubtitleWithAnimation) withObject:nil waitUntilDone:YES];
}

- (void)setSubtitleItem:(PLVVodSubtitleItem *)subtitleItem {
	BOOL same = subtitleItem == _subtitleItem;
	if (same) {
		return;
	}
	_subtitleItem = subtitleItem;

    [self subtitleItemDidChange:subtitleItem];
}

- (void)setSubtitleAtTopItem:(PLVVodSubtitleItem *)subtitleAtTopItem {
    BOOL same = subtitleAtTopItem == _subtitleAtTopItem;
    if (same) {
        return;
    }
    _subtitleAtTopItem = subtitleAtTopItem;
    
    [self subtitleItemAtTopDidChange:subtitleAtTopItem];
}

- (void)setSubtitleItem2:(PLVVodSubtitleItem *)subtitleItem2 {
    BOOL same = subtitleItem2 == _subtitleItem2;
    if (same) {
        return;
    }
    _subtitleItem2 = subtitleItem2;

    [self subtitleItem2DidChange:subtitleItem2];
}

- (void)setSubtitleAtTopItem2:(PLVVodSubtitleItem *)subtitleAtTopItem2 {
    BOOL same = subtitleAtTopItem2 == _subtitleAtTopItem2;
    if (same) {
        return;
    }
    _subtitleAtTopItem2 = subtitleAtTopItem2;
    
    [self subtitleItem2AtTopDidChange:subtitleAtTopItem2];
}

- (void)setSubtitleLabel:(UILabel *)subtitleLabel {
    [self setSubtitleLabel:subtitleLabel style:nil];
}

- (void)setSubtitleLabel:(UILabel *)subtitleLabel style:(PLVVodSubtitleItemStyle *)style {
    _subtitleLabel = subtitleLabel;
    _subtitleItemStyle = style;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupSubtitleLabel:subtitleLabel style:style];
    });
}

- (void)setSubtitleTopLabel:(UILabel *)subtitleTopLabel {
    [self setSubtitleTopLabel:subtitleTopLabel style:nil];
}

- (void)setSubtitleTopLabel:(UILabel *)subtitleTopLabel style:(PLVVodSubtitleItemStyle *)style {
    _subtitleTopLabel = subtitleTopLabel;
    _subtitleAtTopItemStyle = style;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupSubtitleTopLabel:subtitleTopLabel style:style];
    });
}

- (void)setSubtitleLabel2:(UILabel *)subtitleLabel2 {
    [self setSubtitleLabel2:subtitleLabel2 style:nil];
}

- (void)setSubtitleLabel2:(UILabel *)subtitleLabel2 style:(PLVVodSubtitleItemStyle *)style {
    _subtitleLabel2 = subtitleLabel2;
    _subtitleItemStyle2 = style;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupSubtitleLabel2:subtitleLabel2 style:style];
    });
}

- (void)setSubtitleTopLabel2:(UILabel *)subtitleTopLabel2 {
    [self setSubtitleTopLabel2:subtitleTopLabel2 style:nil];
}

- (void)setSubtitleTopLabel2:(UILabel *)subtitleTopLabel2 style:(PLVVodSubtitleItemStyle *)style {
    _subtitleTopLabel2 = subtitleTopLabel2;
    _subtitleAtTopItemStyle2 = style;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupSubtitleTopLabel2:subtitleTopLabel2 style:style];
    });
}

#pragma mark - private

- (void)hideSubtitleWithAnimation {
	[UIView animateWithDuration:PLVVodSubtitleAnimationDuration animations:^{
		self.subtitleLabel.alpha = self.enable ? 1.0 : 0;
        self.subtitleTopLabel.alpha = self.enable ? 1.0 : 0;
	}];
}

- (void)setupSubtitleLabel:(UILabel *)subtitleLabel style:(PLVVodSubtitleItemStyle *)style {
    subtitleLabel.text = @"";
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.contentMode = UIViewContentModeBottom;
    subtitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    subtitleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    subtitleLabel.shadowOffset = CGSizeMake(1, 1);
    subtitleLabel.backgroundColor = style.backgroundColor ? style.backgroundColor : [UIColor clearColor];
}

- (void)setupSubtitleTopLabel:(UILabel *)subtitleTopLabel style:(PLVVodSubtitleItemStyle *)style {
    subtitleTopLabel.text = @"";
    subtitleTopLabel.numberOfLines = 0;
    subtitleTopLabel.contentMode = UIViewContentModeBottom;
    subtitleTopLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    subtitleTopLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    subtitleTopLabel.shadowOffset = CGSizeMake(1, 1);
    subtitleTopLabel.backgroundColor = style.backgroundColor ? style.backgroundColor : [UIColor clearColor];
}

- (void)setupSubtitleLabel2:(UILabel *)subtitleLabel style:(PLVVodSubtitleItemStyle *)style {
    subtitleLabel.text = @"";
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.contentMode = UIViewContentModeBottom;
    subtitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    subtitleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    subtitleLabel.shadowOffset = CGSizeMake(1, 1);
    subtitleLabel.backgroundColor = style.backgroundColor ? style.backgroundColor : [UIColor clearColor];
}

- (void)setupSubtitleTopLabel2:(UILabel *)subtitleTopLabel style:(PLVVodSubtitleItemStyle *)style {
    subtitleTopLabel.text = @"";
    subtitleTopLabel.numberOfLines = 0;
    subtitleTopLabel.contentMode = UIViewContentModeBottom;
    subtitleTopLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    subtitleTopLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    subtitleTopLabel.shadowOffset = CGSizeMake(1, 1);
    subtitleTopLabel.backgroundColor = style.backgroundColor ? style.backgroundColor : [UIColor clearColor];
}

- (void)subtitleItemDidChange:(PLVVodSubtitleItem *)subtitleItem {
	//NSLog(@"%@", subtitleItem);
	[UIView transitionWithView:self.subtitleLabel duration:PLVVodSubtitleAnimationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		self.subtitleLabel.attributedText = [self subtitleItem:subtitleItem style:self.subtitleItemStyle];
	} completion:^(BOOL finished) {
		
	}];
}

- (void)subtitleItemAtTopDidChange:(PLVVodSubtitleItem *)subtitleItem {
    //NSLog(@"%@", subtitleItem);
    [UIView transitionWithView:self.subtitleTopLabel duration:PLVVodSubtitleAnimationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.subtitleTopLabel.attributedText = [self subtitleItem:subtitleItem style:self.subtitleAtTopItemStyle];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)subtitleItem2DidChange:(PLVVodSubtitleItem *)subtitleItem {
    //NSLog(@"%@", subtitleItem);
    [UIView transitionWithView:self.subtitleLabel2 duration:PLVVodSubtitleAnimationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.subtitleLabel2.attributedText = [self subtitleItem:subtitleItem style:self.subtitleItemStyle2];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)subtitleItem2AtTopDidChange:(PLVVodSubtitleItem *)subtitleItem {
    //NSLog(@"%@", subtitleItem);
    [UIView transitionWithView:self.subtitleTopLabel2 duration:PLVVodSubtitleAnimationDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.subtitleTopLabel2.attributedText = [self subtitleItem:subtitleItem style:self.subtitleAtTopItemStyle2];
    } completion:^(BOOL finished) {
        
    }];
}

- (NSAttributedString *)subtitleItem:(PLVVodSubtitleItem *)subtitleItem style:(PLVVodSubtitleItemStyle *)style {
    if (!subtitleItem.attributedText) {
        return nil;
    }
    
    // 获取原始文本内容
    NSString *originalText = subtitleItem.attributedText.string;
    
    // 确定字体和颜色
    UIFont *font;
    UIColor *textColor;
    
    if (style && [style isKindOfClass:[PLVVodSubtitleItemStyle class]]) {
        textColor = style.textColor ?: [UIColor whiteColor];
        if (style.bold) {
            font = [UIFont fontWithName:@"PingFangSC-SemiBold" size:20];
        } else {
            font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        }
    } else {
        // 从原始attributedText中提取字体和颜色
        NSRange range = NSMakeRange(0, subtitleItem.attributedText.length);
        font = [subtitleItem.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:&range] ?: [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        textColor = [subtitleItem.attributedText attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range] ?: [UIColor whiteColor];
    }
    
    // 使用LaTeX助手处理文本
    NSAttributedString *processedText = [PLVVodSubtitleLaTeXHelper attributedStringWithText:originalText
                                                                                       font:font
                                                                                  textColor:textColor
                                                                               mathFontSize:font.pointSize
                                                                                  mathColor:textColor];
    
    // 如果支持LaTeX且样式需要倾斜，应用倾斜效果
    if ([PLVVodSubtitleLaTeXHelper isLaTeXSupported] && style && style.italic) {
        NSMutableAttributedString *mutableText = [[NSMutableAttributedString alloc] initWithAttributedString:processedText];
        [mutableText addAttribute:NSObliquenessAttributeName value:@(15 * M_PI / 180) range:NSMakeRange(0, mutableText.length)];
        return [mutableText copy];
    }
    
    return processedText;
}

@end
