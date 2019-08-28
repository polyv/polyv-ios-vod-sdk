//
//  PLVUploadCell.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/6/12.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVUploadCell.h"

@implementation PLVUploadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _videoIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plv_icon_video_placeholder"]];
        [self.contentView addSubview:_videoIconImageView];
        
        _videoTitleLabel = [[UILabel alloc] init];
        _videoTitleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_videoTitleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat rowHeight = self.contentView.frame.size.height;
    _videoIconImageView.frame = CGRectMake(15, (rowHeight - 40)/2.0, 40, 40);
}

- (void)setCellModel:(PLVUploadModel *)model {
}

@end
