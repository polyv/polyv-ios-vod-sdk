//
//  PLVVodGestureIndicatorView.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodGestureIndicatorView.h"

@interface PLVVodGestureIndicatorView ()

@property (weak, nonatomic) IBOutlet UIImageView *indicatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *indicatorLabel;

@end

@implementation PLVVodGestureIndicatorView

#pragma mark - property

- (void)setType:(PLVVodGestureIndicatorType)type {
	_type = type;
	UIImage *image = nil;
	switch (type) {
		case PLVVodGestureIndicatorTypeBrightness:{
			image = [UIImage imageNamed:@"plv_vod_ic_brightness"];
		}break;
		case PLVVodGestureIndicatorTypeVolume:{
			image = [UIImage imageNamed:@"plv_vod_ic_volume"];
		}break;
		case PLVVodGestureIndicatorTypeVolumeOff:{
			image = [UIImage imageNamed:@"plv_vod_ic_volume_non"];
		}break;
		case PLVVodGestureIndicatorTypeProgressUp:{
			image = [UIImage imageNamed:@"plv_vod_ic_forward"];
		}break;
		case PLVVodGestureIndicatorTypeProgressDown:{
			image = [UIImage imageNamed:@"plv_vod_ic_rewind"];
		}break;
		default:{}break;
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		self.indicatorImageView.image = image;
	});
}

- (void)setText:(NSString *)text {
	_text = text;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.indicatorLabel.text = text;
	});
}

@end
