//
//  PLVVodSettingPanelView.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/28.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodConstans.h>

@interface PLVVodSettingPanelView : UIView
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@property (nonatomic, strong) NSArray<NSString *> *subtitleKeys;
@property (nonatomic, copy) NSString *selectedSubtitleKey;
@property (nonatomic, copy) void (^selectedSubtitleKeyDidChangeBlock)(NSString *selectedSubtitleKey);

@property (nonatomic, assign) NSInteger scalingMode;
@property (nonatomic, copy) void (^scalingModeDidChangeBlock)(NSInteger scalingMode);

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode;

@end
