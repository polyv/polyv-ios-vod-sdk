//
//  PLVCastBusinessManager.m
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2019/1/7.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVCastBusinessManager.h"

#import "PLVVodPlayerSkin.h"
#import "PLVCastControllView.h"
#import "PLVCastServiceListView.h"

@interface PLVCastBusinessManager () <PLVCastManagerDelegate,PLVCastControllViewDelegate>

@property (nonatomic, weak, readwrite) UIView * listPlaceholderView;
@property (nonatomic, weak, readwrite) PLVVodPlayerViewController * player;

@property (nonatomic, strong, readwrite) PLVCastManager * castManager;// 投屏管理器
@property (nonatomic, strong) PLVCastServiceListView * castListV;     // 投屏设备列表选择
@property (nonatomic, strong) PLVCastControllView * castControllView; // 投屏操作界面

@end

@implementation PLVCastBusinessManager

- (void)dealloc{
    NSLog(@"PLVCastBusinessManager - [[[ Had Dealloc ]]]");
}

#pragma mark - ----------------- < Private Method > -----------------
- (void)setupCastServiceListView{
    PLVCastServiceListView * castListV = [[PLVCastServiceListView alloc]initWithFrame:self.listPlaceholderView.bounds];
    castListV.wifiName = [PLVCastManager getWifiName];
    castListV.landsOrVer = NO;
    castListV.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.listPlaceholderView addSubview:castListV];
    self.castListV = castListV;
    
    __weak typeof (self) weakSelf = self;
    // 事件
    // 选中设备
    castListV.selectEvent = ^(PLVCastServiceListView * listView, NSInteger index, PLVCastCellType type) {
        
        if (type == PLVCastCellType_Device) {
            [weakSelf.player pause];
            
            [listView refreshBtnClickToSelected:NO];
            
            [listView dismiss];
            
            PLVCastServiceModel * plv_s = [weakSelf.castManager connectServiceWithIndex:index];
            
            if (plv_s.isConnecting) {
                return;
            }
            
            [weakSelf.castControllView show];
            
            weakSelf.castControllView.deviceName = plv_s.deviceName;
            weakSelf.castControllView.status = PLVCastCVStatus_Connecting;
            [weakSelf.castControllView reloadControllBtnWithStringArray:@[@"2:退出",@"3:换设备"]];
            
            // 设置投屏控制视图代理
            // TODO 如果一直没有建立连接，则回调是一直不通的，因为没有设置delegate
            if (weakSelf.castControllView.delegate != weakSelf) {
                weakSelf.castControllView.delegate = weakSelf;
            }
        }        
    };
    
    // 点击‘刷新’按钮
    castListV.refreshButtonClickEvent = ^(PLVCastServiceListView * _Nonnull listView, UIButton * _Nonnull button) {
        BOOL WiFiCanUse = [PLVCastManager wifiCanUse];
        
        if (button.selected == YES) {  // 停止搜索
            [weakSelf.castManager stopSearchService];
        }else{
            
            if (WiFiCanUse == NO) { // 直接返回不处理
                return;
            }else{                  // 刷新
                [weakSelf.castManager startSearchService];
            }
            
        }
    };
    
    // 视图出现隐藏回调
    castListV.listViewShowOrHideEvent = ^(BOOL isShow) {
        
        if (isShow) {
            
            [weakSelf.castListV refreshBtnClickToSelected:YES];
            
        }else{
            PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)weakSelf.player.playerControl;
            skin.castButton.selected = NO;
            skin.castButtonInFullScreen.selected = NO;
            
            [weakSelf.castListV refreshBtnClickToSelected:NO];
            
            [weakSelf.castManager stopSearchService];
        }
        
    };
    
}

- (void)setupCastControllView{
    PLVCastControllView * cv = [[PLVCastControllView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.player.view.bounds), CGRectGetHeight(self.player.view.bounds))];
    cv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.player.view addSubview:cv];
    self.castControllView = cv;
}

#pragma mark - ----------------- < Open Method > -----------------
- (instancetype)initCastBusinessWithListPlaceholderView:(UIView *)listPlaceholderView player:(PLVVodPlayerViewController *)player{
    if (self = [super init]) {
        self.listPlaceholderView = listPlaceholderView;
        self.player = player;
    }
    return self;
}

- (void)setup{

    if (self.player.videoCaptureProtect) {
        NSLog(@"PLVCastBusinessManager - 警告：播放器防录屏功能已开启，保利威投屏模块将不可用");
        return;
    }
    
    // 投屏管理器
    self.castManager = [PLVCastManager shareManager];
    self.castManager.delegate = self;
    
    // 投屏设备列表选择
    [self setupCastServiceListView];
    
    // 投屏操作界面
    [self setupCastControllView];
    
    // 皮肤点击投屏按钮事件
    __weak typeof (self) weakSelf = self;
    PLVVodPlayerSkin * skin = (PLVVodPlayerSkin *)self.player.playerControl;
    skin.castButtonTouchHandler = ^(UIButton *button) {
        [weakSelf.castListV show];
        
        if ([PLVCastManager wifiCanUse]) {
            weakSelf.castListV.showAirPlayOption = YES;
            
            [weakSelf.castListV refreshBtnClickToSelected:YES];
        }else{
            [weakSelf.castListV refreshBtnClickToSelected:NO];
        }
        
    };
    
}

+ (void)getCastAuthorization{
    [PLVCastManager getCastAuthorization];
}

+ (BOOL)authorizationInfoIsLegal{
    return [PLVCastManager authorizationInfoIsLegal];
}

- (void)quitAllFuntionc{
    [self.castManager quitAllFuntionc];
}

#pragma mark - ----------------- < Delegate - 投屏管理器 > -----------------
// 设备搜索发现设备回调
- (void)plvCastManager_findServices:(NSArray<PLVCastServiceModel *> *)servicesArray{
    
    if (servicesArray.count == 0) return;
    
    NSMutableArray <PLVCastCellInfoModel *> * mArr = [[NSMutableArray alloc]init];
    for (PLVCastServiceModel * plv_s in servicesArray) {
        PLVCastCellInfoModel * m = [[PLVCastCellInfoModel alloc]init];
        m.type = PLVCastCellType_Device;
        m.deviceName = plv_s.deviceName;
        m.isConnecting = plv_s.isConnecting;
        [mArr addObject:m];
    }
    
    [self.castListV reloadServicesListWithModelArray:mArr];
}

// 设备搜索状态变更回调
- (void)plvCastManager_searchStateHadChanged:(BOOL)searchIsStart{
    if (searchIsStart == NO) { // 搜索已停止
        self.castListV.showSearching = NO;
        
        [self.castListV stopRefreshBtnRotate];
        
        [self.castListV reloadList];
        
    }else{                    // 搜索已启动
        
        self.castListV.showSearching = YES;
        
        [self.castListV startRefreshBtnRotate];
        
        [self.castListV reloadList];
        
    }
    
}

// 设备连接错误回调
- (void)plvCastManager_castError:(NSError *)error{
    self.castControllView.status = PLVCastCVStatus_Error;
}

// 设备连接状态回调
- (void)plvCastManager_connectServicesResult:(BOOL)isConnected serviceModel:(nonnull PLVCastServiceModel *)serviceModel passiveDisconnect:(BOOL)isPassiveDisconnect{
    
    if (isConnected) {
        NSInteger quality = self.player.quality;
        quality = quality == 0 ? (quality + 1) : quality; // 若自动档则+1流畅
        
        PLVVodVideo * video = self.player.video;
        if ([video isKindOfClass: [PLVVodLocalVideo class]]){ // 需先读取到video模型缓存
            __weak typeof(self) weakSelf = self;
            [PLVVodVideo requestVideoPriorityCacheWithVid:video.vid completion:^(PLVVodVideo *video, NSError *error) {
                // 开始投屏
                [weakSelf.castManager startPlayWithVideo:video quality:quality];
                
                // 设置清晰度数量 初始所选清晰度
                weakSelf.castControllView.qualityOptionCount =  video.hlsVideos.count;
                weakSelf.castControllView.currentQualityIndex = quality;
            }];
        }else{ // 无需读取video模型缓存
            // 开始投屏
            [self.castManager startPlayWithVideo:video quality:quality];
            
            // 设置清晰度数量 初始所选清晰度
            self.castControllView.qualityOptionCount = self.player.video.hlsVideos.count;
            self.castControllView.currentQualityIndex = quality;
        }
        
    }else{
        
        if (isPassiveDisconnect) { // 被动断开
            
            // 更新投屏控制界面状态
            self.castControllView.status = PLVCastCVStatus_Disconnect;
            
        }
        
    }
}

// WiFi变更回调
- (void)plvCastManager_WiFiDidChanged:(nullable NSString *)wifiName didChanged:(BOOL)didChanged{
    
    if (didChanged) {
        self.castListV.wifiName = wifiName;
        
        if (wifiName == nil) { // WiFi不可用 AirPlay隐藏
            self.castListV.showAirPlayOption = NO;
            
            [self.castListV refreshBtnClickToSelected:NO];
            
            [self.castListV reloadServicesListWithModelArray:nil];
        }else{                 // WiFi可用
            self.castListV.showAirPlayOption = YES;
            
            [self.castListV refreshBtnClickToSelected:YES];
        }
        
    }
}

// 播放状态变更回调
- (void)plvCastManager_playStatusChangedWithStatus:(PLVCastPlayStatus)status{
    PLVCastControllViewCastStatus plvCastCV_status = PLVCastCVStatus_Unknown;
    if (status == PLVCastPlayStatusUnkown) plvCastCV_status = PLVCastCVStatus_Unknown;
    
    if (status == PLVCastPlayStatusPlaying) {
        plvCastCV_status = PLVCastCVStatus_Casting;
        
        // 更新投屏控制视图
        self.castControllView.playBtn.selected = YES;
        self.castControllView.deviceName = [self.castManager currentServiceModel].deviceName;
        
        [self.castControllView reloadControllBtnWithStringArray:@[@"3:换设备",@"2:退出",@"1:清晰度"]];
    }
    
    if (status == PLVCastPlayStatusPause ||
        status == PLVCastPlayStatusStopped) {
        // 更新投屏控制视图
        self.castControllView.playBtn.selected = NO;
        
        if (status == PLVCastPlayStatusStopped &&
            (self.castControllView.status == PLVCastCVStatus_Connecting ||
             self.castControllView.status == PLVCastCVStatus_Unknown)) {
                // 若回调播放停止，且当前状态处于未知状态、连接中，则状态提示更新为投屏失败
                plvCastCV_status = PLVCastCVStatus_Disconnect;
                
                // 1.5秒后自动断开连接
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self plvCastControllView_quitButtonClick];
                });
            }
    }
    
    if (status == PLVCastPlayStatusCommpleted) {
        plvCastCV_status = PLVCastCVStatus_Complete;
        
        [self plvCastControllView_quitButtonClick];
    }
    
    self.castControllView.status = plvCastCV_status;
}

// 播放进度改变回调
- (void)plvCastManager_playTimeChangedWithCurrentTime:(NSInteger)currentTime duration:(NSInteger)duration{
    [self.castControllView refreshTimeLabelWithCurrentTime:currentTime duration:duration];
}

#pragma mark - ----------------- < Delegate - 投屏控制 > -----------------
- (void)plvCastControllView_deviceButtonClick {
    [self.castListV show];
}

- (void)plvCastControllView_quitButtonClick {
    [self.castManager stop];
    
    [self.castManager disconnect];
    
    [self.castControllView hide];
    
    [self.player play];
    
    [self.castListV dismiss];
    
    [self.castListV clearSelectedDevice];
}

- (void)plvCastControllView_volumeAddButtonClick {
    [self.castManager addVolume];
}

- (void)plvCastControllView_volumeMinusButtonClick {
    [self.castManager reduceVolume];
}

- (void)plvCastControllView_sliderValueChanged:(UISlider *)slider{
    [self.castManager seekTo:(self.player.video.duration * slider.value)];
}

- (void)plvCastControllView_playButtonClick:(UIButton *)button{
    if (button.selected) { // 播放
        [self.castManager resume];
    }else{                 // 暂停
        [self.castManager pause];
    }
}

- (void)plvCastControllView_fullScreenButtonClick:(UIButton *)button{
    [self.player.playerControl.fullShrinkscreenButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

// 播放清晰度改变
- (void)plvCastControllView_qualityChangeWithIndex:(NSInteger)index{
    
    if ((index - 1) >= self.player.video.hlsVideos.count) {
        return;
    }
    
    // 暂停播放
    [self.castManager stop];
    
    NSInteger quality = index;
    quality = quality == 0 ? (quality + 1) : quality; // 若自动档则+1流畅
    
    // 投屏新视频
    [self.castManager startPlayWithVideo:self.player.video quality:quality];
}


@end
