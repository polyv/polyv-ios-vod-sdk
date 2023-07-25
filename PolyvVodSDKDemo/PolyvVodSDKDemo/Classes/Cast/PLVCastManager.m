//
//  PLVCastManager.m
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2018/12/14.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import "PLVCastManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AlicloudUtils/AlicloudReachabilityManager.h>
#import "PLVVodUtils.h"

// 定时器时间
// 两者不能一样 否则任务无法区分
#define searchSustainTime 5 // 搜索持续时间
#define searchIntervalTime 10 // 搜索间隔时间

@interface PLVCastManager ()<WXDLNASenderServerDelegate, WXDLNASenderResponseDelegate>

@property (nonatomic,strong) WXDLNASenderRenderer *dlnaRender;

@property (nonatomic, strong) NSArray <WXDLNASenderDevice *>* dl_serviceArr;
@property (nonatomic, strong) NSMutableArray <PLVCastServiceModel *>* plv_serviceArr; // 转化后的投屏设备信息模型数组，仅保留需要的信息，来供给调用方读取

@property (nonatomic, copy) NSString * lastWiFiName; // 用于判断wifi是否变更

@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSTimer * getPositionInfoTimer;

@property (nonatomic, assign) NSTimeInterval startPosition;
@property (nonatomic, assign) NSInteger currentVolume;


@end

@implementation PLVCastManager


#pragma mark - ----------------- < Life Priord > -----------------
- (void)dealloc{
    if (_timer) {
        _timer.fireDate = NSDate.distantFuture;
        [_timer invalidate];
        _timer = nil;
    }
    
    if (_getPositionInfoTimer) {
        _getPositionInfoTimer.fireDate = NSDate.distantFuture;
        [_getPositionInfoTimer invalidate];
        _getPositionInfoTimer = nil;
    }
    
    NSLog(@"PLVCastManager - [[[ PLVCastManager Dealloc ]]]");
}

static PLVCastManager * manager = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) manager = [super allocWithZone:zone];
    });
    return manager;
}

- (instancetype)init{
    if (self = [super init]) {
        [self initData];
        
        self.lastWiFiName = [[self class]getWifiName];
        
        // 监听WiFi变更
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,onNotifyCallback, CFSTR("com.apple.system.config.network_change"), NULL,CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}

- (void)initData{
    self.plv_serviceArr = [[NSMutableArray alloc]init];
}

#pragma mark - ----------------- < Open Method > -----------------
+ (BOOL)authorizationInfoIsLegal{
    if (DLAPPID.length == 0 || DLSECRETKEY.length == 0) return NO;
    return YES;
}

+ (void)getCastAuthorization{
    if ([self authorizationInfoIsLegal] == NO) {
        NSLog(@"PLVCastManager - 注册信息不足，如需投屏功能，请在'PLVCastManager.h'中填写");
        return;
    }
    
    [WXDLNASenderServer registWithAppId:DLAPPID appSecret:DLSECRETKEY registResult:^(BOOL success) {
        if (success) {
            NSLog(@"PLVCastManager - 授权成功");
        }else{
            NSLog(@"PLVCastManager - 授权失败");
        }
    }];
}

+ (instancetype)shareManager{
    return [[self alloc]init];
}

+ (NSString *)getWifiName{
/* 如需获取正确的wifi名称，请需要在Info.plist中配置以下对应的键值
 
 NSLocationAlwaysUsageDescription : 允许在前后台获取定位的描述
 NSLocationWhenInUseDescription : 允许在前台获取定位的描述
 
 并在此文件新增#import <CoreLocation/CoreLocation.h> 引用，并在此方法中增加以下两行代码，否则以上请求授权的方法不生效
 CLLocationManager *manager = [[CLLocationManager alloc]init];
 [manager requestAlwaysAuthorization];
*/
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    if (!ssid && [self wifiCanUse]) {
        ssid = @"获取 WIFI 名称失败";
    }
    return ssid;
}

+ (BOOL)wifiCanUse{
    AlicloudReachabilityManager *reachability = [AlicloudReachabilityManager shareInstance];
    return [reachability isReachableViaWifi];
}

- (void)quitAllFuntionc{
    [self stopTimer];
    [self stopGetPositionInfoTimerTimer];
    
    self.dl_serviceArr = nil;
    [self.plv_serviceArr removeAllObjects];
    
    self.dlnaRender.device = nil;
    [[WXDLNASenderServer shared] stop];
    
    self.dlnaRender.delegate = nil;
    [WXDLNASenderServer shared].delegate = nil;

    self.dlnaRender = nil;
}

- (PLVCastServiceModel *)currentServiceModel{
    WXDLNASenderDevice * dl_Device = self.dlnaRender.device;
    PLVCastServiceModel * plv_service = [self getPlvServiceInfoWithOriginalDeviceModel:dl_Device];
    return plv_service;
}

- (BOOL)connected{
    if (self.dlnaRender.device) return YES;
    return NO;
}

#pragma mark 设备搜索操作
- (void)startSearchService{
    [WXDLNASenderServer shared].delegate = self;
    
    [[WXDLNASenderServer shared] start];
    
    // 回调搜索状态
    if ([self.delegate respondsToSelector:@selector(plvCastManager_searchStateHadChanged:)]) {
        [self.delegate plvCastManager_searchStateHadChanged:YES];
    }
    
    [self createFutureEventWithTime:searchSustainTime];
}

- (void)stopSearchService{
    [self stopSearchServiceWithAutoStartSearch:NO];
}

#pragma mark 设备连接操作
- (PLVCastServiceModel *)connectServiceWithIndex:(NSInteger)idx{
    if (idx < self.plv_serviceArr.count) {
        PLVCastServiceModel * plv_service = self.plv_serviceArr[idx];
        [self connectServiceWithModel:plv_service];
        return plv_service;
    }
    return nil;
}

- (void)connectServiceWithModel:(PLVCastServiceModel *)plv_service{
    WXDLNASenderDevice * dl_device = [self getOriginalDeviceInfoWithPlvServiceModel:plv_service];
    NSLog(@"PLVCastManager - 准备连接的设备 简短名 : %@, 设备名 :%@",dl_device.friendlyName,dl_device.modelName);
    
    // 若设备为空
    if (dl_device == nil) {
        if ([self.delegate respondsToSelector:@selector(plvCastManager_castError:)]) {
            [self.delegate plvCastManager_castError:nil];
        }
        return;
    }
    
    // 若所选设备和当前一致
    if (self.dlnaRender.device == dl_device) {
        return;
    }
    
    // 若已连接其他设备
    if (self.dlnaRender.device != nil) {
        
        [self stop];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self disconnect];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectServiceWithModel:plv_service];
        });
        return;
    }
    self.dlnaRender = [[WXDLNASenderRenderer alloc] initWithUPnPDevice:dl_device];
    self.dlnaRender.delegate = self;
    
    NSLog(@"PLVCastManager - 已连接到设备服务 设备%@ 设备名:%@",dl_device,dl_device.friendlyName);
    
    if ([self.delegate respondsToSelector:@selector(plvCastManager_connectServicesResult:serviceModel:passiveDisconnect:)]) {
        [self.delegate plvCastManager_connectServicesResult:YES serviceModel:plv_service passiveDisconnect:NO];
    }
}

- (void)disconnect{
    WXDLNASenderDevice *willBeDisconnectedDevice = self.dlnaRender.device;
    self.dlnaRender.delegate = nil;
    self.dlnaRender.device = nil;
    
    NSLog(@"PLVCastManager - 已断开与设备服务的连接 设备名：%@",willBeDisconnectedDevice.friendlyName);
    
    PLVCastServiceModel * plv_service = [self getPlvServiceInfoWithOriginalDeviceModel:willBeDisconnectedDevice];
    
    if ([self.delegate respondsToSelector:@selector(plvCastManager_connectServicesResult:serviceModel:passiveDisconnect:)]) {
        [self.delegate plvCastManager_connectServicesResult:NO serviceModel:plv_service passiveDisconnect:NO];
    }
}

#pragma mark 设备播放操作
- (void)startPlayWithVideo:(PLVVodVideo *)video quality:(NSInteger)quality startPosition:(NSTimeInterval)startPosition {
    
    NSString *urlString = [video transformCastMediaURLStringWithQuality:quality];
    if (urlString == nil || [urlString isKindOfClass: [NSString class]] == NO || urlString.length == 0) {
        NSLog(@"PLVCastManager - 播放链接非法 链接：%@",urlString);
        return;
    }
    self.startPosition = startPosition;
    if (video.keepSource || video.isPlain) {
        WXDLNASenderMediaInfo *mediaInfo = [[WXDLNASenderMediaInfo alloc] initWithUrlString:urlString];
        mediaInfo.title = video.title;
        [self.dlnaRender setAVTransport:mediaInfo];
    }else{
        
        __weak typeof(self) weakSelf = self;
        [PLVVodPlayerUtil requestCastKeyIvWitVideo:video quality:quality completion:^(NSString * _Nullable key, NSString * _Nullable iv, NSError * _Nullable error) {
            if (error == nil) {
                if (key && key.length && iv && iv.length) {
                    WXDLNASenderMediaInfo *mediaInfo = [[WXDLNASenderMediaInfo alloc] initWithUrlString:urlString];
                    mediaInfo.title = video.title;
                    mediaInfo.decryptKey = key;
                    mediaInfo.decryptIV = iv;
                    [weakSelf.dlnaRender setAVTransport:mediaInfo];
                }else {
                    NSLog(@"PLVCastManager - 投加密视频失败, 没有获取到解密key");
                }
            }else{
                NSLog(@"PLVCastManager - 投加密视频失败 ：%@",error);
            }
        }];
    }
}

- (void)pause{
    [self.dlnaRender pause];
}

- (void)resume{
    [self.dlnaRender play];
}

- (void)seekTo:(NSInteger)seekTime{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.dlnaRender seek:seekTime];
    });
}

- (void)stop{
    [self.dlnaRender stop];
    [self stopGetPositionInfoTimerTimer];
}

- (void)addVolume{
    self.currentVolume += 5;
    NSString *volumeStr = [NSString stringWithFormat:@"%ld", (long)self.currentVolume];
    [self.dlnaRender setVolumeWith:volumeStr];
}

- (void)reduceVolume{
    self.currentVolume -= 5;
    NSString *volumeStr = [NSString stringWithFormat:@"%ld", (long)self.currentVolume];
    [self.dlnaRender setVolumeWith:volumeStr];
}

- (void)setVolume:(NSInteger)value{
    [self.dlnaRender setVolumeWith:[NSString stringWithFormat:@"%ld", (long)value]];
}

#pragma mark - ----------------- < Private Method > -----------------
static void onNotifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    NSString * notifyName = (__bridge NSString *) name;
    NSDictionary * notifDic = (__bridge NSDictionary *) userInfo;

    if ([notifyName isEqualToString:@"com.apple.system.config.network_change"]) {
        if (manager != nil) {
            NSString * currentWiFiName = [[manager class]getWifiName];
            
            // 判断是否和上个WiFi是相同的
            // TODO 若WiFi名相同则无法判断
            BOOL wifiDidChanged = YES;
            if (currentWiFiName == manager.lastWiFiName ||
                [currentWiFiName isEqualToString:manager.lastWiFiName]) wifiDidChanged = NO;
        
            // 回调
            if ([manager.delegate respondsToSelector:@selector(plvCastManager_WiFiDidChanged:didChanged:)]) {
                [manager.delegate plvCastManager_WiFiDidChanged:currentWiFiName didChanged:wifiDidChanged];
            }
            
            // 保存
            manager.lastWiFiName = currentWiFiName;
        }
        
    } else {
        NSLog(@"PLVCastManager - WiFi没有变更 -> %@  info %@", notifyName,notifDic);
    }
}

// 停止搜索，参数决定是否附带自动启动搜索任务
- (void)stopSearchServiceWithAutoStartSearch:(BOOL)autoStart{
    [[WXDLNASenderServer shared] stop];
    
    // 回调搜索状态
    if ([self.delegate respondsToSelector:@selector(plvCastManager_searchStateHadChanged:)]) {
        [self.delegate plvCastManager_searchStateHadChanged:NO];
    }
    
    if (autoStart) {
        if ([[self class] wifiCanUse] == NO) {
            return;
        }
        
        [self createFutureEventWithTime:searchIntervalTime];
    }else{
        [self stopTimer];
    }
}

// 设置定时任务
- (void)createFutureEventWithTime:(NSInteger)time{
    [self stopTimer];
    
    if (self.delegate == nil) {
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timeEvent:) userInfo:nil repeats:YES];
}

- (void)stopTimer{
    if (_timer) {
        _timer.fireDate = NSDate.distantFuture;
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)startGetPositionInfoTimerTimer {
    if (self.getPositionInfoTimer) {
        [self stopGetPositionInfoTimerTimer];
    }
    self.getPositionInfoTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getPositionInfoTimerEvent:) userInfo:nil repeats:YES];
    [self.getPositionInfoTimer fire];
    
}

- (void)stopGetPositionInfoTimerTimer {
    if (_getPositionInfoTimer) {
        _getPositionInfoTimer.fireDate = NSDate.distantFuture;
        [_getPositionInfoTimer invalidate];
        _getPositionInfoTimer = nil;
    }
}

// 通过plv设备模型，找到对应的lb设备模型
- (WXDLNASenderDevice *)getOriginalDeviceInfoWithPlvServiceModel:(PLVCastServiceModel *)plv_service{
    NSInteger idx = [self.plv_serviceArr indexOfObject:plv_service];
    WXDLNASenderDevice * dl_device = nil;
    if (idx < self.dl_serviceArr.count) {
        dl_device = self.dl_serviceArr[idx];
    }
    if (dl_device == nil) NSLog(@"PLVCastManager - 警告：无法找到对应乐播设备信息模型 plv_s %@",plv_service);
    return dl_device;
}

// 通过lb设备模型，找到对应的plv设备模型
- (PLVCastServiceModel *)getPlvServiceInfoWithOriginalDeviceModel:(WXDLNASenderDevice *)ld_Device {
    NSInteger idx = [self.dl_serviceArr indexOfObject:ld_Device];
    PLVCastServiceModel * plv_service = nil;
    if (idx < self.plv_serviceArr.count) {
        plv_service = self.plv_serviceArr[idx];
    }
    if (plv_service == nil) NSLog(@"PLVCastManager - 警告：无法找到对应Plv设备信息模型 lb_s %@",ld_Device);
    return plv_service;
}

// 转化设备信息模型
- (void)setPlvServicesArrWithOriginalServicesArr:(NSArray<WXDLNASenderDevice *> *)dlDeviceArr{
    [self.plv_serviceArr removeAllObjects];
    
    for (WXDLNASenderDevice * dl_device in dlDeviceArr) {
        // 生成plv的设备信息模型
        PLVCastServiceModel * plv_service = [[PLVCastServiceModel alloc]init];
        plv_service.serviceName = dl_device.friendlyName;
        plv_service.isConnecting = [self.dlnaRender.device.uuid isEqualToString:dl_device.uuid];
        [self.plv_serviceArr addObject:plv_service];
    }
    
    self.dl_serviceArr = dlDeviceArr;
}

// 刷新及回调最新的设备信息
- (void)refreshAndCallBackServicesInfoWithOriginalServicesInfoArray:(NSArray<WXDLNASenderDevice *> *)devices{
    // 刷新
    [self setPlvServicesArrWithOriginalServicesArr:devices];
    
    // 回调
    if ([self.delegate respondsToSelector:@selector(plvCastManager_findServices:)]) {
        [self.delegate plvCastManager_findServices:self.plv_serviceArr];
    }
}

#pragma mark - ----------------- < Event > -----------------
- (void)timeEvent:(NSTimer *)timer{
    if (self.delegate == nil) {
        [self stopTimer];
        return;
    }
    
    if (timer != _timer) {
        return;
    }
    
    if (timer.timeInterval == searchSustainTime) { // 搜索持续时间任务
        
        [self stopSearchServiceWithAutoStartSearch:YES];
        
    }else if(timer.timeInterval == searchIntervalTime) { // 搜索间隔时间任务
     
        if ([[self class] wifiCanUse]) {
            [self startSearchService];
        }else{
            NSLog(@"PLVCastManager - WiFi不可用，自动启动搜索任务不执行");
        }
    }
    [timer invalidate];
}

- (void)getPositionInfoTimerEvent:(NSTimer *)timer {
    if (self.delegate == nil) {
        [self stopGetPositionInfoTimerTimer];
        return;
    }
    if (self.dlnaRender == nil) {
        return;
    }
    [self.dlnaRender getPositionInfo];
}

#pragma mark - ----------------- < Delegate > -----------------
#pragma mark 设备搜索回调
- (void)upnpSearchChangeWithResults:(NSArray<WXDLNASenderDevice *> *)devices {
    [self refreshAndCallBackServicesInfoWithOriginalServicesInfoArray:devices];
}

- (void)upnpSearchError:(NSError *)error {
    NSLog(@"PLVCastManager - 设备搜索报错 Error : %@",error);
}

- (void)upnpSearchCloseWithError:(NSError *)error {
    NSLog(@"PLVCastManager - 设备搜索报错 Error : %@",error);
}

#pragma mark 设备播放回调
- (void)upnpSetAVTransportURIResponse {
    [self.dlnaRender play];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf startGetPositionInfoTimerTimer];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.dlnaRender getVolume];
    });
}

- (void)upnpGetTransportInfoResponse:(WXUPnPTransportInfo *)info {
    NSLog(@"upnpGetTransportInfoResponse %@ ", info.currentTransportState);
}

- (void)upnpPlayResponse {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(plvCastManager_playStatusChangedWithStatus:)]) {
            [weakSelf.delegate plvCastManager_playStatusChangedWithStatus:PLVCastPlayStatusPlaying];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.startPosition != 0) {
            [weakSelf.dlnaRender seek:weakSelf.startPosition];
            weakSelf.startPosition = 0;
        }
    });
}

- (void)upnpPauseResponse {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(plvCastManager_playStatusChangedWithStatus:)]) {
            [weakSelf.delegate plvCastManager_playStatusChangedWithStatus:PLVCastPlayStatusPause];
        }
    });
}

- (void)upnpStopResponse {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(plvCastManager_playStatusChangedWithStatus:)]) {
            [weakSelf.delegate plvCastManager_playStatusChangedWithStatus:PLVCastPlayStatusStopped];
        }
    });
}

- (void)upnpGetVolumeResponse:(NSString *)volume {
    self.currentVolume = [volume integerValue];
}

- (void)upnpUndefinedResponse:(NSString *)resXML postXML:(NSString *)postXML {
    NSLog(@"PLVCastManager - 未响应的错误 %@",resXML);
    WXDLNASenderDevice *willBeDisconnectedDevice = self.dlnaRender.device;
    PLVCastServiceModel * plv_service = [self getPlvServiceInfoWithOriginalDeviceModel:willBeDisconnectedDevice];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(plvCastManager_playStatusChangedWithStatus:)]) {
            [weakSelf.delegate plvCastManager_playStatusChangedWithStatus:PLVCastPlayStatusStopped];
        }
        if ([weakSelf.delegate respondsToSelector:@selector(plvCastManager_connectServicesResult:serviceModel:passiveDisconnect:)]) {
            [weakSelf.delegate plvCastManager_connectServicesResult:NO serviceModel:plv_service passiveDisconnect:YES];
        }
    });
    
    [self stopGetPositionInfoTimerTimer];
}

- (void)upnpGetPositionInfoResponse:(WXDLNASenderAVPositionInfo *)info {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(plvCastManager_playTimeChangedWithCurrentTime:duration:)]) {
            weakSelf.currentServiceModel.currentTime = (NSTimeInterval)info.relTime;
            [weakSelf.delegate plvCastManager_playTimeChangedWithCurrentTime:(NSInteger)info.relTime duration:(NSInteger)info.trackDuration];
        }
    });
}

@end


@implementation PLVCastServiceModel


@end

