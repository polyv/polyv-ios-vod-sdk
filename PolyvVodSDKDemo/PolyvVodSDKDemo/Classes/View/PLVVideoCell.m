//
//  PLVVideoCell.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVideoCell.h"
#import <YYWebImage/YYWebImage.h>

@interface PLVVideoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation PLVVideoCell

+ (NSString *)timeStringWithSeconds:(NSTimeInterval)seconds {
	NSInteger time = seconds;
	NSInteger _hours = time / 60 / 60;
	NSInteger _minutes = (time / 60) % 60;
	NSInteger _seconds = time % 60;
	NSString *timeString = _hours > 0 ? [NSString stringWithFormat:@"%02zd", _hours] : @"";
	timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%02zd:%02zd", _minutes, _seconds]];
	return timeString;
}

- (void)setVideo:(PLVCourseVideo *)video {
	_video = video;
	[self.coverImageView yy_setImageWithURL:[NSURL URLWithString:video.cover] placeholder:[UIImage imageNamed:@"plv_ph_courseCover"]];
	self.titleLabel.text = video.title;
	self.durationLabel.text = [self.class timeStringWithSeconds:video.duration];
}

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
