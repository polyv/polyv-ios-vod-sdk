//
//  PLVSchool.h
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVSchool : NSObject

/// 网校域名
@property (nonatomic, copy) NSString *host;
/// 网校 Key
@property (nonatomic, copy) NSString *schoolKey;

/// 静态对象
+ (instancetype)sharedInstance;

@end
