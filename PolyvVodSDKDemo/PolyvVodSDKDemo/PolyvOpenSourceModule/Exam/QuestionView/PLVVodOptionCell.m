//
//  PLVVodOptionCell.m
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/12/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodOptionCell.h"

@interface PLVVodOptionCell ()

@property (weak, nonatomic) IBOutlet UIButton *checkboxButton;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel;

@end

@implementation PLVVodOptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (IBAction)checkboxButtonAction:(UIButton *)sender {
//	sender.selected = !sender.selected;
//}

- (void)setText:(NSString *)text {
	self.optionLabel.text = text;
//	NSAttributedString *_attributedText = self.optionLabel.attributedText;
//	NSRange range = NSMakeRange(0, 1);
//	NSDictionary *attribute = [_attributedText attributesAtIndex:0 effectiveRange:&range];
//	NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attribute];
//	self.optionLabel.attributedText = attributedText;
}
- (NSString *)text {
	return self.optionLabel.text;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	self.checkboxButton.selected = selected;
}

+ (NSString *)identifier {
	return NSStringFromClass([self class]);
}

@end
