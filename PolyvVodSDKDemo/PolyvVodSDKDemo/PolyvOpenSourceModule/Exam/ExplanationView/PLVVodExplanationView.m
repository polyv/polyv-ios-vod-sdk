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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews{
    [self updateOuterContainerSize];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.explanationTextView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    
    self.containerWithoutExplanation.layer.cornerRadius = 8;
    self.containerWithoutExplanation.layer.masksToBounds = YES;
    
    self.alpha = 0;
    
    [self commonInit];
}

- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    [self updateOuterContainerSize];
}

#pragma mark - property

- (void)setExplanation:(NSString *)explanation correct:(BOOL)correct {
    
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
    
    float width = self.superview.bounds.size.width;
    float height = self.superview.bounds.size.height;
    
    if (height == 0 || width == 0) {
        self.alpha = 0;
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
        }];
    }
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) { // 竖屏
        
        if (width >= height) {
            self.outerContainerTopConstraint.constant = 0;
            self.outerContainerBottomConstraint.constant = 0;
        }else{
            CGFloat contanerHeight = width / (16.0 / 9.0);
            CGFloat topBottomPadding = (height - contanerHeight) / 2.0;
            
            self.outerContainerTopConstraint.constant = topBottomPadding;
            self.outerContainerBottomConstraint.constant = topBottomPadding;
        }
        
        self.outerContainerLeadingConstraint.constant = 0;
        self.outerContainerTailingConstraint.constant = 0;
        
    } else { // 横屏
        CGFloat verticalPadding = 60;
        CGFloat horzontalPadding;
        
        CGFloat scale = verticalPadding / 375.0;
        verticalPadding = scale * height;
        
        CGFloat outerContanerHeight = height - verticalPadding * 2;
        NSLog(@"outerContanerHeight = %f", outerContanerHeight);
        CGFloat outerContanerWeidht = outerContanerHeight / 9.0 * 16;
        
        horzontalPadding = (width - outerContanerWeidht) / 2.0 ;
        
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
