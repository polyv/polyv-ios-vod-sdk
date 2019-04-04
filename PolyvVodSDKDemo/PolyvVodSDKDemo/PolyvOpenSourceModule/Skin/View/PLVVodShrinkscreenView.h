//
//  PLVVodShrinkscreenView.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodConstans.h>

@interface PLVVodShrinkscreenView : UIView

@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressView;
@property (weak, nonatomic) IBOutlet UISlider *playbackSlider;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchScreenButton;

//音视频切换
@property (weak, nonatomic) IBOutlet UIView *playModeContainerView;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayModeButton;
@property (weak, nonatomic) IBOutlet UIButton *audioPlayModeButton;

@property (weak, nonatomic) IBOutlet UIButton *definitionButton;
@property (weak, nonatomic) IBOutlet UIButton *playbackRateButton;
@property (weak, nonatomic) IBOutlet UIButton *routeButton; // 线路切换

@property (nonatomic, assign) BOOL isShowRouteline; // 显示线路
@property (nonatomic, assign) BOOL isShowRate;      // 显示速率
@property (nonatomic, assign) BOOL isShowQuality;   // 显示清晰度

@property (nonatomic, assign) BOOL enableQualityBtn;   // 清晰度按钮是否响应事件

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode;

@end
