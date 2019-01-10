//
//  PLVCastServiceListView.h
//  PolyvVodSDKDemo
//
//  Created by Lincal on 2018/12/17.
//  Copyright © 2018 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVCastCellInfoModel;

// 元素类型
typedef NS_ENUM(NSInteger,PLVCastCellType) {
    PLVCastCellType_Tips,      // 提示
    PLVCastCellType_Device,    // 设备
    PLVCastCellType_AirPlay,   // AirPlay
    PLVCastCellType_Searching, // 搜索中
};

NS_ASSUME_NONNULL_BEGIN

@interface PLVCastServiceListView : UIView // 投屏设备选择列表视图

// 点击刷新列表按钮回调
@property (nonatomic, strong) void (^ refreshButtonClickEvent) (PLVCastServiceListView * listView, UIButton * button);

// 点选设备列表回调
@property (nonatomic, strong) void (^ selectEvent)(PLVCastServiceListView * listView, NSInteger index, PLVCastCellType type);

// 界面出现隐藏回调
@property (nonatomic, strong) void (^ listViewShowOrHideEvent) (BOOL isShow);

// 类型 用于横屏或竖屏 YES-用于横屏场景；NO-用于竖屏场景；默认横屏
@property (nonatomic, assign) BOOL landsOrVer;

// 是否展示提示语
@property (nonatomic, assign) BOOL showTips;

// 是否展示AirPlay选项
@property (nonatomic, assign) BOOL showAirPlayOption;

// 是否展示搜索中
@property (nonatomic, assign) BOOL showSearching;

// 设置WiFi名
@property (nonatomic, copy) NSString * wifiName;

// 刷新列表
- (void)reloadList;

// 刷新设备列表；传nil清空设备列表
- (void)reloadServicesListWithModelArray:(nullable NSArray <PLVCastCellInfoModel *>*)modelArray;

// 展示
- (void)show;

// 隐藏
- (void)dismiss;

// 点击刷新按钮
// 参数：YES - 目的是选中按钮; NO - 目的是取消选中按钮
// 但不会直接修改选中状态，参数仅表达目的，内部会做过滤操作
- (void)refreshBtnClickToSelected:(BOOL)toSelected;

// 开始刷新按钮转动
- (void)startRefreshBtnRotate;

// 停止刷新按钮转动
- (void)stopRefreshBtnRotate;

// 手动先让设备不再标蓝（标蓝色表示是当前所选投屏设备）
- (void)clearSelectedDevice;

@end


@interface PLVCastCellInfoModel : NSObject // 列表元素信息模型

// 元素类型
@property (nonatomic, assign) PLVCastCellType type;

// 提示内容
@property (nonatomic, copy) NSString * tips;

// 设备名
@property (nonatomic, copy) NSString * deviceName;

// 是否正在连接
@property (nonatomic, assign) BOOL isConnecting;

@end

NS_ASSUME_NONNULL_END
