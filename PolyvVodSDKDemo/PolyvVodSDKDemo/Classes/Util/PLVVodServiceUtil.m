//
//  PLVVodServiceUtil.m
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/8.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "PLVVodServiceUtil.h"
#import <PLVVodSDK/PLVVodSettings.h>
#import "NSString+PLVVod.h"

#define PLV_HTTP_POST @"POST"
#define PLV_HTTP_GET @"GET"

static NSString * const PLVVodNetworkingErrorDomain = @"net.polyv.vod.error.networking";

/// 请求参数字典 -> 文本
static NSString *paramStr(NSDictionary *paramDict) {
    NSArray *keys = paramDict.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    NSMutableString *paramStr = [NSMutableString string];
    for (int i = 0; i < keys.count; i ++) {
        NSString *key = keys[i];
        [paramStr appendFormat:@"%@=%@", key, paramDict[key]];
        if (i == keys.count - 1) break;
        [paramStr appendString:@"&"];
    }
    return paramStr;
}


@implementation PLVVodServiceUtil

+ (void)requestVideoListWithAccount:(NSString *)emailAccount
                             cataId:(NSString *)cataId
                            subCata:(NSString *)needSubCata
                          orderType:(NSString *)orderType
                          pageIndex:(NSString *)pageIndex
                      completeBlock:(void (^)(PLVUserVideoListResult * ))success
                          failBlock:(void (^)(NSError * ))fail
{
    PLVVodSettings *settings = [PLVVodSettings sharedSettings];
    
    NSString *url = [NSString stringWithFormat:@"https://api.polyv.net/v2/video/%@/get-by-uploader", settings.userid];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"userid"] = settings.userid;
    params[@"ptime"] = [self timestamp];
    
    if (emailAccount && emailAccount.length) params[@"email"] = emailAccount;
    if (cataId && cataId.length) params[@"cataid"] = cataId;
    if (needSubCata && needSubCata.length) params[@"containSubCata"] = needSubCata;
    if (orderType && orderType.length) params[@"orderType"] = orderType;
    if (pageIndex && pageIndex.length) params[@"page"] = pageIndex;
    
    // 生成签名数据
    NSArray *keys = params.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    NSMutableString *plainSign = [NSMutableString string];
    for (int i = 0; i < keys.count; i ++) {
        NSString *key = keys[i];
        [plainSign appendFormat:@"%@=%@", key, params[key]];
        if (i < keys.count-1) {
            [plainSign appendFormat:@"&"];
        }
    }
    plainSign = [NSMutableString stringWithFormat:@"%@%@", plainSign, settings.secretkey];
    params[@"sign"] = plainSign.sha1.uppercaseString;
    NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HTTP_GET params:params];
    [self requestDictionary:request completion:^(NSDictionary *dic, NSError *error) {
        NSInteger code = [dic[@"code"] integerValue];
        if (code != 200) {
            NSString *status = dic[@"status"];
            NSString *message = dic[@"message"];
            NSLog(@"%@, %@", status, message);
            
            if (fail){
                fail (error);
            }
            
            return;
        }
        
        // 结果解析
        NSDictionary *respData = [dic objectForKey:@"data"];
        if (respData){
            PLVUserVideoListResult *videoList = [[PLVUserVideoListResult alloc] initWithDic:respData];
            if (success){
                success (videoList);
            }
        }
        else{
            if (success){
                success (nil);
            }
        }
    }];
}

+ (void)requestPlayTimesWithVids:(NSArray<NSString *> *)vids
                        realTime:(NSString *)realTime
                   completeBlock:(void (^)(NSArray<PLVVideoPlayTimesResult *> * ))success
                       failBlock:(void (^)(NSError * ))fail
{
    // 1 参数检查
    if (vids.count ==0){
        if (fail){
            
            NSError *error = [NSError errorWithDomain:PLVVodNetworkingErrorDomain
                                                 code:1
                                              userInfo:@{NSLocalizedFailureReasonErrorKey:@"vids 参数错误"}];
            fail (error);
        }
    }
    PLVVodSettings *settings = [PLVVodSettings sharedSettings];
    NSString *url = [NSString stringWithFormat:@"http://api.polyv.net/v2/data/%@/play-times", settings.userid];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"ptime"] = [self timestamp];
    if ([realTime integerValue] > 0){
        params[@"realTime"] = @"1";
    }
    else{
        params[@"realTime"] = @"0";
    }
    
    NSMutableString *strVids = [[NSMutableString alloc] init];
    for (int i=0; i<vids.count; i++) {
        [strVids appendString:vids[i]];
        if (i != vids.count-1){
            [strVids appendString:@","];
        }
    }
    params[@"vids"] = strVids;
    
    // 生成签名数据
    NSArray *keys = params.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    NSMutableString *plainSign = [NSMutableString string];
    for (int i = 0; i < keys.count; i ++) {
        NSString *key = keys[i];
        [plainSign appendFormat:@"%@=%@", key, params[key]];
        if (i < keys.count-1) {
            [plainSign appendFormat:@"&"];
        }
    }
    plainSign = [NSMutableString stringWithFormat:@"%@%@", plainSign, settings.secretkey];
    params[@"sign"] = plainSign.sha1.uppercaseString;
    
    NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HTTP_GET params:params];
    [self requestDictionary:request completion:^(NSDictionary *dic, NSError *error) {
        NSInteger code = [dic[@"code"] integerValue];
        if (code != 200) {
            NSString *status = dic[@"status"];
            NSString *message = dic[@"message"];
            NSLog(@"%@, %@", status, message);
            
            if (fail){
                fail (error);
            }
            
            return;
        }
        
        // 结果解析
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
            
            if (success){
                success (list);
            }
        }
        else{
            if (success){
                success(nil);
            }
        }
       
    }];
}

#pragma public

/// 快速生成Request
+ (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)HTTPMethod params:(NSDictionary *)paramDic {
    NSString *urlString = url.copy;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if (paramDic.count) {
        NSString *parameters = paramStr(paramDic);
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

+ (void)requestDictionary:(NSURLRequest *)request completion:(void (^)(NSDictionary *dic, NSError *error))completion {
    [self requestData:request completion:^(NSData *data, NSError *error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error){
            NSLog(@"JSONReading error = %@", error.localizedDescription);
            //if (PLVNetworkingLogEnable)
            NSLog(@"%@ - 请求结果 = \n%@", request.URL, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            if (completion) completion(nil, error);
            return;
        }
        NSLog(@"%@ - 请求结果 = %@", request.URL, responseDic);
        if (completion) completion(responseDic, nil);
    }];
}

/// 异步获取数据
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
            if (completion) completion(data, error);
        }
    }] resume];
}

#pragma mark -- tool
/// 时间戳
+ (NSString *)timestamp {
    NSInteger timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    return @(timeInterval).description;
}

@end
