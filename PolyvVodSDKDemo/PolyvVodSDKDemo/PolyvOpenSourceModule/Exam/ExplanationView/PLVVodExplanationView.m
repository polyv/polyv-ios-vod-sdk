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

@property (weak, nonatomic) IBOutlet UITextView *explanationTextView;

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
}

#pragma mark - property

- (void)setExplanation:(NSString *)explanation correct:(BOOL)correct {
	self.correct = correct;
	NSMutableParagraphStyle *titleParagraphStyle = [NSMutableParagraphStyle defaultParagraphStyle].mutableCopy;
	titleParagraphStyle.alignment = NSTextAlignmentCenter;
	NSDictionary *titleAttributes =
	@{
	  NSFontAttributeName: [UIFont systemFontOfSize:17],
	  NSForegroundColorAttributeName: [UIColor colorWithHex:0x6FAB32],
	  NSParagraphStyleAttributeName: titleParagraphStyle
	  };
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"回答错误\n\n" attributes:titleAttributes];
	if (correct) {
		title = [[NSAttributedString alloc] initWithString:@"回答正确\n\n" attributes:titleAttributes];
	}
	
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
}

#pragma mark - action

- (IBAction)confirmButtonAction:(UIBarButtonItem *)sender {
	if (self.confirmActionHandler) self.confirmActionHandler(self.correct);
}

#pragma mark - public mehtod

- (void)scrollToTop {
	[self.explanationTextView setContentOffset:CGPointZero animated:YES];
}

@end
