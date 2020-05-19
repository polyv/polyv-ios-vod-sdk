//
//  PLVVodDanmu+PLVVod.h
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/11/29.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#if __has_include(<PLVVodDanmu/PLVVodDanmu.h>)
#import <PLVVodDanmu/PLVVodDanmu.h>
#else
#import "PLVVodDanmu.h"
#endif

@interface PLVVodDanmu (PLVVod)

/// 发送弹幕
- (void)sendDammuWithVid:(NSString *)vid completion:(void (^)(NSError *error, NSString * danmuId))completion;

/// 加载弹幕
+ (void)requestDanmusWithVid:(NSString *)vid completion:(void (^)(NSArray<PLVVodDanmu *> *danmus, NSError *error))completion;

@end
