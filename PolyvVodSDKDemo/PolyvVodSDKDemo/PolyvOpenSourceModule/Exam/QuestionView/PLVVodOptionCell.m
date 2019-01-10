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
}

- (void)setText:(NSString *)text {
	self.optionLabel.text = text;
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

+ (CGFloat)calculateCellWithHeight:(NSString *)s andWidth:(CGFloat)width {
    CGFloat labelWidth = width - (86 - 54);
    CGRect rect = [s boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:13] }
                                  context:nil];
    CGFloat height = ceil(rect.size.height) + 4;
    
    CGFloat minHeight = 22;
    if (height < minHeight) {
        height = minHeight;
    }

    return height;
}

@end
