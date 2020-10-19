//
//  PLVVodNetworkUtil.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/6/13.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import "PLVVodNetworkUtil.h"
#import "NSString+PLVVod.h"
#import <PLVVodSDK/PLVVodSettings.h>

NSString *PLVVodNetworkingErrorDomain = @"net.polyv.vod.error.networking";

@implementation PLVVodNetworkUtil

+ (void)requestData:(NSURLRequest *)request
            success:(void (^)(NSDictionary *dic))successHandler
            failure:(void (^)(NSError *error))failureHandler {
    [PLVVodNetworkUtil requestData:request completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            !failureHandler ?: failureHandler(error);
            return;
        }
        
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error){
            NSLog(@"JSONReading error = %@", error.localizedDescription);
            NSLog(@"%@ - 请求结果 = \n%@", request.URL, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            !failureHandler ?: failureHandler(error);
            return;
        }
        
        NSInteger code = [responseDic[@"code"] integerValue];
        if (code != 200) {
            NSString *status = responseDic[@"status"];
            NSString *message = responseDic[@"message"];
            NSLog(@"%@, %@", status, message);
            !failureHandler ?: failureHandler(nil);
            return;
        }
        
        !successHandler ?: successHandler(responseDic);
    }];
}

+ (void)requestData:(NSURLRequest *)request completion:(void (^)(NSData *data, NSError *error))completion {
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger httpStatusCode = httpResponse.statusCode;
        if (error) { // 网络错误
            if (completion) completion(nil, error);
            NSLog(@"网络错误: %@", error);
        } else if (httpStatusCode != 200) { // 服务器错误
            NSString *errorMessage = [NSString stringWithFormat:@"服务器响应失败，状态码:%zd",httpResponse.statusCode];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
            NSError *serverError = [NSError errorWithDomain:PLVVodNetworkingErrorDomain code:httpStatusCode userInfo:userInfo];
            if (completion) completion(nil, serverError);
            NSLog(@"%@，服务器错误: %@", request.URL.absoluteString, serverError);
        } else {
            if (completion) completion(data, nil);
        }
    }] resume];
}

+ (NSDictionary *)addSign:(NSDictionary *)params {
    NSMutableDictionary *resultParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    
    NSString *paramString = [self convertDictionaryToSortedString:params];
#ifdef PLVSupportSubAccount
    NSMutableString *plainSign = [NSMutableString stringWithFormat:@"%@%@", paramString, PLVVodSecretKey];
#else
    NSMutableString *plainSign = [NSMutableString stringWithFormat:@"%@%@", paramString, [PLVVodSettings sharedSettings].secretkey];

#endif
    resultParams[@"sign"] = plainSign.sha1.uppercaseString;
    return [resultParams copy];
}

+ (NSString *)convertDictionaryToSortedString:(NSDictionary *)params {
    NSArray *keys = [params allKeys];
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    NSMutableString *paramStr = [NSMutableString string];
    for (int i = 0; i < keys.count; i ++) {
        NSString *key = keys[i];
        [paramStr appendFormat:@"%@=%@", key, params[key]];
        if (i == keys.count - 1) break;
        [paramStr appendString:@"&"];
    }
    return [paramStr copy];
}

@end
