//
//  PolyvVodSDKDemo-Prefix.pch
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/7/26.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#ifndef PolyvVodSDKDemo_Prefix_pch
#define PolyvVodSDKDemo_Prefix_pch

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.

// UIScreen width.
#define PLV_ScreenWidth   [UIScreen mainScreen].bounds.size.width
// UIScreen height.
#define PLV_ScreenHeight  [UIScreen mainScreen].bounds.size.height
// iPhone X
#define PLV_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define PLV_iPhoneXR1 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define PLV_iPhoneXR2 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1624), [[UIScreen mainScreen] currentMode].size) : NO)
#define PLV_iPhoneXS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define PLV_iPhoneXsMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

#define PLV_iPhoneXSeries ({\
BOOL isPhoneX = NO;\
CGSize size = [UIScreen mainScreen].bounds.size;\
NSInteger notchValue = size.width / size.height * 100;\
if (notchValue == 216 || notchValue == 46) {\
    isPhoneX = YES;\
}\
isPhoneX;\
})

// 横屏时左右安全区域
#define PLV_Landscape_Left_And_Right_Safe_Side_Margin  44
// 横屏时底部安全区域
#define PLV_Landscape_Left_And_Right_Safe_Bottom_Margin  21
// 状态栏高度
#define PLV_StatusBarHeight ((PLV_iPhoneX || PLV_iPhoneXR) ? 44.f: 20.f)
// 状态栏+导航栏高度

#define PLV_StatusAndNaviBarHeight (PLV_iPhoneXSeries ? 88.f: 64.f)
// 各个机型最小逻辑分辨率宽度
#define PLV_Min_ScreenWidth 320
#define PLV_Max_ScreenWidth 414

// 支持多账号下载
#ifndef PLVSupportMultiAccount
//#define PLVSupportMultiAccount
#endif

// 支持音频文件下载
#ifndef PLVSupportDownloadAudio
//#define PLVSupportDownloadAudio
#endif

// 支持子账号配置,默认不支持
#ifndef PLVSupportSubAccount
//#define PLVSupportSubAccount
#endif

// 支持自定义问答功能
#ifndef PLVSupportCustomQuestion
//#define PLVSupportCustomQuestion
#endif

// 支持三分屏播放，默认不支持
#ifndef PLVSupportPPTScreen
#define PLVSupportPPTScreen
#endif

// 投屏功能
#ifndef PLVCastFeature
#define PLVCastFeature
#endif

#endif /* PolyvVodSDKDemo_Prefix_pch */
