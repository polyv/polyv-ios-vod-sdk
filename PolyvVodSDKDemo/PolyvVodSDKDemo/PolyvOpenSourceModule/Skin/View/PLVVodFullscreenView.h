//
//  PLVVodFullscreenView.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PLVVodSDK/PLVVodConstans.h>

@interface PLVVodFullscreenView : UIView

@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressView;
@property (weak, nonatomic) IBOutlet UISlider *playbackSlider;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *switchScreenButton;
@property (weak, nonatomic) IBOutlet UIButton *snapshotButton;
@property (weak, nonatomic) IBOutlet UIButton *danmuSendButton;
@property (weak, nonatomic) IBOutlet UIButton *definitionButton;
@property (weak, nonatomic) IBOutlet UIButton *playbackRateButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *danmuButton;

//音视频切换
@property (weak, nonatomic) IBOutlet UIView *playModeContainerView;
@property (weak, nonatomic) IBOutlet UIButton *videoPlayModeButton;
@property (weak, nonatomic) IBOutlet UIButton *audioPlayModeButton;

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode;

@end
