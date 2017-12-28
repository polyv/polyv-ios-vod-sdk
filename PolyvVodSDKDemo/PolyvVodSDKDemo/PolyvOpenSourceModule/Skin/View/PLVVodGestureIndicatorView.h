//
//  PLVVodGestureIndicatorView.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PLVVodGestureIndicatorType) {
	PLVVodGestureIndicatorTypeBrightness,
	PLVVodGestureIndicatorTypeVolume,
	PLVVodGestureIndicatorTypeVolumeOff,
	PLVVodGestureIndicatorTypeProgressUp,
	PLVVodGestureIndicatorTypeProgressDown
};

@interface PLVVodGestureIndicatorView : UIView

@property (nonatomic, assign) PLVVodGestureIndicatorType type;
@property (nonatomic, copy) NSString *text;

@end
