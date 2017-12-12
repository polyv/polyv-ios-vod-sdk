//
//  PLVSchool.h
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVSchool : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *schoolId;
@property (nonatomic, copy) NSString *schoolKey;
@property (nonatomic, copy) NSString *appSecretKey;
@property (nonatomic, copy) NSString *vodKey;
@property (nonatomic, copy) NSString *vodKeyDecodeKey;
@property (nonatomic, copy) NSString *vodKeyDecodeIv;

/// 静态对象
+ (instancetype)sharedInstance;

@end
