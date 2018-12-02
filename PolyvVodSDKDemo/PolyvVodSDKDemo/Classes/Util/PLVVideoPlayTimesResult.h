//
//  PLVVideoPlayTimesResult.h
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/12.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVideoPlayTimesResult : NSObject

@property (nonatomic, copy) NSString *vid;
@property (nonatomic, copy) NSString *times;

- (instancetype)initWithDic:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
