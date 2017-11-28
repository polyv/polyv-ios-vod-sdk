//
//  PLVDownloadCell.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVDownloadCell.h"

@implementation PLVDownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
	self.backgroundColor = [UIColor colorWithHue:0.636 saturation:0.045 brightness:0.957 alpha:1.000];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
