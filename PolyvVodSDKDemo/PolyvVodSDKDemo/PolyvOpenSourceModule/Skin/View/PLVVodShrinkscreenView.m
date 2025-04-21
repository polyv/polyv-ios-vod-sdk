//
//  PLVVodShrinkscreenView.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodShrinkscreenView.h"

@interface PLVVodShrinkscreenView ()

@property (weak, nonatomic) IBOutlet UIImageView *videoModeSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoModeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *audioModeSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *audioModeLabel;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (weak, nonatomic) IBOutlet UIStackView *rightToolStackView;

// 是否显示 ppt 相关按钮，默认 NO，需要设为 YES 调用方法 "-enablePPTMode:"
@property (nonatomic, assign) BOOL supportPPT;

#pragma clang diagnostic pop

@end

@implementation PLVVodShrinkscreenView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self initUIControl];
}

- (void)initUIControl{
    // 默认隐藏清晰度
    self.isShowQuality = NO;
    self.definitionButton.hidden = !self.isShowQuality;

    // 默认隐藏播放速率
    self.isShowRate = NO;
    self.playbackRateButton.hidden = !self.isShowRate;

    //  默认打开线路切换
    self.isShowRouteline = YES;
    self.routeButton.hidden = !self.isShowRouteline;
    // 重置线路按钮
    [self.routeButton setTitle:@"" forState:UIControlStateNormal];
    [self.routeButton setBackgroundImage:[UIImage imageNamed:@"plv_vod_btn_line"] forState:UIControlStateNormal];
    
    // 添加热力图控件
    [self insertSubview:self.heatMapView atIndex:0];
    
    // 添加自定义打点标签
    [self insertSubview:self.progressMarkerView aboveSubview:self.heatMapView];
}

- (void)layoutSubviews{
    
    // 客户可以具体需求，调整布局
    if (self.frame.size.width <= PLV_Min_ScreenWidth){
        self.rightToolStackView.spacing = 10;
    }
    else{
        self.rightToolStackView.spacing = 15;
    }
    
    // 热力图布局
    CGFloat heatMap_H = 50;
    self.heatMapView.frame = CGRectMake(0,self.bounds.size.height - 54 -heatMap_H, self.bounds.size.width, heatMap_H);
    // 自定义打点标签布局
    CGFloat markView_H = 35;
    self.progressMarkerView.frame = CGRectMake(0,self.bounds.size.height - 54 -markView_H, self.bounds.size.width, markView_H);
}

- (PLVVodHeatMapView *)heatMapView{
    if (!_heatMapView){
        _heatMapView = [[PLVVodHeatMapView alloc] init];
    }
    
    return _heatMapView;
}

- (PLVVodProgressMarkerView *)progressMarkerView{
    if (!_progressMarkerView){
        _progressMarkerView = [[PLVVodProgressMarkerView alloc] init];
    }
    
    return _progressMarkerView;
}

#pragma mark button action

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode {
    if (mode == PLVVodPlaybackModeAudio) {
        self.videoModeSelectedImageView.hidden = YES;
        self.videoModeLabel.highlighted = NO;
        self.audioModeSelectedImageView.hidden = NO;
        self.audioModeLabel.highlighted = YES;
    } else {
        self.videoModeSelectedImageView.hidden = NO;
        self.videoModeLabel.highlighted = YES;
        self.audioModeSelectedImageView.hidden = YES;
        self.audioModeLabel.highlighted = NO;
    }
    [self enablePPTMode:_supportPPT];
}

- (void)enablePPTMode:(BOOL)enable {
    _supportPPT = enable;
    self.subScreenButton.hidden = !_supportPPT;
}

- (void)enableFloating:(BOOL)enable {
    self.floatingButton.hidden = !enable;
}

- (void)setEnableQualityBtn:(BOOL)enableQualityBtn{
    self.definitionButton.enabled = enableQualityBtn;
    if (enableQualityBtn){
        self.definitionButton.alpha = 1.0;
    }
    else{
        self.definitionButton.alpha = 0.5;
    }
}

#pragma mark PLVVodProgressMarkerViewDelegate
- (void)progressMarkerView:(PLVVodProgressMarkerView *)progressMarkerView clickItem:(PLVVodMarkerViewData *)viewData{
    
}

- (NSString *)description {
	NSMutableString *description = [super.description stringByAppendingString:@":\n"].mutableCopy;
	[description appendFormat:@" playPauseButton: %@;\n", _playPauseButton];
	return description;
}

@end
