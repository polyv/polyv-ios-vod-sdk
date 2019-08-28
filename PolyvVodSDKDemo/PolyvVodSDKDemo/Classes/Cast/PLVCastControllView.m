//
//  PLVCastControllView.m
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2018/12/12.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import "PLVCastControllView.h"

@interface PLVCastQualityView : UIView

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (nonatomic, strong) UIStackView * stackV;

// 清晰度数量
@property (nonatomic, assign) NSInteger qualityCount;

// 选择的清晰度
@property (nonatomic, assign) NSInteger qualityIdx;

// 当前的清晰度
@property (nonatomic, copy, readonly) NSString * currentQueality;

@property (nonatomic, copy) void (^qualityDidChangeBlock) (NSInteger qualityIdx, UIButton * button);

- (void)show;

- (void)hide;

@end


@interface PLVCastControllView ()


@property (nonatomic, strong) UIImageView * deviceBgImgV;

@property (nonatomic, strong) UILabel * deviceNameLb;
@property (nonatomic, strong) UILabel * stateLb;

@property (nonatomic, strong) UIButton * volumeAddBtn;
@property (nonatomic, strong) UIButton * volumeMinusBtn;

@property (nonatomic, strong) UIView * controllBgV;
@property (nonatomic, weak) UIButton * qualityChangeBtn;

@property (nonatomic, strong) NSArray <NSString *>* controllBtnStrArr;

@property (nonatomic, strong) UIButton * backBtn;

// 播放控制区域
@property (nonatomic, strong) UISlider * timeSld;

@property (nonatomic, strong) UIView * bottomControllV;
@property (nonatomic, strong, readwrite) UIButton * playBtn;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIButton * fullScreenBtn;

@property (nonatomic, strong) PLVCastQualityView * qualityV;

// 上一个清晰度
@property (nonatomic, copy) NSString * lastQuality;

@end

@implementation PLVCastControllView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self createUI];
        
        self.alpha = 0;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)createUI{
    
    // 设备
    [self addSubview:self.deviceBgImgV];
    [self addSubview:self.deviceNameLb];
    [self addSubview:self.stateLb];
    
    // 音量
    [self addSubview:self.volumeAddBtn];
    [self addSubview:self.volumeMinusBtn];
    
    // 控制
    [self addSubview:self.controllBgV];
    
    // 底部控制
    [self addSubview:self.bottomControllV];
    [self addSubview:self.timeSld];

    // 其他
    [self addSubview:self.qualityV];
    [self addSubview:self.backBtn];
    
}

- (void)layoutSubviews{
    float boundsW = self.bounds.size.width;
    float boundsH = self.bounds.size.height;
    
    // 横竖屏
    BOOL VorH = UIScreen.mainScreen.bounds.size.width < UIScreen.mainScreen.bounds.size.height; // yes - 竖屏；no - 横屏
    
    // 设备
    float bgImgVW = boundsW * 0.7;
    float bgImgVH = boundsH * 0.37;
    if (VorH) {
        self.deviceBgImgV.frame = CGRectMake((boundsW - bgImgVW) / 2, 0, bgImgVW, bgImgVH);
    }else{
        float bgImgScale = bgImgVW / bgImgVH;
        float bgImgVWInH = (359.0 / 667.0) * boundsW;
        float bgImgVHInH = (bgImgVWInH / bgImgScale);
        self.deviceBgImgV.frame = CGRectMake((boundsW - bgImgVWInH) / 2, 0, bgImgVWInH, bgImgVHInH);
    }

    // 投屏状态 投屏设备
    float top = VorH ? 0 : 20;
    self.stateLb.frame = CGRectMake((boundsW - bgImgVW) / 2, 20 + top, bgImgVW, 15);
    self.deviceNameLb.frame = CGRectMake((boundsW - bgImgVW) / 2, CGRectGetMaxY(self.stateLb.frame) + 10 + top * 0.5, bgImgVW, 17);

    // 音量
    float volumeBtnW = 34;
    self.volumeAddBtn.frame = CGRectMake(boundsW - 10 - 34, 10 + top * 1.2, volumeBtnW, volumeBtnW);
    self.volumeMinusBtn.frame = CGRectMake(boundsW - 10 - 34, CGRectGetMaxY(self.volumeAddBtn.frame) + 10, volumeBtnW, volumeBtnW);
    
    // 底部控制
    float bottomControllVH = 54;
    self.bottomControllV.frame = CGRectMake(0, boundsH - bottomControllVH, boundsW, bottomControllVH);
    self.timeSld.frame = CGRectMake(-2, boundsH - bottomControllVH - 2 - 31 / 2, boundsW + 4, 31);
    
    float playBtnH = 22;
    float padding = 19;
    self.playBtn.frame = CGRectMake(padding, (bottomControllVH - playBtnH) / 2, 14, playBtnH);
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.playBtn.frame) + padding, (bottomControllVH - playBtnH) / 2, 150, playBtnH);
    self.fullScreenBtn.frame = CGRectMake(CGRectGetWidth(self.bottomControllV.frame) - padding - 19, (bottomControllVH - playBtnH) / 2, 19, 22);
    
    if (self.controllBtnStrArr.count > 0) {
        // 控制
        float scale = 80.0 / 375.0;
        float controllBtnW = scale * boundsW;
        float controllBgVW = controllBtnW * self.controllBtnStrArr.count + (self.controllBtnStrArr.count - 1) * 1;
        float controlBgY = VorH ? (CGRectGetMaxY(self.deviceBgImgV.frame) + 20 + top * 3) : (CGRectGetMinY(self.bottomControllV.frame) - 36 - 36);
        self.controllBgV.frame = CGRectMake((boundsW - controllBgVW) / 2, controlBgY, controllBgVW, 36);
        
        // 控件按钮
        NSArray * subVArr = _controllBgV.subviews;
        for (UIView * subV in subVArr) {
            if (subV.tag >= 100) {
                NSInteger idx = subV.tag - 100;
                subV.frame = CGRectMake(idx * (controllBtnW + 1),
                                        0,
                                        controllBtnW,
                                        CGRectGetHeight(_controllBgV.frame));
            }
        }
    }
    
    // 其他
    self.qualityV.frame = self.bounds;
    self.backBtn.hidden = VorH;
    self.backBtn.frame = CGRectMake(10, 26, 32, 32);
}

#pragma mark - ----------------- < Getter > -----------------
#pragma mark 设备
- (UIImageView *)deviceBgImgV{
    if (_deviceBgImgV == nil) {
        _deviceBgImgV = [[UIImageView alloc]init];
        // _deviceBgImgV.backgroundColor = [UIColor orangeColor];
        _deviceBgImgV.image = [UIImage imageNamed:@"bg-tv-s"];
    }
    return _deviceBgImgV;
}

- (UILabel *)deviceNameLb{
    if (_deviceNameLb == nil) {
        _deviceNameLb = [[UILabel alloc]init];
        _deviceNameLb.text = @"客厅的小米电视";
        _deviceNameLb.font = [UIFont systemFontOfSize:12];
        _deviceNameLb.textColor = [UIColor whiteColor];
        _deviceNameLb.textAlignment = NSTextAlignmentCenter;
    }
    return _deviceNameLb;
}

- (UILabel *)stateLb{
    if (_stateLb == nil) {
        _stateLb = [[UILabel alloc]init];
        _stateLb.text = @"投屏中";
        _stateLb.font = [UIFont systemFontOfSize:15];
        _stateLb.textColor = [UIColor colorWithRed:40.0/255.0
                                             green:142.0/255.0
                                              blue:218.0/255.0
                                             alpha:1];
        _stateLb.textAlignment = NSTextAlignmentCenter;
    }
    return _stateLb;
}

#pragma mark 音量
- (UIButton *)volumeAddBtn{
    if (_volumeAddBtn == nil) {
        _volumeAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _volumeAddBtn.backgroundColor = [UIColor colorWithRed:51.0/255.0
                                                        green:51.0/255.0
                                                         blue:51.0/255.0
                                                        alpha:0.5];
        _volumeAddBtn.layer.cornerRadius = 8;
        // _volumeAddBtn.backgroundColor = [UIColor yellowColor];
        [_volumeAddBtn setImage:[UIImage imageNamed:@"btn-vol+"] forState:UIControlStateNormal];
        [_volumeAddBtn addTarget:self action:@selector(volumeAddBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _volumeAddBtn.alpha = 0;
        _volumeAddBtn.userInteractionEnabled = NO;
    }
    return _volumeAddBtn;
}

- (UIButton *)volumeMinusBtn{
    if (_volumeMinusBtn == nil) {
        _volumeMinusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _volumeMinusBtn.backgroundColor = [UIColor colorWithRed:51.0/255.0
                                                          green:51.0/255.0
                                                           blue:51.0/255.0
                                                          alpha:0.5];
        _volumeMinusBtn.layer.cornerRadius = 8;
        // _volumeMinusBtn.backgroundColor = [UIColor yellowColor];
        [_volumeMinusBtn setImage:[UIImage imageNamed:@"btn-vol-"] forState:UIControlStateNormal];
        [_volumeMinusBtn addTarget:self action:@selector(volumeMinusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _volumeMinusBtn.alpha = 0;
        _volumeMinusBtn.userInteractionEnabled = NO;
    }
    return _volumeMinusBtn;
}

#pragma mark 控制
- (UIView *)controllBgV{
    if (_controllBgV == nil) {
        _controllBgV = [[UIView alloc]init];
        // _controllBgV.backgroundColor = [UIColor blackColor];
        _controllBgV.clipsToBounds = YES;
        _controllBgV.layer.cornerRadius = 10;
    }
    return _controllBgV;
}

#pragma mark 底部控制
- (UISlider *)timeSld{
    if (_timeSld == nil) {
        _timeSld = [[UISlider alloc]init];
        // _timeSld.backgroundColor = [UIColor yellowColor];
        [_timeSld setThumbImage:[UIImage imageNamed:@"plv_vod_btn_slider_player"] forState:UIControlStateNormal];
        _timeSld.minimumTrackTintColor = [UIColor colorWithRed:49/255.0 green:173/255.0 blue:254/255.0 alpha:1.0];
//        [_timeSld addTarget:self action:@selector(:) forControlEvents:UIControlEventTouchDown];
        [_timeSld addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
//        [_timeSld addTarget:self action:@selector(:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    }
    return _timeSld;
}

- (UIView *)bottomControllV{
    if (_bottomControllV == nil) {
        _bottomControllV = [[UIView alloc]init];
        _bottomControllV.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7];
        // _bottomControllV.backgroundColor = [UIColor orangeColor];
        [_bottomControllV addSubview:self.playBtn];
        [_bottomControllV addSubview:self.timeLabel];
        [_bottomControllV addSubview:self.fullScreenBtn];
    }
    return _bottomControllV;
}

- (UIButton *)playBtn{
    if (_playBtn == nil) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"plv_vod_btn_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"plv_vod_btn_pause"] forState:UIControlStateSelected];
        // _volumeAddBtn.backgroundColor = [UIColor yellowColor];
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.text = @"00:00 / 00:00";
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (UIButton *)fullScreenBtn{
    if (_fullScreenBtn == nil) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"plv_vod_btn_fullscreen"] forState:UIControlStateNormal];
        // _volumeAddBtn.backgroundColor = [UIColor yellowColor];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

#pragma mark 其他
- (PLVCastQualityView *)qualityV{
    if (_qualityV == nil) {
        _qualityV = [[PLVCastQualityView alloc]init];
        
        __weak typeof(self) weakSelf = self;
        _qualityV.qualityDidChangeBlock = ^(NSInteger qualityIdx, UIButton *button) {
            // 判断是否同一个清晰度，是则不需回调
            if ([weakSelf.lastQuality isEqualToString:button.titleLabel.text]) {
                return ;
            }
            
            // 回调
            if ([weakSelf.delegate respondsToSelector:@selector(plvCastControllView_qualityChangeWithIndex:)]) {
                [weakSelf.delegate plvCastControllView_qualityChangeWithIndex:qualityIdx];
            }
            
            // 更新Btn所显示清晰度
            [weakSelf.qualityChangeBtn setTitle:button.titleLabel.text forState:UIControlStateNormal];
            
            // 保存所选清晰度
            weakSelf.lastQuality = weakSelf.qualityV.currentQueality;
        };
    
        _qualityV.alpha = 0;
        _qualityV.userInteractionEnabled = NO;
    }
    return _qualityV;
}

- (UIButton *)backBtn{
    if (_backBtn == nil) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.backgroundColor = [UIColor colorWithRed:0/255.0 green:16/255.0 blue:27/255.0 alpha:0.7];
        [_backBtn setImage:[UIImage imageNamed:@"plv_vod_btn_back"] forState:UIControlStateNormal];
        _backBtn.layer.cornerRadius = 16;
        _backBtn.layer.masksToBounds = YES;
        [_backBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark - ----------------- < Private Method > -----------------
- (void)showVolumeBtn{
    [UIView animateWithDuration:0.2 animations:^{
        self.volumeAddBtn.alpha = 1;
        self.volumeAddBtn.userInteractionEnabled = YES;
        self.volumeMinusBtn.alpha = 1;
        self.volumeMinusBtn.userInteractionEnabled = YES;
    }];
}

- (void)hideVolumeBtn{
    [UIView animateWithDuration:0.2 animations:^{
        self.volumeAddBtn.alpha = 0;
        self.volumeAddBtn.userInteractionEnabled = NO;
        self.volumeMinusBtn.alpha = 0;
        self.volumeMinusBtn.userInteractionEnabled = NO;
    }];
}

#pragma mark - ----------------- < Open Method > -----------------
- (void)reloadControllBtnWithStringArray:(NSArray <NSString *>*)strArr{
    self.controllBtnStrArr = strArr;
    
    // 清空Btn
    NSArray * subVArr = _controllBgV.subviews;
    for (UIView * subV in subVArr) [subV removeFromSuperview];

    // 添加Btn
    for (int i = 0; i < strArr.count; i ++) {
        NSString * string = strArr[i];
        NSArray * subStrArr = [string componentsSeparatedByString:@":"];
    
        NSString * typeStr = subStrArr.firstObject;
        NSString * textStr = subStrArr.lastObject;
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:textStr forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.backgroundColor = [UIColor colorWithRed:51.0/255.0
                                              green:51.0/255.0
                                               blue:51.0/255.0
                                              alpha:1];
        btn.tag = 100 + i;
        [_controllBgV addSubview:btn];
        
        SEL method = nil;
        if ([typeStr isEqualToString:@"1"]) method = @selector(qualityBtnClick:);
        if ([typeStr isEqualToString:@"2"]) method = @selector(quitBtnClick:);
        if ([typeStr isEqualToString:@"3"]) method = @selector(deviceBtnClick:);

        if (method != nil) [btn addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
        
        if ([typeStr isEqualToString:@"1"]) {
            [btn setTitle:[self.qualityV currentQueality] forState:UIControlStateNormal];
            self.qualityChangeBtn = btn;
        }
    }
    
    [self setNeedsLayout];
}

- (void)refreshTimeLabelWithCurrentTime:(NSInteger)currentTime duration:(NSInteger)duration{
    NSString * curTimeStr = [NSString stringWithFormat:@"%02ld:%02ld",currentTime / 60 , currentTime % 60];
    NSString * durTimeStr = [NSString stringWithFormat:@"%02ld:%02ld",duration / 60 , duration % 60];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@",curTimeStr,durTimeStr];
    
    float percent = (float)currentTime / (float)duration;
    self.timeSld.value = percent;
}

- (void)setDeviceName:(NSString *)deviceName{
    if (_deviceName != deviceName) {
        self.deviceNameLb.text = deviceName;
        _deviceName = [deviceName copy];
    }
}

- (void)setStatus:(PLVCastControllViewCastStatus)status{
    self.stateLb.textColor = [UIColor whiteColor];
    
    if (status == PLVCastCVStatus_Unknown) {
        self.stateLb.text = @"正在连接..."; // 未知状态也显示为正在连接
        self.stateLb.textColor = [UIColor whiteColor];
        
        [self hideVolumeBtn];
    }else if (status == PLVCastCVStatus_Connecting) {
        self.stateLb.text = @"正在连接...";
        self.stateLb.textColor = [UIColor whiteColor];
        
        [self hideVolumeBtn];
    }else if (status == PLVCastCVStatus_Casting){
        self.stateLb.text = @"投屏中";
        self.stateLb.textColor = [UIColor colorWithRed:49/255.0 green:173/255.0 blue:254/255.0 alpha:1.0];
        
        [self showVolumeBtn];
    }else if (status == PLVCastCVStatus_Disconnect){
        self.stateLb.text = @"投屏失败";
        self.stateLb.textColor = [UIColor colorWithRed:255/255.0 green:91/255.0 blue:91/255.0 alpha:1.0];
        
        [self hideVolumeBtn];
    }else if (status == PLVCastCVStatus_Complete){
        self.stateLb.text = @"投屏结束";
        self.stateLb.textColor = [UIColor colorWithRed:49/255.0 green:173/255.0 blue:254/255.0 alpha:1.0];
        
        [self hideVolumeBtn];
    }else if (status == PLVCastCVStatus_Error){
        self.stateLb.text = @"投屏错误 请重试";
        self.stateLb.textColor = [UIColor colorWithRed:255/255.0 green:91/255.0 blue:91/255.0 alpha:1.0];
        
        [self hideVolumeBtn];
    }
    
    _status = status;
}

- (void)setCurrentQualityIndex:(NSInteger)currentQualityIndex{
    if (self.qualityV.qualityCount == 0) {
        NSLog(@"PLVCastControllView - 设置当前清晰度失败，请先设置清晰度可选数");
        return;
    }
    self.qualityV.qualityIdx = currentQualityIndex;
    
    self.lastQuality = self.qualityV.currentQueality;
    
    _currentQualityIndex = currentQualityIndex;
}

- (void)setQualityOptionCount:(NSInteger)qualityOptionCount{
    self.qualityV.qualityCount = qualityOptionCount;
    
    _qualityOptionCount = qualityOptionCount;
}

- (void)show{
    [UIView animateWithDuration:0.33 animations:^{
        self.alpha = 1;
        self.userInteractionEnabled = YES;
    }];
}

- (void)hide{
    [UIView animateWithDuration:0.33 animations:^{
        self.alpha = 0;
        self.userInteractionEnabled = NO;
    }];
}

#pragma mark - ----------------- < Event > -----------------
#pragma mark 音量
- (void)volumeAddBtnClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(plvCastControllView_volumeAddButtonClick)]) {
        [self.delegate plvCastControllView_volumeAddButtonClick];
    }
}

- (void)volumeMinusBtnClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(plvCastControllView_volumeMinusButtonClick)]) {
        [self.delegate plvCastControllView_volumeMinusButtonClick];
    }
}

#pragma mark 控制
- (void)qualityBtnClick:(UIButton *)btn{
    [self.qualityV show];
}

- (void)quitBtnClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(plvCastControllView_quitButtonClick)]) {
        [self.delegate plvCastControllView_quitButtonClick];
    }
}

- (void)deviceBtnClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(plvCastControllView_deviceButtonClick)]) {
        [self.delegate plvCastControllView_deviceButtonClick];
    }
}

#pragma mark 底部控制
- (void)sliderValueChange:(UISlider *)sld{
    if ([self.delegate respondsToSelector:@selector(plvCastControllView_sliderValueChanged:)]) {
        [self.delegate plvCastControllView_sliderValueChanged:sld];
    }
}

- (void)playBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    
    if ([self.delegate respondsToSelector:@selector(plvCastControllView_playButtonClick:)]) {
        [self.delegate plvCastControllView_playButtonClick:btn];
    }
}

- (void)fullScreenBtnClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(plvCastControllView_fullScreenButtonClick:)]) {
        [self.delegate plvCastControllView_fullScreenButtonClick:btn];
    }
}


@end



@implementation PLVCastQualityView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];

        [self createUI];
    }
    return self;
}

- (void)layoutSubviews{
    self.stackV.frame = self.bounds;
}

- (void)createUI{
    self.stackV = [[UIStackView alloc]initWithFrame:self.bounds];
    self.stackV.axis = UILayoutConstraintAxisHorizontal;
    self.stackV.alignment = UIStackViewAlignmentCenter;
    self.stackV.spacing = 48;
    self.stackV.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:self.stackV];
}

#pragma mark - ----------------- < Open Mehotd > -----------------
- (void)show{
    [UIView animateWithDuration:0.33 animations:^{
        self.alpha = 1;
        self.userInteractionEnabled = YES;
    }];
}

- (void)hide{
    [UIView animateWithDuration:0.33 animations:^{
        self.alpha = 0;
        self.userInteractionEnabled = NO;
    }];
}

- (void)setQualityCount:(NSInteger)qualityCount {
    _qualityCount = qualityCount;
    if (qualityCount < 1) {
        return;
    }
    if (qualityCount > 3) {
        _qualityCount = 3;
    }
    
    UIButton * qualityStandardButton = [self.class buttonWithTitle:@"流畅" target:self];
    UIButton * qualityHighButton = [self.class buttonWithTitle:@"高清" target:self];
    UIButton * qualityUltraButton = [self.class buttonWithTitle:@"超清" target:self];
    
    // 清除控件
    for (UIView * subview in self.stackV.arrangedSubviews) {
        [self.stackV removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    switch (qualityCount) {
        case 1:{
            [self.stackV addArrangedSubview:qualityStandardButton];
        }break;
        case 2:{
            [self.stackV addArrangedSubview:qualityStandardButton];
            [self.stackV addArrangedSubview:qualityHighButton];
        }break;
        case 3:{
            [self.stackV addArrangedSubview:qualityStandardButton];
            [self.stackV addArrangedSubview:qualityHighButton];
            [self.stackV addArrangedSubview:qualityUltraButton];
        }break;
        default:{}break;
    }
}

- (void)setQualityIdx:(NSInteger)qualityIdx {
    if (qualityIdx <= 0 || qualityIdx > self.stackV.arrangedSubviews.count) {
        return;
    }
    UIButton * qualityButton = self.stackV.arrangedSubviews[qualityIdx - 1];
    qualityButton.selected = YES;
    _qualityIdx = qualityIdx;
}

- (NSString *)currentQueality{
    if (_qualityIdx > self.stackV.arrangedSubviews.count || _qualityIdx <= 0) return @"";
    UIButton * qualityButton = self.stackV.arrangedSubviews[_qualityIdx - 1];
    return qualityButton.titleLabel.text;
}

#pragma mark - ----------------- < Event > -----------------
- (void)qualityButtonAction:(UIButton *)sender {
    for (UIButton * button in self.stackV.arrangedSubviews) {
        button.selected = NO;
    }
    NSInteger index = [self.stackV.arrangedSubviews indexOfObject:sender];
    self.qualityIdx = index + 1;
    if (self.qualityDidChangeBlock) self.qualityDidChangeBlock(self.qualityIdx, sender);
    [self hide];
}

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:40.0/255.0
                                          green:142.0/255.0
                                           blue:218.0/255.0
                                          alpha:1] forState:UIControlStateSelected];
    button.tintColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:target action:@selector(qualityButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hide];
}

@end

#pragma clang diagnostic pop

