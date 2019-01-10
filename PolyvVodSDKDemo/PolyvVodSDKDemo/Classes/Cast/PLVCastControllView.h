//
//  PLVCastControllView.h
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2018/12/12.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PLVCastControllViewDelegate <NSObject>

// 音量+ 按钮点击回调
- (void)plvCastControllView_volumeAddButtonClick;
// 音量- 按钮点击回调
- (void)plvCastControllView_volumeMinusButtonClick;

// 退出 按钮点击回调
- (void)plvCastControllView_quitButtonClick;
// 换设备 按钮点击回调
- (void)plvCastControllView_deviceButtonClick;

// 播放/暂停 按钮点击回调
- (void)plvCastControllView_playButtonClick:(UIButton *)button;
// 半屏/全屏 按钮点击回调
- (void)plvCastControllView_fullScreenButtonClick:(UIButton *)button;
// 滑杆 拖动回调
- (void)plvCastControllView_sliderValueChanged:(UISlider *)slider;

// 清晰度切换 回调
- (void)plvCastControllView_qualityChangeWithIndex:(NSInteger)index;

@end

typedef NS_ENUM(NSInteger, PLVCastControllViewCastStatus){
    PLVCastCVStatus_Unknown,    // 未知状态
    PLVCastCVStatus_Connecting, // 连接中
    PLVCastCVStatus_Casting,    // 投屏中
    PLVCastCVStatus_Disconnect, // 断开连接
    PLVCastCVStatus_Complete,   // 投屏播放完成
    PLVCastCVStatus_Error,      // 投屏错误
};

@interface PLVCastControllView : UIView // 投屏控制视图

@property (nonatomic, weak) id <PLVCastControllViewDelegate> delegate;

// 修改设备名
@property (nonatomic, copy) NSString * deviceName;

// 修改投屏状态
@property (nonatomic, assign) PLVCastControllViewCastStatus status;

// 设置当前使用的清晰度
@property (nonatomic, assign) NSInteger currentQualityIndex;

// 设置清晰度可选数量，自动对应清晰度关系
@property (nonatomic, assign) NSInteger qualityOptionCount;

// 播放按钮，可修改选中状态
@property (nonatomic, strong, readonly) UIButton * playBtn;

// 更换中间控制播放按钮
- (void)reloadControllBtnWithStringArray:(NSArray <NSString *>*)strArr;

// 刷新显示的进度时间、总时间
- (void)refreshTimeLabelWithCurrentTime:(NSInteger)currentTime duration:(NSInteger)duration;

// 展示/隐藏
- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
