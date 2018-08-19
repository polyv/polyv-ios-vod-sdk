//
//  PLVDownloadProcessingCell.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/7/24.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVDownloadProcessingCell.h"
#import <YYWebImage/YYWebImage.h>

@implementation PLVDownloadProcessingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.thumbnailView.clipsToBounds = YES;
    self.thumbnailView.layer.cornerRadius = 5.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setThumbnailUrl:(NSString *)thumbnailUrl {
    _thumbnailUrl = thumbnailUrl;
    [self.thumbnailView yy_setImageWithURL:[NSURL URLWithString:thumbnailUrl] placeholder:[UIImage imageNamed:@"plv_ph_courseCover"]];
}

+ (NSString *)identifier{
    
    return NSStringFromClass([self class]);
}

@end
