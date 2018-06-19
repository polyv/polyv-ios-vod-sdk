//
//  PLVVodExplanationView.m
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodExplanationView.h"
#import "UIColor+PLVVod.h"

@interface PLVVodExplanationView ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerTailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerContainerBottomConstraint;

@property (weak, nonatomic) IBOutlet UITextView *explanationTextView;

@property (weak, nonatomic) IBOutlet UIView *containerWithExplanation;

@property (weak, nonatomic) IBOutlet UIView *containerWithoutExplanation;
@property (weak, nonatomic) IBOutlet UIImageView *answerCorrectImage;
@property (weak, nonatomic) IBOutlet UILabel *answerCorrectLabel;

@property (nonatomic, assign) BOOL correct;

@end

@implementation PLVVodExplanationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.explanationTextView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    
    self.containerWithoutExplanation.layer.cornerRadius = 8;
    self.containerWithoutExplanation.layer.masksToBounds = YES;
}

#pragma mark - property

- (void)setExplanation:(NSString *)explanation correct:(BOOL)correct {
    [self updateOuterContainerSize];
    
	self.correct = correct;
    
    if (explanation.length > 0) {
        self.containerWithExplanation.hidden = NO;
        self.containerWithoutExplanation.hidden = YES;
        
        NSMutableParagraphStyle *titleParagraphStyle = [NSMutableParagraphStyle defaultParagraphStyle].mutableCopy;
        titleParagraphStyle.alignment = NSTextAlignmentCenter;
        
        NSString *titleString = correct ? @"\n回答正确\n\n" : @"\n回答错误\n\n";
        UIColor *titleColor  = correct ? [UIColor colorWithHex:0x6FAB32] : [UIColor colorWithHex:0xF95652];
        NSDictionary *titleAttributes =
        @{
          NSFontAttributeName: [UIFont systemFontOfSize:17],
          NSForegroundColorAttributeName: titleColor,
          NSParagraphStyleAttributeName: titleParagraphStyle
          };
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:titleString attributes:titleAttributes];
        
        NSDictionary *contentAttributes =
        @{
          NSFontAttributeName: [UIFont systemFontOfSize:14],
          NSForegroundColorAttributeName: [UIColor colorWithHex:0x455A64]
          };
        NSAttributedString *content = [[NSAttributedString alloc] initWithString:explanation attributes:contentAttributes];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
        [attributedText appendAttributedString:title];
        [attributedText appendAttributedString:content];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.explanationTextView.attributedText = attributedText;
        });
    } else {
        self.containerWithExplanation.hidden = YES;
        self.containerWithoutExplanation.hidden = NO;
        
        NSString *imageString = correct ? @"plv_vod_ic_answer_right.png" : @"plv_vod_ic_answer_wrong.png";
        [self.answerCorrectImage setImage:[UIImage imageNamed:imageString]];
        
        NSString *labelString = correct ? @"回答正确" : @"回答错误";
        [self.answerCorrectLabel setText:labelString];
        
        UIColor *labelColor  = correct ? [UIColor colorWithHex:0x6FAB32] : [UIColor colorWithHex:0xF95652];
        [self.answerCorrectLabel setTextColor:labelColor];
        
        [self performSelector:@selector(disappear) withObject:nil afterDelay:3];
    }
}

- (void)updateOuterContainerSize {
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        self.outerContainerLeadingConstraint.constant = 0;
        self.outerContainerTailingConstraint.constant = 0;
        self.outerContainerTopConstraint.constant = 0;
        self.outerContainerBottomConstraint.constant = 0;
    } else {
        CGFloat verticalPadding = 60;
        CGFloat horzontalPadding;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        CGFloat outerContanerHeight = screenHeight - 60 * 2;
        CGFloat outerContanerWeidht = outerContanerHeight / 9 * 16;
        
        horzontalPadding = (screenWidth - outerContanerWeidht) / 2;
        
        self.outerContainerLeadingConstraint.constant = horzontalPadding;
        self.outerContainerTailingConstraint.constant = horzontalPadding;
        self.outerContainerTopConstraint.constant = verticalPadding;
        self.outerContainerBottomConstraint.constant = verticalPadding;
    }
}

#pragma mark - action

- (IBAction)confirmButtonAction:(UIBarButtonItem *)sender {
    [self disappear];
}

#pragma mark - public mehtod

- (void)scrollToTop {
	[self.explanationTextView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - private method
- (void)disappear {
    if (self.confirmActionHandler) self.confirmActionHandler(self.correct);
}

@end
