//
//  PLVVodQuestionReusableView.m
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodQuestionReusableView.h"

@interface PLVVodQuestionReusableView ()

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;

@end

@implementation PLVVodQuestionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
	
}

- (void)setText:(NSString *)text {
	self.questionLabel.text = text;
//	NSAttributedString *_attributedText = self.questionLabel.attributedText;
//	NSRange range = NSMakeRange(0, 1);
//	NSDictionary *attribute = [_attributedText attributesAtIndex:0 effectiveRange:&range];
//	NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attribute];
//	self.questionLabel.attributedText = attributedText;
}
- (NSString *)text {
	return self.questionLabel.text;
}

+ (NSString *)identifier {
	return NSStringFromClass([self class]);
}

+ (CGFloat)preferredHeightWithText:(NSString *)text inSize:(CGSize)maxSize {
	CGSize textSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} context:nil].size;
	return textSize.height;
}

@end
