//
//  PLVVodMarkerViewData.h
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/1/6.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodMarkerViewData : NSObject

/// 时间位置
@property (nonatomic, assign) CGFloat time;
/// 视频总时长
@property (nonatomic, assign) CGFloat totalVideoTime;
/// 文本标题
@property (nonatomic, copy) NSString *title;
/// 气泡背景
@property (nonatomic, copy) NSString *color;
@property (nonatomic, assign) CGFloat colorAlpha;

// defaut test data
+(NSArray *)defautMarkerViewData;

@end

NS_ASSUME_NONNULL_END
