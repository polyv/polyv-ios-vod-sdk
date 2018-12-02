//
//  PLVVideoPlayTimesResult.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/12.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVideoPlayTimesResult.h"

@implementation PLVVideoPlayTimesResult

- (instancetype)initWithDic:(NSDictionary *)dict{
    if (self = [super init]){
        
        _vid = [NSString stringWithFormat:@"%@", dict[@"vid"]];
        _times = [NSString stringWithFormat:@"%@", dict[@"times"]];
    }
    
    return self;
}

@end
