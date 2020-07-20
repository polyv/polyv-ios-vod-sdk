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

// 定时器时间
// 两者不能一样 否则任务无法区分
#define searchSustainTime 5 // 搜索持续时间
#define searchIntervalTime 10 // 搜索间隔时间

@interface PLVCastManager ()<LBLelinkBrowserDelegate,LBLelinkConnectionDelegate,LBLelinkPlayerDelegate>

@property (nonatomic, strong) LBLelinkBrowser * lelinkBrowser;
@property (nonatomic, strong) LBLelinkConnection * lelinkConnection;
@property (nonatomic, strong) LBLelinkPlayer * lbplayer;

@property (nonatomic, strong) NSArray <LBLelinkService *>* lb_servicesArr;
@property (nonatomic, strong) NSMutableArray <PLVCastServiceModel *>* plv_servicesArr; // 转化后的投屏设备信息模型数组，仅保留需要的信息，来供给调用方读取

@property (nonatomic, copy) NSString * lastWiFiName; // 用于判断wifi是否变更

@property (nonatomic, strong) LBLelinkService * willBeDisconnectedService; // 即将断开的设备，用于判断是主动断开还是被动断开

@property (nonatomic, strong) NSTimer * timer;

@end

@implementation PLVCastManager


#pragma mark - ----------------- < Life Priord > -----------------
- (void)dealloc{
    if (_timer) {
        _timer.fireDate = NSDate.distantFuture;
        [_timer invalidate];
        _timer = nil;
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
    self.plv_servicesArr = [[NSMutableArray alloc]init];
}


#pragma mark - ----------------- < Getter > -----------------
- (LBLelinkBrowser *)lelinkBrowser{
    if (_lelinkBrowser == nil) {
        _lelinkBrowser = [[LBLelinkBrowser alloc]init];
        _lelinkBrowser.delegate = self;
    }
    return _lelinkBrowser;
}

- (LBLelinkConnection *)lelinkConnection{
    if (_lelinkConnection == nil) {
        _lelinkConnection = [[LBLelinkConnection alloc]init];
        _lelinkConnection.delegate = self;
    }
    return _lelinkConnection;
}

- (LBLelinkPlayer *)lbplayer{
    if (_lbplayer == nil) {
        _lbplayer = [[LBLelinkPlayer alloc]init];
        _lbplayer.delegate = self;
        _lbplayer.lelinkConnection = self.lelinkConnection;
    }
    return _lbplayer;
}


#pragma mark - ----------------- < Open Method > -----------------
+ (BOOL)authorizationInfoIsLegal{
    if (LBAPPID.length == 0 || LBSECRETKEY.length == 0) return NO;
    return YES;
}

+ (void)getCastAuthorization{
    if ([self authorizationInfoIsLegal] == NO) {
        NSLog(@"PLVCastManager - 注册信息不足，如需投屏功能，请在'PLVCastManager.h'中填写");
        return;
    }
    
    [LBLelinkKit enableLog:NO];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError * error = nil;
            BOOL result = [LBLelinkKit authWithAppid:LBAPPID secretKey:LBSECRETKEY error:&error];
            if (result) {
                NSLog(@"PLVCastManager - 授权成功");
            }else{
                NSLog(@"PLVCastManager - 授权失败：error = %@",error);
            }
        });
    });
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
    
    self.lb_servicesArr = nil;
    [self.plv_servicesArr removeAllObjects];
    self.willBeDisconnectedService = nil;
    
    // [self.lbplayer stop]; 无需停止播放
    [self.lelinkConnection disConnect];
    [self.lelinkBrowser stop];
    
    self.lbplayer.delegate = nil;
    self.lelinkConnection.delegate = nil;
    self.lelinkBrowser.delegate = nil;

    self.lbplayer = nil;
    self.lelinkConnection = nil;
    self.lelinkBrowser = nil;
}

- (PLVCastServiceModel *)currentServiceModel{
    LBLelinkService * lb_s = self.lelinkConnection.lelinkService;
    PLVCastServiceModel * plv_s = [self getPlvServiceInfoWithOriginalServiceModel:lb_s];
    return plv_s;
}

- (BOOL)connected{
    if (self.lelinkConnection.lelinkService) return YES;
    return NO;
}

#pragma mark 设备搜索操作
- (void)startSearchService{
    [self.lelinkBrowser searchForLelinkService];
    
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
    if (idx < self.plv_servicesArr.count) {
        PLVCastServiceModel * plv_s = self.plv_servicesArr[idx];
        [self connectServiceWithModel:plv_s];
        return plv_s;
    }
    return nil;
}

- (void)connectServiceWithModel:(PLVCastServiceModel *)plv_s{
    LBLelinkService * lb_s = [self getOriginalServiceInfoWithPlvServiceModel:plv_s];
    NSLog(@"PLVCastManager - 准备连接的设备 设备名 : %@, 接收端包名 : %@, 服务类型：%lu",lb_s.lelinkServiceName,lb_s.receviverPackageName,(unsigned long)lb_s.serviceType);
    
    // 若设备为空
    if (lb_s == nil) {
        if ([self.delegate respondsToSelector:@selector(plvCastManager_castError:)]) {
            [self.delegate plvCastManager_castError:nil];
        }
        return;
    }
    
    // 若所选设备和当前一致
    if (self.lelinkConnection.lelinkService == lb_s) {
        return;
    }
    
    // 若已连接其他设备
    if (self.lelinkConnection.lelinkService != nil) {
        // 提前保存即将断开的服务
        self.willBeDisconnectedService = self.lelinkConnection.lelinkService;
        
        [self stop];
        [self stop];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self disconnect];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectServiceWithModel:plv_s];
        });
        return;
    }
    
    self.lelinkConnection.lelinkService = lb_s;
    [self.lelinkConnection connect];
}

- (void)disconnect{
    self.willBeDisconnectedService = self.lelinkConnection.lelinkService;
    
    [self.lelinkConnection disConnect];
}

#pragma mark 设备播放操作
- (void)startPlayWithVideo:(PLVVodVideo *)video quality:(NSInteger)quality{
    
    NSString * urlString;
    if (video.keepSource) {
        urlString = video.play_source_url;
    }else{
        
        NSArray * urlArr;
        if(video.isPlain == YES && video.isHls == NO){
            urlArr = video.plainVideos;
        }else{
            urlArr = video.hlsVideos;
        }
        NSInteger idx = quality - 1;
        urlString = (urlArr.count > idx && idx >= 0) ? urlArr[idx] : @"";
        
    }
    
    if (urlString == nil || [urlString isKindOfClass: [NSString class]] == NO || urlString.length == 0) {
        NSLog(@"PLVCastManager - 播放链接非法 链接：%@",urlString);
        return;
    }
    
    // 创建播放内容对象
    LBLelinkPlayerItem * item = [[LBLelinkPlayerItem alloc] init];
    item.mediaType = LBLelinkMediaTypeVideoOnline;
    item.mediaURLString = urlString;
    NSString * versionInfo = [NSString stringWithFormat:@"PolyviOSScreencast%@",PLVVodSdkVersion];
    item.headerInfo = @{@"user-agent":versionInfo};

    if (video.keepSource || video.isPlain) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.lbplayer playWithItem:item];
        });
    }else{
        
        __weak typeof(self) weakSelf = self;
        [PLVVodPlayerUtil requestCastKeyIvWitVideo:video quality:quality completion:^(NSString * _Nullable key, NSString * _Nullable iv, NSError * _Nullable error) {
            if (error == nil) {
                if ((key == nil && iv == nil) == NO) {
                    item.aesModel = [LBPlayerAesModel new];
                    item.aesModel.model = @"1";
                    item.aesModel.key = key;
                    item.aesModel.iv = iv;
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    /** 注意，为了适配接收端的bug，播放之前先stop，否则当先推送音乐再推送视频的时候会导致连接被断开 */
                    [weakSelf.lbplayer stop];
                    [weakSelf.lbplayer playWithItem:item];
                });
            }else{
                NSLog(@"PLVCastManager - 投加密视频失败 ：%@",error);
            }
        }];
    }
}

- (void)pause{
    [self.lbplayer pause];
}

- (void)resume{
    [self.lbplayer resumePlay];
}

- (void)seekTo:(NSInteger)seekTime{
    [self.lbplayer seekTo:seekTime];
}

- (void)stop{
    [self.lbplayer stop];
}

- (void)addVolume{
    [self.lbplayer addVolume];
}

- (void)reduceVolume{
    [self.lbplayer reduceVolume];
}

- (void)setVolume:(NSInteger)value{
    [self.lbplayer setVolume:value];
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
    [self.lelinkBrowser stop]; // TODO 调用了stop也仍然会有回调出现
    
    // 回调搜索状态
    // TODO 若本方法被多次调用，则此处的回调也会被多次回调
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

// 通过plv设备模型，找到对应的lb设备模型
- (LBLelinkService *)getOriginalServiceInfoWithPlvServiceModel:(PLVCastServiceModel *)plv_s{
    NSInteger idx = [self.plv_servicesArr indexOfObject:plv_s];
    LBLelinkService * lb_s = nil;
    if (idx < self.lb_servicesArr.count) {
        lb_s = self.lb_servicesArr[idx];
    }
    if (lb_s == nil) NSLog(@"PLVCastManager - 警告：无法找到对应乐播设备信息模型 plv_s %@",plv_s);
    return lb_s;
}

// 通过lb设备模型，找到对应的plv设备模型
- (PLVCastServiceModel *)getPlvServiceInfoWithOriginalServiceModel:(LBLelinkService *)lb_s{
    NSInteger idx = [self.lb_servicesArr indexOfObject:lb_s];
    PLVCastServiceModel * plv_s = nil;
    if (idx < self.plv_servicesArr.count) {
        plv_s = self.plv_servicesArr[idx];
    }
    if (plv_s == nil) NSLog(@"PLVCastManager - 警告：无法找到对应Plv设备信息模型 lb_s %@",lb_s);
    return plv_s;
}

// 转化设备信息模型
- (void)setPlvServicesArrWithOriginalServicesArr:(NSArray<LBLelinkService *> *)lbServicesArr{
    [self.plv_servicesArr removeAllObjects];
    
    for (LBLelinkService * lb_s in lbServicesArr) {
        // 生成plv的设备信息模型
        PLVCastServiceModel * plv_s = [[PLVCastServiceModel alloc]init];
        plv_s.deviceName = lb_s.lelinkServiceName;
        plv_s.isConnecting = [self.lelinkConnection.lelinkService.tvUID isEqualToString:lb_s.tvUID];
        [self.plv_servicesArr addObject:plv_s];
    }
    
    self.lb_servicesArr = lbServicesArr;
    // NSLog(@"PLVCastManager - 设备信息数组已更新 设备数：%lu",(unsigned long)self.plv_servicesArr.count);
}

// 刷新及回调最新的设备信息
- (void)refreshAndCallBackServicesInfoWithOriginalServicesInfoArray:(NSArray<LBLelinkService *> *)services{
    // 刷新
    [self setPlvServicesArrWithOriginalServicesArr:services];
    
    // 回调
    if ([self.delegate respondsToSelector:@selector(plvCastManager_findServices:)]) {
        [self.delegate plvCastManager_findServices:self.plv_servicesArr];
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

#pragma mark - ----------------- < Delegate > -----------------
#pragma mark 设备搜索回调
- (void)lelinkBrowser:(LBLelinkBrowser *)browser
              onError:(NSError *)error {
    NSLog(@"PLVCastManager - 设备搜索报错 Error : %@",error);
}

- (void)lelinkBrowser:(LBLelinkBrowser *)browser
didFindLelinkServices:(NSArray<LBLelinkService *> *)services {
    /*
    if (services.count > 0) {
        NSLog(@"[");
        NSLog(@"PLVCastManager - 设备搜索回调 设备数 : %lu",(unsigned long)services.count);
        for (LBLelinkService * ser in services) {
            NSLog(@"PLVCastManager - 设备名 : %@, 接收端包名 : %@, 服务类型：%lu",ser.lelinkServiceName,ser.receviverPackageName,(unsigned long)ser.serviceType);
        }
        NSLog(@"]");
    }
    */

    [self refreshAndCallBackServicesInfoWithOriginalServicesInfoArray:services];
}

#pragma mark 设备连接回调
- (void)lelinkConnection:(LBLelinkConnection *)connection onError:(NSError *)error {
    if (error) {
        NSLog(@"PLVCastManager - 设备连接错误 %@",error);
        if ([self.delegate respondsToSelector:@selector(plvCastManager_castError:)]) {
            [self.delegate plvCastManager_castError:error];
        }
    }
}

- (void)lelinkConnection:(LBLelinkConnection *)connection
     didConnectToService:(LBLelinkService *)service {
    NSLog(@"PLVCastManager - 已连接到设备服务 设备%@ 设备名:%@",service,service.lelinkServiceName);
    
    PLVCastServiceModel * plv_s = [self getPlvServiceInfoWithOriginalServiceModel:service];
    
    if ([self.delegate respondsToSelector:@selector(plvCastManager_connectServicesResult:serviceModel:passiveDisconnect:)]) {
        [self.delegate plvCastManager_connectServicesResult:YES serviceModel:plv_s passiveDisconnect:NO];
    }
    
    if (self.lelinkConnection.lelinkService != service && service != nil) {
        self.lelinkConnection.lelinkService = service;
    }
}

- (void)lelinkConnection:(LBLelinkConnection *)connection
     disConnectToService:(LBLelinkService *)service {
    NSLog(@"PLVCastManager - 已断开与设备服务的连接 设备名：%@",service.lelinkServiceName);
    
    // 是否被动断开连接（因客观原因断开，非主动点击断开）
    BOOL isPassiveDisconnect = (self.willBeDisconnectedService == nil || [self.willBeDisconnectedService.tvUID isEqualToString:service.tvUID] == NO);
    
    PLVCastServiceModel * plv_s = [self getPlvServiceInfoWithOriginalServiceModel:service];
    
    if ([self.delegate respondsToSelector:@selector(plvCastManager_connectServicesResult:serviceModel:passiveDisconnect:)]) {
        [self.delegate plvCastManager_connectServicesResult:NO serviceModel:plv_s passiveDisconnect:isPassiveDisconnect];
    }
    
    // 清空
    self.willBeDisconnectedService = nil;
    if (self.lelinkConnection.lelinkService == service) {
        self.lelinkConnection.lelinkService = nil;
    }
}

#pragma mark 设备播放回调
- (void)lelinkPlayer:(LBLelinkPlayer *)player onError:(NSError *)error {
    if (error) {
        NSLog(@"PLVCastManager - 播放错误 %@",error);
    }
}

// 播放状态代理回调
- (void)lelinkPlayer:(LBLelinkPlayer *)player playStatus:(LBLelinkPlayStatus)playStatus {
    NSLog(@"PLVCastManager - 播放状态回调 %lu",(unsigned long)playStatus);
    
    if (self.lelinkConnection.lelinkService == self.willBeDisconnectedService) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(plvCastManager_playStatusChangedWithStatus:)]) {
        [self.delegate plvCastManager_playStatusChangedWithStatus:(PLVCastPlayStatus)playStatus];
    }
}

// 播放进度信息回调
- (void)lelinkPlayer:(LBLelinkPlayer *)player progressInfo:(LBLelinkProgressInfo *)progressInfo {
    if ([self.delegate respondsToSelector:@selector(plvCastManager_playTimeChangedWithCurrentTime:duration:)]) {
        [self.delegate plvCastManager_playTimeChangedWithCurrentTime:progressInfo.currentTime duration:progressInfo.duration];
    }
}

@end


@implementation PLVCastServiceModel


@end

