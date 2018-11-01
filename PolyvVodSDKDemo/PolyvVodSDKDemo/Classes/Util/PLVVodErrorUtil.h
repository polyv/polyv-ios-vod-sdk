//
//  PLVVodErrorUtil.h
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PLVVodSDK/PLVVodConstans.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodErrorUtil : NSObject

/// 根据错误码获取错误提示信息
+ (NSString *)getErrorMsgWithCode:(PLVVodErrorCode )errorCod;

@end

NS_ASSUME_NONNULL_END
