//
//  PLVVideoCell.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/11/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVideoCell.h"
#import "PLVCourseVideo.h"
#import "PLVVodAccountVideo.h"
#import <YYWebImage/YYWebImage.h>
#import "UIControl+PLVVod.h"

@interface PLVVideoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;

@end

@implementation PLVVideoCell

+ (NSString *)timeStringWithSeconds:(NSTimeInterval)seconds {
	NSInteger time = seconds;
	NSInteger _hours = time / 60 / 60;
	NSInteger _minutes = (time / 60) % 60;
	NSInteger _seconds = time % 60;
	NSString *timeString = _hours > 0 ? [NSString stringWithFormat:@"%02zd:", _hours] : @"";
	timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%02zd:%02zd", _minutes, _seconds]];
	return timeString;
}

- (void)setVideo:(id)video {
	_video = video;
	if ([video isKindOfClass:[PLVCourseVideo class]]) {
		PLVCourseVideo *courseVideo = video;
		self.titleLabel.text = courseVideo.title;
		self.durationLabel.text = [self.class timeStringWithSeconds:courseVideo.duration];
		__weak typeof(self) weakSelf = self;
		[courseVideo requestVodVideoWithCompletion:^(PLVVodVideo *vodVideo) {
			[weakSelf.coverImageView yy_setImageWithURL:[NSURL URLWithString:vodVideo.snapshot] placeholder:[UIImage imageNamed:@"plv_ph_courseCover"]];
		}];
	} else if ([video isKindOfClass:[PLVVodAccountVideo class]]) {
		PLVVodAccountVideo *accountVideo = video;
		[self.coverImageView yy_setImageWithURL:[NSURL URLWithString:accountVideo.snapshot] placeholder:[UIImage imageNamed:@"plv_ph_courseCover"]];
		self.titleLabel.text = accountVideo.title;
		self.durationLabel.text = [self.class timeStringWithSeconds:accountVideo.duration];
	}
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
	self.playButton.acceptEventInterval = 2;
	[self.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)playButtonAction:(UIButton *)sender {
	if (self.playButtonAction) self.playButtonAction(self, sender);
}
- (void)downloadButtonAction:(UIButton *)sender {
	if (self.downloadButtonAction) self.downloadButtonAction(self, sender);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)identifier {
	return NSStringFromClass([self class]);
}

@end
