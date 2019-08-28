//
//  PLVVodServiceUtil.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/8.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodServiceUtil.h"
#import "PLVNetworkUtil.h"
#import <PLVVodSDK/PLVVodSettings.h>
#import "NSString+PLVVod.h"

#define PLV_HTTP_POST @"POST"
#define PLV_HTTP_GET @"GET"

@implementation PLVVodServiceUtil

+ (void)requestVideoListWithAccount:(NSString *)emailAccount
                             cataId:(NSString *)cataId
                            subCata:(NSString *)needSubCata
                          orderType:(NSString *)orderType
                          pageIndex:(NSString *)pageIndex
                      completeBlock:(void (^)(PLVUserVideoListResult * ))success
                          failBlock:(void (^)(NSError * ))fail {
    
    NSString *url = [NSString stringWithFormat:@"https://api.polyv.net/v2/video/%@/get-by-uploader",
                     [PLVVodSettings sharedSettings].userid];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = [PLVVodSettings sharedSettings].userid;
    params[@"ptime"] = [self timestamp];
    
    if (emailAccount && emailAccount.length) params[@"email"] = emailAccount;
    if (cataId && cataId.length) params[@"cataid"] = cataId;
    if (needSubCata && needSubCata.length) params[@"containSubCata"] = needSubCata;
    if (orderType && orderType.length) params[@"orderType"] = orderType;
    if (pageIndex && pageIndex.length) params[@"page"] = pageIndex;
    
    NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HTTP_GET params:[PLVNetworkUtil addSign:params]];
    [PLVNetworkUtil requestData:request success:^(NSDictionary * _Nonnull dic) {
        NSDictionary *respData = [dic objectForKey:@"data"];
        PLVUserVideoListResult *videoList = respData ? [[PLVUserVideoListResult alloc] initWithDic:respData] : nil;
        !success ?: success(videoList);
    } failure:^(NSError *error) {
        !fail ?: fail(error);
    }];
}

+ (void)requestPlayTimesWithVids:(NSArray<NSString *> *)vids
                        realTime:(NSString *)realTime
                   completeBlock:(void (^)(NSArray<PLVVideoPlayTimesResult *> * ))success
                       failBlock:(void (^)(NSError * ))fail
{
    // 1 参数检查
    if (vids.count ==0 && fail){
        NSError *error = [NSError errorWithDomain:PLVVodNetworkingErrorDomain
                                             code:1
                                         userInfo:@{NSLocalizedFailureReasonErrorKey:@"vids 参数错误"}];
        fail (error);
    }
    NSString *url = [NSString stringWithFormat:@"http://api.polyv.net/v2/data/%@/play-times", [PLVVodSettings sharedSettings].userid];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"ptime"] = [self timestamp];
    params[@"realTime"] = ([realTime integerValue] > 0) ? @"1" : @"0";
    params[@"vids"] = [self stringWithVids:vids];
    
    NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HTTP_GET params:[PLVNetworkUtil addSign:params]];
    [PLVNetworkUtil requestData:request success:^(NSDictionary * _Nonnull dic) {
        id respData = [dic objectForKey:@"data"];
        if ([respData isKindOfClass:[NSArray class]]){
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:0];
            NSArray *respArray = respData;
            [respArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSDictionary *item = obj;
                PLVVideoPlayTimesResult *model = [[PLVVideoPlayTimesResult alloc] initWithDic:item];
                if (model){
                    [list addObject:model];
                }
            }];
            !success ?: success(list);
        } else {
            !success ?: success(nil);
        }
    } failure:^(NSError *error) {
        !fail ?: fail(error);
    }];
}

#pragma public

/// 快速生成Request
+ (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)HTTPMethod params:(NSDictionary *)paramDic {
    NSString *urlString = url.copy;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if (paramDic.count) {
        NSString *parameters = [PLVNetworkUtil convertDictionaryToSortedString:paramDic];
        if ([PLV_HTTP_GET isEqualToString:HTTPMethod]) {
            urlString = [NSString stringWithFormat:@"%@?%@", urlString, parameters];
        }else if ([PLV_HTTP_POST isEqualToString:HTTPMethod]){
            NSData *bodyData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
            request.HTTPBody = bodyData;
        }
    }
    
    NSURL *URL = [NSURL URLWithString:urlString];
    request.URL = URL;
    request.HTTPMethod = HTTPMethod;
    request.timeoutInterval = 10;
    NSLog(@"%@ - 参数列表 = %@\t%@\n\n", url, paramDic, urlString);
    
    //NSString *userAgent = [NSString stringWithFormat:@"polyv-ios-sdk_%@", PLVVodSdkVersion];
    //[request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    return request;
}

#pragma mark -- tool

+ (NSString *)stringWithVids:(NSArray<NSString *> *)vids {
    NSMutableString *strVids = [[NSMutableString alloc] init];
    for (int i=0; i<vids.count; i++) {
        [strVids appendString:vids[i]];
        if (i != vids.count-1){
            [strVids appendString:@","];
        }
    }
    return [strVids copy];
}

/// 时间戳
+ (NSString *)timestamp {
    long long timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    return @(timeInterval).description;
}

@end
