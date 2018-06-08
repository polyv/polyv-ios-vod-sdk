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
/// 网校 ID
@property (nonatomic, copy) NSString *schoolId;
/// 网校 Key
@property (nonatomic, copy) NSString *schoolKey;

/// 点播加密串
@property (nonatomic, copy) NSString *vodKey;
/// 点播加密串解密秘钥
@property (nonatomic, copy) NSString *vodKeyDecodeKey;
/// 点播加密串解密向量
@property (nonatomic, copy) NSString *vodKeyDecodeIv;

/// 静态对象
+ (instancetype)sharedInstance;

@end
