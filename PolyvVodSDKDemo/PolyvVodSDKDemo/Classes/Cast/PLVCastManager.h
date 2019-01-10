//
//  PLVCastManager.h
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2018/12/14.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <LBLelinkKit/LBLelinkKit.h>
#import <PLVVodSDK/PLVVodVideo.h>
#import <PLVVodSDK/PLVVodSettings.h>
#import <PLVVodSDK/PLVVodPlayerUtil.h>

// TODO
// APPID 和 APPSECRET 需与包名绑定，获取方式请咨询Polyv技术支持
static NSString * const LBAPPID = @"10729";                                    // APP id
static NSString * const LBSECRETKEY = @"176141b01d6bfa5c40cc7dd2b71bd3c2";     // 密钥

NS_ASSUME_NONNULL_BEGIN

@class PLVCastServiceModel;

typedef NS_ENUM(NSUInteger, PLVCastPlayStatus) {
    PLVCastPlayStatusUnkown = 0,
    PLVCastPlayStatusLoading,
    PLVCastPlayStatusPlaying,
    PLVCastPlayStatusPause,
    PLVCastPlayStatusStopped,
    PLVCastPlayStatusCommpleted,
    PLVCastPlayStatusError,
};

@protocol PLVCastManagerDelegate <NSObject>

// 设备搜索发现设备回调
- (void)plvCastManager_findServices:(NSArray <PLVCastServiceModel *>*)servicesArray;

// 设备搜索状态变更回调
- (void)plvCastManager_searchStateHadChanged:(BOOL)searchIsStart;

// 投屏错误回调
// 包括搜索中、连接中、投屏过程中错误
// error为空，代表其他未知情况
- (void)plvCastManager_castError:(nullable NSError *)error;

// 设备连接回调
// 若是断开状态，可根据isPassiveDisconnect来判断是否是被动断开；
// 若是连接状态，则此参数isPassiveDisconnect默认传NO，请忽视
- (void)plvCastManager_connectServicesResult:(BOOL)isConnected serviceModel:(PLVCastServiceModel *)serviceModel passiveDisconnect:(BOOL)isPassiveDisconnect;

// WiFi变更回调
- (void)plvCastManager_WiFiDidChanged:(nullable NSString *)wifiName didChanged:(BOOL)didChanged;

// 播放状态回调
- (void)plvCastManager_playStatusChangedWithStatus:(PLVCastPlayStatus)status;

// 播放进度回调
- (void)plvCastManager_playTimeChangedWithCurrentTime:(NSInteger)currentTime duration:(NSInteger)duration;

@end


@interface PLVCastManager : NSObject // 单例类，投屏管理器

@property (nonatomic, weak) id <PLVCastManagerDelegate> delegate;

@property (nonatomic, strong, readonly) PLVCastServiceModel * currentServiceModel; // 当前连接的设备服务

@property (nonatomic, assign, readonly) BOOL connected; // 当前是否有连接中的设备

// 获知注册信息是否具备，将决定是否允许启动注册逻辑
+ (BOOL)authorizationInfoIsLegal;

// 获取授权，当可能需要投屏业务时，可提前调用此方法。生命周期中仅第一次调用有效
+ (void)getCastAuthorization;

// 单例对象
+ (instancetype)shareManager;

// 获取WiFi名
+ (NSString *)getWifiName;

// 是否连接可用WiFi
+ (BOOL)wifiCanUse;

// 当退出时，要调用此方法停止所有功能
- (void)quitAllFuntionc;

#pragma mark 设备搜索操作
// 开始搜索
- (void)startSearchService;

// 停止搜索 若不停止，则设备列表会持续刷新及回调
- (void)stopSearchService;


#pragma mark 设备连接操作
// 连接设备 以设备模型下标来寻找
- (PLVCastServiceModel *)connectServiceWithIndex:(NSInteger)idx;

// 连接设备
- (void)connectServiceWithModel:(PLVCastServiceModel *)plv_s;

// 断开当前连接
- (void)disconnect;


#pragma mark 设备播放操作
// 使用视频模型、所选码率，来开始新的视频播放
- (void)startPlayWithVideo:(PLVVodVideo *)video quality:(NSInteger)quality;

// 暂停播放
- (void)pause;

// 恢复播放
- (void)resume;

// 退出播放
- (void)stop;

// 进度调节 单位：秒
- (void)seekTo:(NSInteger)seekTime;

// 增加音量
- (void)addVolume;

// 减少音量
- (void)reduceVolume;

// 设置音量值 范围：0~100
- (void)setVolume:(NSInteger)value;

@end


@interface PLVCastServiceModel : NSObject // 投屏设备信息模型

// 设备名
@property (nonatomic, copy) NSString * deviceName;

// 接收端App的包名，用于判断是哪个服务
@property (nonatomic, copy) NSString * receviverPackageName;

// 是否当前连接中的设备
@property (nonatomic, assign) BOOL isConnecting;

@end

NS_ASSUME_NONNULL_END
