//
//  PLVLoadCell.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVLoadCell.h"
#import <YYWebImage/YYWebImage.h>

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
			[UIView animateWithDuration:.5 animations:^{
				self.downloadButton.alpha = 1;
			}];
		}break;
		case PLVLoadCellStateCompleted:{
			[UIView animateWithDuration:.5 animations:^{
				self.downloadButton.alpha = 0;
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
