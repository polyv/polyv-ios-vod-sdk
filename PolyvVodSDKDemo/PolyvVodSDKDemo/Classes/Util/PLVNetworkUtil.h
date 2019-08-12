//
//  PLVNetworkUtil.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/6/13.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *PLVVodNetworkingErrorDomain;

NS_ASSUME_NONNULL_BEGIN

@interface PLVNetworkUtil : NSObject

+ (void)requestData:(NSURLRequest *)request
            success:(void (^)(NSDictionary *dic))successHandler
            failure:(nullable void (^)(NSError * __nullable error))failureHandler;

+ (void)requestData:(NSURLRequest *)request
         completion:(nullable void (^)(NSData * __nullable data, NSError * __nullable error))completion;

+ (NSDictionary *)addSign:(NSDictionary *)params;

+ (NSString *)convertDictionaryToSortedString:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
