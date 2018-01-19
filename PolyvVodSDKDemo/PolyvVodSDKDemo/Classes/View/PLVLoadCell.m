//
//  PLVLoadCell.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVLoadCell.h"
#import <YYWebImage/YYWebImage.h>

@interface PLVLoadCell ()

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (weak, nonatomic) IBOutlet UIStackView *downloadProcessStackView;

#pragma clang diagnostic pop

@end

@implementation PLVLoadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
	[self.downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setThumbnailUrl:(NSString *)thumbnailUrl {
	_thumbnailUrl = thumbnailUrl;
	[self.thumbnailView yy_setImageWithURL:[NSURL URLWithString:thumbnailUrl] placeholder:[UIImage imageNamed:@"plv_ph_courseCover"]];
}

- (void)setState:(PLVLoadCellState)state {
	_state = state;
	switch (state) {
		case PLVLoadCellStateProcessing:{
			self.downloadProcessStackView.hidden = NO;
			[UIView animateWithDuration:.5 animations:^{
				self.downloadButton.alpha = 1;
				self.downloadProcessStackView.alpha = 1;
			}];
		}break;
		case PLVLoadCellStateCompleted:{
			[UIView animateWithDuration:.5 animations:^{
				self.downloadButton.alpha = 0;
				self.downloadProcessStackView.alpha = 0;
			} completion:^(BOOL finished) {
				self.downloadProcessStackView.hidden = YES;
			}];
		}break;
		default:{}break;
	}
}

- (void)downloadButtonAction:(UIButton *)sender {
	if (self.downloadButtonAction) self.downloadButtonAction(self, sender);
}

+ (NSString *)identifier {
	return NSStringFromClass([self class]);
}

@end
