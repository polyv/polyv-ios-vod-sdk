//
//  PLVCastManager.m
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2018/12/14.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import "PLVCastManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "PLVVodSDK/PLVVodReachability.h"
#import "PLVVodUtils.h"

// 定时器时间配置
#define searchSustainTime 5    // 搜索持续时间
#define searchIntervalTime 10  // 搜索间隔时间
#define getPostionTimer 0.5     // 查询播放端播放器状态间隔

@interface PLVCastManager ()<PLVFindDeviceDelegate, PLVControlDeviceDelegate>

@property (nonatomic, strong) PLVControlDevice *dlnaRender;

@property (nonatomic, strong) NSArray <PLVUPnPDevice *>* dl_serviceArr;
@property (nonatomic, strong) NSMutableArray <PLVCastServiceModel *>* plv_serviceArr;

@property (nonatomic, copy) NSString * lastWiFiName;
@property (nonatomic, strong) NSTimer * timer;  // 搜索管理定时器
@property (nonatomic, strong) NSTimer * getPositionInfoTimer; // 播放状态轮询定时器
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL isInBackground; // 标记是否在后台

@property (nonatomic, assign) NSTimeInterval startPosition;
@property (nonatomic, assign) NSInteger currentVolume;
@property (nonatomic, assign) BOOL hasReportedCompletion; // 标记是否已报告播放完成，避免重复触发

// 网络错误容错机制
@property (nonatomic, assign) NSInteger consecutiveErrorCount; // 连续错误次数
@property (nonatomic, assign) NSInteger maxErrorThreshold;     // 最大错误阈值

@end

@implementation PLVCastManager

#pragma mark - Life Cycle
- (void)dealloc{
    [self stopTimer];
    [self stopGetPositionInfoTimer];
    NSLog(@"PLVCastManager - dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static PLVCastManager * manager = nil;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) manager = [super allocWithZone:zone];
    });
    return manager;
}

- (instancetype)init{
    if (self = [super init]) {
        self.plv_serviceArr = [[NSMutableArray alloc]init];
        self.lastWiFiName = [[self class] getWifiName];
        self.isInBackground = NO;
        
        // 初始化网络错误容错机制
        self.consecutiveErrorCount = 0;
        self.maxErrorThreshold = 10; // 允许10次连续错误（约5秒容错时间，用于乐播广告等场景）
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, onNotifyCallback, CFSTR("com.apple.system.config.network_change"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        
        // 监听APP前后台切换
        // 使用 WillResignActive 更早地暂停，避免网络请求在后台被中断
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationWillResignActive:) 
                                                     name:UIApplicationWillResignActiveNotification 
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationDidBecomeActive:) 
                                                     name:UIApplicationDidBecomeActiveNotification 
                                                   object:nil];
    }
    return self;
}

#pragma mark - Public
+ (void)getCastAuthorization {
    // PLVDLNA does not require authorization
}

+ (BOOL)authorizationInfoIsLegal{
    return YES;
}

+ (instancetype)shareManager{
    return [[self alloc]init];
}

+ (NSString *)getWifiName{
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    ssid = ssid ?: [ifs firstObject];
    if (!ssid && [self wifiCanUse]) {
        ssid = @"获取 WIFI 名称失败";
    }
    return ssid;
}

+ (BOOL)wifiCanUse{
    PLVVodReachability *reachability = [PLVVodReachability sharedReachability];
    return (reachability.currentReachabilityStatus == PLVVodReachableViaWiFi);
}

- (void)quitAllFuntionc{
    NSLog(@"PLVCastManager - quit all functions");
    [self stopSearchService];
    [self disconnect];
    self.dl_serviceArr = nil;
    [self.plv_serviceArr removeAllObjects];
}

- (PLVCastServiceModel *)currentServiceModel{
    if (!self.dlnaRender.device) return nil;
    return [self getPlvServiceInfoWithOriginalDeviceModel:self.dlnaRender.device];
}

- (BOOL)connected{
    return self.dlnaRender.device != nil;
}

- (void)startSearchService{
    if (self.isSearching) return;
    if (![[self class] wifiCanUse]) {
        if ([self.delegate respondsToSelector:@selector(plvCastManager_castError:)]) {
            [self.delegate plvCastManager_castError:[NSError errorWithDomain:@"PLVCastManagerError" code:-1001 userInfo:@{NSLocalizedDescriptionKey: @"WiFi not available"}]];
        }
        return;
    }

    NSLog(@"PLVCastManager - 开始启动设备搜索服务");
    self.isSearching = YES;
    [PLVFindDevice sharedInstance].delegate = self;
    [[PLVFindDevice sharedInstance] startFindDevice];
    
    if ([self.delegate respondsToSelector:@selector(plvCastManager_searchStateHadChanged:)]) {
        [self.delegate plvCastManager_searchStateHadChanged:YES];
    }
    
    // 启动搜索持续时间定时器
    [self createFutureEventWithTime:searchSustainTime];
}

- (void)stopSearchService{
    [self stopSearchServiceWithAutoStartSearch:NO];
}

- (PLVCastServiceModel *)connectServiceWithIndex:(NSInteger)idx{
    if (idx < self.plv_serviceArr.count) {
        PLVCastServiceModel *plv_service = self.plv_serviceArr[idx];
        [self connectServiceWithModel:plv_service];
        return plv_service;
    }
    return nil;
}

- (BOOL)isDeviceConnectedAtIndex:(NSInteger)idx{
    if (idx >= self.plv_serviceArr.count) {
        return NO;
    }
    
    if (!self.dlnaRender || !self.dlnaRender.device) {
        return NO;
    }
    
    PLVCastServiceModel *plv_service = self.plv_serviceArr[idx];
    return [self.dlnaRender.device.uuid isEqualToString:plv_service.uuid];
}

- (void)connectServiceWithModel:(PLVCastServiceModel *)plv_service{
    PLVUPnPDevice *dl_device = [self getOriginalDeviceInfoWithPlvServiceModel:plv_service];
    if (!dl_device) {
        if ([self.delegate respondsToSelector:@selector(plvCastManager_castError:)]) {
            [self.delegate plvCastManager_castError:nil];
        }
        return;
    }

    if ([self.dlnaRender.device.uuid isEqualToString:dl_device.uuid]) return;

    if (self.dlnaRender.device) {
        [self stop];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self disconnect];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectServiceWithModel:plv_service];
        });
        return;
    }

    self.dlnaRender = [[PLVControlDevice alloc] initWithDevice:dl_device];
    self.dlnaRender.delegate = self;
    
    NSLog(@"PLVCastManager - 已连接到设备服务 设备%@ 设备名:%@", dl_device.friendlyName, dl_device.modelName);
    
    plv_service.isConnecting = YES;
    if ([self.delegate respondsToSelector:@selector(plvCastManager_connectServicesResult:serviceModel:passiveDisconnect:)]) {
        [self.delegate plvCastManager_connectServicesResult:YES serviceModel:plv_service passiveDisconnect:NO];
    }
}

- (void)disconnect{
    if (!self.dlnaRender) return;

    PLVUPnPDevice *disconnectedDevice = self.dlnaRender.device;
    PLVCastServiceModel *plv_service = [self getPlvServiceInfoWithOriginalDeviceModel:disconnectedDevice];

    self.dlnaRender.delegate = nil;
    self.dlnaRender = nil;
    self.hasReportedCompletion = NO; // 重置播放完成标志
    self.consecutiveErrorCount = 0;  // 重置错误计数
    
    NSLog(@"PLVCastManager - 已断开与设备服务的连接 设备名：%@", disconnectedDevice.friendlyName);
    
    if (plv_service) plv_service.isConnecting = NO;
    if ([self.delegate respondsToSelector:@selector(plvCastManager_connectServicesResult:serviceModel:passiveDisconnect:)]) {
        [self.delegate plvCastManager_connectServicesResult:NO serviceModel:plv_service passiveDisconnect:NO];
    }
}

- (void)startPlayWithVideo:(PLVVodVideo *)video quality:(NSInteger)quality startPosition:(NSTimeInterval)startPosition {
    // 检测视频是否加密，加密视频不支持投屏
    if (video && !video.isPlain && !video.keepSource) {
        NSLog(@"PLVCastManager - 加密视频不支持投屏，视频vid: %@", video.vid);
        NSError *error = [NSError errorWithDomain:@"PLVCastManagerError"
                                             code:-1002
                                         userInfo:@{NSLocalizedDescriptionKey: @"加密视频不支持投屏"}];
        if ([self.delegate respondsToSelector:@selector(plvCastManager_castError:)]) {
            [self.delegate plvCastManager_castError:error];
        }
        return;
    }
    
    NSString *urlString = [video transformCastMediaURLStringWithQuality:quality];
    if (!urlString.length) {
        NSLog(@"PLVCastManager - 播放链接非法 链接：%@", urlString);
        return;
    }
    
    self.startPosition = startPosition;
    self.hasReportedCompletion = NO; // 重置播放完成标志
    
    if (video.keepSource || video.isPlain) {
        [self.dlnaRender setAVTransportURL:urlString];
    } else {
        __weak typeof(self) weakSelf = self;
        [PLVVodPlayerUtil requestCastKeyIvWitVideo:video quality:quality completion:^(NSString * _Nullable key, NSString * _Nullable iv, NSError * _Nullable error) {
            if (error == nil) {
                if (key && key.length && iv && iv.length) {
                    // PLVDLNA 不直接支持加密播放，URL 本身必须是可播放的
                    // 如果需要加密支持，需要修改 PLVDLNA 库
                    [weakSelf.dlnaRender setAVTransportURL:urlString];
                } else {
                    NSLog(@"PLVCastManager - 投加密视频失败, 没有获取到解密key");
                }
            } else {
                NSLog(@"PLVCastManager - 投加密视频失败 ：%@", error);
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
    // 如果用户拖动进度，重置播放完成标志，允许再次检测播放完成
    self.hasReportedCompletion = NO;
    [self.dlnaRender seekToTime:seekTime];
}

- (void)stop{
    [self.dlnaRender stop]; 
    [self stopGetPositionInfoTimer];
}

- (void)addVolume{
    self.currentVolume += 5;
    [self.dlnaRender setVolume:(int)self.currentVolume];
}

- (void)reduceVolume{
    self.currentVolume -= 5;
    [self.dlnaRender setVolume:(int)self.currentVolume];
}

- (void)setVolume:(NSInteger)value{
    self.currentVolume = value;
    [self.dlnaRender setVolume:(int)value];
}

#pragma mark - Private
#pragma mark - APP生命周期
- (void)applicationWillResignActive:(NSNotification *)notification {
    self.isInBackground = YES;
    NSLog(@"PLVCastManager - APP即将失去焦点，暂停定时器");
    
    // 暂停播放状态轮询定时器，避免后台网络请求被系统中断
    if (self.getPositionInfoTimer) {
        [self.getPositionInfoTimer invalidate];
        self.getPositionInfoTimer = nil;
        NSLog(@"PLVCastManager - 已暂停播放状态轮询定时器");
    }
    
    // 暂停搜索管理定时器
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        NSLog(@"PLVCastManager - 已暂停搜索管理定时器");
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    NSLog(@"PLVCastManager - APP已激活，准备恢复定时器");
    
    // 延迟一小段时间再恢复，确保网络连接稳定
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.isInBackground = NO;
        
        // 如果有投屏连接，先验证连接再恢复定时器
        if (weakSelf.dlnaRender && weakSelf.dlnaRender.device) {
            NSLog(@"PLVCastManager - 验证投屏连接，尝试获取播放位置信息");
            
            // 先尝试获取一次播放位置信息，验证连接是否正常
            [weakSelf.dlnaRender getPositionInfo];
            
            // 延迟启动定时器，给一次验证请求的时间
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!weakSelf.isInBackground && weakSelf.dlnaRender && weakSelf.dlnaRender.device) {
                    [weakSelf startGetPositionInfoTimer];
                    NSLog(@"PLVCastManager - 已恢复播放状态轮询定时器");
                }
            });
        }
        
        // 如果正在搜索，恢复搜索定时器
        if (weakSelf.isSearching) {
            [weakSelf createFutureEventWithTime:searchSustainTime];
            NSLog(@"PLVCastManager - 已恢复搜索管理定时器");
        }
    });
}

static void onNotifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    if ([(__bridge NSString *)name isEqualToString:@"com.apple.system.config.network_change"] && manager) {
        NSString *currentWiFiName = [PLVCastManager getWifiName];
        BOOL didChanged = ![currentWiFiName isEqualToString:manager.lastWiFiName];
        if ([manager.delegate respondsToSelector:@selector(plvCastManager_WiFiDidChanged:didChanged:)]) {
            [manager.delegate plvCastManager_WiFiDidChanged:currentWiFiName didChanged:didChanged];
        }
        manager.lastWiFiName = currentWiFiName;
    }
}

// 停止搜索，参数决定是否附带自动启动搜索任务
- (void)stopSearchServiceWithAutoStartSearch:(BOOL)autoStart{
    NSLog(@"PLVCastManager - 停止搜索服务，自动重启: %@", autoStart ? @"是" : @"否");
    
    self.isSearching = NO;
    [[PLVFindDevice sharedInstance] stopFindDevice];
    [PLVFindDevice sharedInstance].delegate = nil;
    
    if ([self.delegate respondsToSelector:@selector(plvCastManager_searchStateHadChanged:)]) {
        [self.delegate plvCastManager_searchStateHadChanged:NO];
    }
    
    if (autoStart) {
        if ([[self class] wifiCanUse] == NO) {
            NSLog(@"PLVCastManager - WiFi 不可用，取消自动重启");
            return;
        }
        
        NSLog(@"PLVCastManager - 将在 %d 秒后自动重启搜索服务", searchIntervalTime);
        [self createFutureEventWithTime:searchIntervalTime];
    } else {
        [self stopTimer];
    }
}

// 设置定时任务
- (void)createFutureEventWithTime:(NSInteger)time{
    [self stopTimer];
    
    if (self.delegate == nil) {
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timeEvent:) userInfo:nil repeats:NO];
}

- (void)stopTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

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
    } else if(timer.timeInterval == searchIntervalTime) { // 搜索间隔时间任务
        if ([[self class] wifiCanUse]) {
            [self startSearchService];
        } else {
            NSLog(@"PLVCastManager - WiFi不可用，自动启动搜索任务不执行");
        }
    }
}

// 播放状态轮询定时器
- (void)startGetPositionInfoTimer {
    if (self.getPositionInfoTimer) {
        [self stopGetPositionInfoTimer];
    }
    self.getPositionInfoTimer = [NSTimer scheduledTimerWithTimeInterval:getPostionTimer target:self selector:@selector(getPositionInfoTimerEvent:) userInfo:nil repeats:YES];
    [self.getPositionInfoTimer fire];
}

- (void)stopGetPositionInfoTimer {
    if (_getPositionInfoTimer) {
        [_getPositionInfoTimer invalidate];
        _getPositionInfoTimer = nil;
    }
}

- (void)getPositionInfoTimerEvent:(NSTimer *)timer {
    if (self.delegate == nil) {
        [self stopGetPositionInfoTimer];
        return;
    }
    if (self.dlnaRender == nil) {
        return;
    }
    // 在后台不执行网络请求
    if (self.isInBackground) {
        return;
    }
    [self.dlnaRender getPositionInfo];
    // 同时获取播放状态，以便检测电视端的播放/暂停操作
    [self.dlnaRender getTransportInfo];
}

- (PLVUPnPDevice *)getOriginalDeviceInfoWithPlvServiceModel:(PLVCastServiceModel *)plv_service{
    for (PLVUPnPDevice *device in self.dl_serviceArr) {
        if ([device.uuid isEqualToString:plv_service.uuid]) return device;
    }
    return nil;
}

- (PLVCastServiceModel *)getPlvServiceInfoWithOriginalDeviceModel:(PLVUPnPDevice *)ld_Device {
    for (PLVCastServiceModel *service in self.plv_serviceArr) {
        if ([service.uuid isEqualToString:ld_Device.uuid]) return service;
    }
    return nil;
}

- (void)refreshAndCallBackServicesInfoWithOriginalServicesInfoArray:(NSArray<PLVUPnPDevice *> *)devices{
    self.dl_serviceArr = devices;
    [self.plv_serviceArr removeAllObjects];
    for (PLVUPnPDevice *dl_device in devices) {
        PLVCastServiceModel *plv_service = [[PLVCastServiceModel alloc]init];
        plv_service.serviceName = dl_device.friendlyName;
        plv_service.uuid = dl_device.uuid;
        plv_service.isConnecting = [self.dlnaRender.device.uuid isEqualToString:dl_device.uuid];
        [self.plv_serviceArr addObject:plv_service];
    }
    if ([self.delegate respondsToSelector:@selector(plvCastManager_findServices:)]) {
        [self.delegate plvCastManager_findServices:self.plv_serviceArr];
    }
}

#pragma mark - PLVFindDeviceDelegate
- (void)plv_UPnPDeviceChanged:(NSArray<PLVUPnPDevice *> *)devices {
    [self refreshAndCallBackServicesInfoWithOriginalServicesInfoArray:devices];
}

- (void)plv_UPnPDeviceFindFaild:(NSError *)error {
    // 在后台不处理设备搜索失败
    if (self.isInBackground) {
        NSLog(@"PLVCastManager - APP在后台，忽略设备搜索失败");
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(plvCastManager_castError:)]) {
        [self.delegate plvCastManager_castError:error];
    }
}

#pragma mark - PLVControlDeviceDelegate
- (void)plv_setAVTransportURLReponse {
    // 在后台不处理播放响应
    if (self.isInBackground) {
        NSLog(@"PLVCastManager - APP在后台，延迟处理 setAVTransportURLReponse");
        return;
    }
    
    [self.dlnaRender play];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakSelf.isInBackground) {
            [weakSelf startGetPositionInfoTimer];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!weakSelf.isInBackground && weakSelf.dlnaRender) {
            [weakSelf.dlnaRender getVolume];
        }
    });
}

- (void)plv_playResponse {
    [self postStatus:PLVCastPlayStatusPlaying];
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!weakSelf.isInBackground && weakSelf.startPosition != 0 && weakSelf.dlnaRender) {
            [weakSelf.dlnaRender seekToTime:weakSelf.startPosition];
            weakSelf.startPosition = 0;
        }
    });
}

- (void)plv_pauseResponse {
    [self postStatus:PLVCastPlayStatusPause];
}

- (void)plv_stopResponse {
    [self postStatus:PLVCastPlayStatusStopped];
}

- (void)plv_getVolumeResponse:(NSString *)volume {
    self.currentVolume = [volume integerValue];
}

- (void)plv_getTransportInfoResponse:(PLVUPnPTransportInfo *)transportInfo {
    // 收到正常响应，重置错误计数
    if (self.consecutiveErrorCount > 0) {
        NSLog(@"PLVCastManager - 收到 TransportInfo 正常响应，重置错误计数（之前:%ld次）", (long)self.consecutiveErrorCount);
        self.consecutiveErrorCount = 0;
    }
    
    // 在后台不处理播放状态更新
    if (self.isInBackground) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // 根据电视端的播放状态同步更新iOS端的播放按钮状态
        if ([transportInfo.currentTransportState isEqualToString:PLVUPnPTransportInfo_Status_Playing]) {
            [weakSelf postStatus:PLVCastPlayStatusPlaying];
        } else if ([transportInfo.currentTransportState isEqualToString:PLVUPnPTransportInfo_Status_Paused]) {
            [weakSelf postStatus:PLVCastPlayStatusPause];
        } else if ([transportInfo.currentTransportState isEqualToString:PLVUPnPTransportInfo_Status_Stopped]) {
            [weakSelf postStatus:PLVCastPlayStatusStopped];
        }
    });
}

- (void)plv_getPositionInfoResponse:(PLVUPnPAVPositionInfo *)info {
    // 收到正常响应，重置错误计数
    if (self.consecutiveErrorCount > 0) {
        NSLog(@"PLVCastManager - 收到 PositionInfo 正常响应，重置错误计数（之前:%ld次）", (long)self.consecutiveErrorCount);
        self.consecutiveErrorCount = 0;
    }
    
    // 在后台不处理播放进度更新
    if (self.isInBackground) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // 检测是否播放完成（当前时间 >= 总时长 - 1秒，考虑到精度问题）
        if (!weakSelf.hasReportedCompletion && info.trackDuration > 0 && info.relTime >= (info.trackDuration - 1)) {
            NSLog(@"PLVCastManager - 检测到播放完成 当前时间:%.2f 总时长:%.2f", info.relTime, info.trackDuration);
            weakSelf.hasReportedCompletion = YES;
            [weakSelf postStatus:PLVCastPlayStatusCommpleted];
        }
        
        if ([weakSelf.delegate respondsToSelector:@selector(plvCastManager_playTimeChangedWithCurrentTime:duration:)]) {
            if (weakSelf.currentServiceModel) weakSelf.currentServiceModel.currentTime = (NSTimeInterval)info.relTime;
            [weakSelf.delegate plvCastManager_playTimeChangedWithCurrentTime:(NSInteger)info.relTime duration:(NSInteger)info.trackDuration];
        }
    });
}

- (void)plv_undefinedResponse:(NSString *)responseXML {
    NSLog(@"PLVCastManager - 未响应的错误 %@", responseXML);
    
    // 如果APP在后台，不断开连接，等待前台恢复
    if (self.isInBackground) {
        NSLog(@"PLVCastManager - APP在后台，忽略网络错误，保持投屏连接");
        return;
    }
    
    // 增加错误计数（容错机制：用于处理乐播广告等暂时性网络中断场景）
    self.consecutiveErrorCount++;
    NSLog(@"PLVCastManager - 连续错误次数: %ld/%ld", (long)self.consecutiveErrorCount, (long)self.maxErrorThreshold);
    
    // 只有连续错误次数超过阈值才断开连接
    // 这样可以容忍乐播电视播放广告期间的暂时性网络中断
    if (self.consecutiveErrorCount < self.maxErrorThreshold) {
        NSLog(@"PLVCastManager - 错误次数未达到阈值，保持投屏连接，等待恢复（可能是乐播广告等场景）");
        return;
    }
    
    // 超过阈值，判定为真正的连接失败
    NSLog(@"PLVCastManager - 连续错误超过阈值，判定为连接失败，断开投屏");
    PLVCastServiceModel *plv_service = [self getPlvServiceInfoWithOriginalDeviceModel:self.dlnaRender.device];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf postStatus:PLVCastPlayStatusStopped];
        if ([weakSelf.delegate respondsToSelector:@selector(plvCastManager_connectServicesResult:serviceModel:passiveDisconnect:)]) {
            [weakSelf.delegate plvCastManager_connectServicesResult:NO serviceModel:plv_service passiveDisconnect:YES];
        }
    });
    
    [self stopGetPositionInfoTimer];
    [self disconnect];
}

- (void)postStatus:(PLVCastPlayStatus)status {
    if ([self.delegate respondsToSelector:@selector(plvCastManager_playStatusChangedWithStatus:)]) {
        [self.delegate plvCastManager_playStatusChangedWithStatus:status];
    }
}

@end

@implementation PLVCastServiceModel
@end

