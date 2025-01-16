//
//  PLVVodHeatMapModel.h
//  PolyvVodSDKDemo
//
//  Created by polyv on 2025/1/6.
//  Copyright © 2025 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodHeatMapModel : NSObject

/// 一个数据节点代表的时长, 默认5秒
@property (nonatomic, assign) CGFloat defautDuration ;
/// 视频总时长
@property (nonatomic, assign) CGFloat totalVideoDuration;
/// 数据节点集合
@property (nonatomic, strong) NSMutableArray<NSNumber *> *dataPoints;

+ (instancetype)defaultTestData;

@end

NS_ASSUME_NONNULL_END
