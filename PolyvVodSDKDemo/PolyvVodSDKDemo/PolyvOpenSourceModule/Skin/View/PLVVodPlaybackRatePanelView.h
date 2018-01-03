//
//  PLVVodPlaybackRatePanelView.h
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/26.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVVodPlaybackRatePanelView : UIView

@property (nonatomic, copy) void (^selectedPlaybackRateDidChangeBlock)(double playbackRate);
@property (nonatomic, copy) void (^playbackRateButtonDidClick)(UIButton *sender);

@end
