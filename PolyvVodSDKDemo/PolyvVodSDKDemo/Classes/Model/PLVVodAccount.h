//
//  PLVVodAccount.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/6/1.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 加密串
extern NSString *PLVVodConfigString;

/// 加密密钥
extern NSString *PLVVodDecodeKey;

/// 加密向量
extern NSString *PLVVodDecodeIv;

/// 账号 secretkey
extern NSString *PLVVodSecretKey;

/// 账号 userid
extern NSString *PLVVodUserId;

/// 子账号 appid
extern NSString *PLVVodSubAccountAppId;

/// 子账号 secretkey
extern NSString *PLVVodSubAccountSecretKey;

@interface PLVVodAccount : NSObject

@end

NS_ASSUME_NONNULL_END
