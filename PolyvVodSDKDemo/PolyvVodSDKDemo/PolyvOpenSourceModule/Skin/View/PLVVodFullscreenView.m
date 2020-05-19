//
//  PLVVodFullscreenView.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/27.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodFullscreenView.h"
#import "PLVVodPlayTipsView.h"

#import <PLVMasonry/PLVMasonry.h>
#if __has_include(<FDStackView/FDStackView.h>)
#import <FDStackView/FDStackView.h>
#else
#import "FDStackView.h"
#endif

@interface PLVVodFullscreenView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarHeight;

@property (weak, nonatomic) IBOutlet UIImageView *videoModeSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoModeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *audioModeSelectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *audioModeLabel;

@property (strong, nonatomic) PLVVodPlayTipsView *playTipsView;
@property (strong, nonatomic) NSArray<PLVVodVideoKeyFrameItem *> *videoTips;
@property (assign, nonatomic) NSInteger videoDuration;  // 视频时长

// 是否显示 ppt 相关按钮，默认 NO，需要设为 YES 调用方法 "-enablePPTMode:"
@property (nonatomic, assign) BOOL supportPPT;

@end

@implementation PLVVodFullscreenView

- (void)awakeFromNib {
	[super awakeFromNib];
    
	if ([UIDevice currentDevice].systemVersion.integerValue < 11) {
		self.statusBarHeight.constant = 12;
	}
    
    
    // 添加点击后的展示视图
    [self addSubview:self.playTipsView];
}

#pragma mark -- getter
- (PLVVodPlayTipsView *)playTipsView{
    if (!_playTipsView){
        _playTipsView = [[PLVVodPlayTipsView alloc] init];
        [_playTipsView.playBtn addTarget:self action:@selector(tipsViewPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _playTipsView.hidden = YES;
    }
    
    return _playTipsView;
}

#pragma mark -- action target
- (void)tipsViewPlayBtnClick:(UIButton *)btn{
    //
    if (self.plvVideoTipsSelectedBlock){
        self.plvVideoTipsSelectedBlock(btn.tag);
    }
}

#pragma mark -- public

- (void)switchToPlayMode:(PLVVodPlaybackMode)mode {
    if (mode == PLVVodPlaybackModeAudio) {
        self.videoModeSelectedImageView.hidden = YES;
        self.videoModeLabel.highlighted = NO;
        self.audioModeSelectedImageView.hidden = NO;
        self.audioModeLabel.highlighted = YES;
        
        self.definitionButton.hidden = YES;
        self.snapshotButton.hidden = YES;
    } else {
        self.videoModeSelectedImageView.hidden = NO;
        self.videoModeLabel.highlighted = YES;
        self.audioModeSelectedImageView.hidden = YES;
        self.audioModeLabel.highlighted = NO;
        
        self.definitionButton.hidden = NO;
        self.snapshotButton.hidden = NO;
    }
    [self enablePPTMode:_supportPPT];
}

- (void)enablePPTMode:(BOOL)enable {
    _supportPPT = enable;
    self.subScreenButton.hidden = !_supportPPT;
    self.pptCatalogButton.hidden = !_supportPPT;
}

- (void)enableFloating:(BOOL)enable {
    self.floatingButton.hidden = !enable;
}

- (void)addPlayTipsWithVideo:(PLVVodVideo *)video{
    [self.sliderBackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]){
            [obj removeFromSuperview];
        }
    }];
    
    //
    if (!video.videokeyframes.count) return;
    
    self.videoTips = [NSArray arrayWithArray:video.videokeyframes];
    self.videoDuration = video.duration;
    
    //
    NSUInteger framesCount = video.videokeyframes.count;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    for (int i=0; i< framesCount; i++){
        UIView *radioView = [[UIView alloc] init];
        radioView.userInteractionEnabled = NO;
        radioView.backgroundColor = [UIColor whiteColor];
        radioView.layer.cornerRadius = 4.0;
        radioView.tag = i;
        [self.sliderBackView addSubview:radioView];
        
        PLVVodVideoKeyFrameItem *item = [video.videokeyframes objectAtIndex:i];
        float full_width = screenSize.width > screenSize.height ? screenSize.width: screenSize.height;
        NSUInteger offset_x = full_width *([item.keytime integerValue]/ video.duration);
        [radioView plv_makeConstraints:^(PLVMASConstraintMaker *make) {
            make.size.plv_equalTo(CGSizeMake(8, 8));
            make.centerY.offset (0);
            make.left.offset (offset_x);
        }];
    }
}

- (void)showPlayTipsWithIndex:(NSUInteger)index{
    //
    self.playTipsView.hidden = NO;
    
    // 显示打点信息
    PLVVodVideoKeyFrameItem *item = [self.videoTips objectAtIndex:index];
    self.playTipsView.playBtn.tag = index;
    NSString *showText = @"";
    if ([item.hours integerValue] > 0){
        showText = [[NSString alloc] initWithFormat:@"%2ld:%2ld:%2ld", (long)[item.hours integerValue] , (long)[item.minutes integerValue], (long)[item.seconds integerValue]];
    }
    else{
        showText = [[NSString alloc] initWithFormat:@"%2ld:%2ld", (long)[item.minutes integerValue], (long)[item.seconds integerValue]];
    }
    
    showText = [NSString stringWithFormat:@"%@  %@", showText, item.keycontext];
    self.playTipsView.showDescribe.text = showText;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float full_width = screenSize.width > screenSize.height ? screenSize.width: screenSize.height;
    float textMaxWidth = full_width - 100;
    CGRect textRect = [showText boundingRectWithSize:CGSizeMake(0, 40)
                                             options:NSStringDrawingUsesFontLeading| NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                             context:nil];
    float textWidth = (textRect.size.width + 60) > textMaxWidth ? textMaxWidth: (textRect.size.width + 60);
    float showWidth = textWidth ;
    
    // 打点坐标
    NSUInteger offset_x = full_width *([item.keytime floatValue]/ self.videoDuration);
    if (showWidth/2 - offset_x > 0){
        // 居左展示
        [self.playTipsView plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
            make.left.offset (45);
            make.bottom.equalTo (self.sliderBackView.plv_top).offset (-10);
            make.height.plv_equalTo(35);
            make.width.plv_equalTo (showWidth);
        }];
    }
    else if (showWidth/2 > (full_width - offset_x)){
        // 居右边展示
        [self.playTipsView plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
            make.right.offset (-45);
            make.bottom.equalTo (self.sliderBackView.plv_top).offset (-10);
            make.height.plv_equalTo(35);
            make.width.plv_equalTo (showWidth);

        }];
    }else{
        // 居中展示
        [self.playTipsView plv_remakeConstraints:^(PLVMASConstraintMaker *make) {
            make.left.offset (offset_x - showWidth/2);
            make.bottom.equalTo (self.sliderBackView.plv_top).offset (-10);
            make.height.plv_equalTo(35);
            make.width.plv_equalTo (showWidth);

        }];
    }
}

- (void)hidePlayTipsView{
    self.playTipsView.hidden = YES;
}

// 清晰度按钮是否响应事件
- (void)setEnableQualityBtn:(BOOL)enableQualityBtn{
    self.definitionButton.enabled = enableQualityBtn;
    if (enableQualityBtn){
        self.definitionButton.alpha = 1.0;
    }
    else{
        self.definitionButton.alpha = 0.5;
    }
}

- (NSString *)description {
	NSMutableString *description = [super.description stringByAppendingString:@":\n"].mutableCopy;
	[description appendFormat:@" playPauseButton: %@;\n", _playPauseButton];
	return description;
}

@end
