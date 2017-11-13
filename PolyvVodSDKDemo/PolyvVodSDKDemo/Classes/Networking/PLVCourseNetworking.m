//
//  PLVCourseNetworking.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseNetworking.h"
#import "PLVSchool.h"
#import <CommonCrypto/CommonDigest.h>

#define PLV_HM_POST @"POST"
#define PLV_HM_GET @"GET"

static BOOL PLVNetworkingLogEnable;
NSString * const PLVVodNetworkingErrorDomain = @"net.polyv.vod.error.networking";

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

@implementation PLVCourseNetworking

#pragma mark - tool

/// MD5 加密
+ (NSString *)md5String:(NSString *)inputString {
	const char* str = [inputString UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (CC_LONG)strlen(str), result);
	
	NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[md5String appendFormat:@"%02x", result[i]];
	}
	return md5String;
}

/// 时间戳
+ (NSString *)timestamp {
	NSInteger timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
	return @(timeInterval).description;
}

/// 快速生成Request
+ (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)HTTPMethod params:(NSDictionary *)paramDic {
	NSString *urlString = url.copy;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	if (paramDic.count) {
		NSString *parameters = paramStr(paramDic);
		if ([PLV_HM_GET isEqualToString:HTTPMethod]) {
			urlString = [NSString stringWithFormat:@"%@?%@", urlString, parameters];
		}else if ([PLV_HM_POST isEqualToString:HTTPMethod]){
			NSData *bodyData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
			request.HTTPBody = bodyData;
		}
	}
	
	NSURL *URL = [NSURL URLWithString:urlString];
	request.URL = URL;
	request.HTTPMethod = HTTPMethod;
	request.timeoutInterval = 10;
	if (PLVNetworkingLogEnable) NSLog(@"%@ - 参数列表 = %@\t%@\n\n", url, paramDic, urlString);
	
	//NSString *userAgent = [NSString stringWithFormat:@"polyv-ios-sdk_%@", PLVVodSdkVersion];
	//[request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	return request;
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
+ (void)requestDictionary:(NSURLRequest *)request completion:(void (^)(NSDictionary *dic, NSError *error))completion {
	[self requestData:request completion:^(NSData *data, NSError *error) {
		if (error) {
			if (completion) completion(nil, error);
			return;
		}
		
		NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
		if (error){
			NSLog(@"JSONReading error = %@", error.localizedDescription);
			if (PLVNetworkingLogEnable) NSLog(@"%@ - 请求结果 = \n%@", request.URL, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
			if (completion) completion(nil, error);
			return;
		}
		if (PLVNetworkingLogEnable) NSLog(@"%@ - 请求结果 = %@", request.URL, responseDic);
		PLVNetworkingLogEnable = NO;
		if (completion) completion(responseDic, nil);
	}];
}

#pragma mark - API

/// 请求课程列表
+ (void)requestCoursesWithCompletion:(void (^)(NSArray *courses))completion {
	[self requestCoursesWithPage:1 pageCount:100 optionalParams:nil completion:completion];
}
+ (void)requestCoursesWithPage:(NSInteger)page pageCount:(NSInteger)pageCount optionalParams:(NSDictionary *)optionalParams completion:(void (^)(NSArray *courses))completion {
	PLVSchool *school = [PLVSchool sharedInstance];
	NSString *url = [NSString stringWithFormat:@"http://%@/api/courses", school.host];
	__block NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params addEntriesFromDictionary:optionalParams];
	params[@"school_id"] = school.schoolId;
	params[@"page"] = @(page);
	params[@"page_size"] = @(pageCount);
	__weak typeof(self) weakSelf = self;
	[self requestSchoolTokenWithCompletion:^(NSString *token) {
		params[@"access_token"] = token;
		NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HM_GET params:params];
		[weakSelf requestDictionary:request completion:^(NSDictionary *dic, NSError *error) {
			if (error) {
				NSLog(@"request courses error: %@", error.localizedDescription);
				return;
			}
			NSInteger code = [dic[@"code"] integerValue];
			if (code != 200) {
				NSString *message = dic[@"message"];
				NSLog(@"request courses error: %@", message);
				return;
			}
			NSArray *courses = dic[@"data"][@"courses"];
			if (completion) {
				completion(courses);
			}
		}];
	}];
}

+ (void)requestSchoolTokenWithCompletion:(void (^)(NSString *token))completion {
	PLVSchool *school = [PLVSchool sharedInstance];
	NSString *url = [NSString stringWithFormat:@"http://%@/oauth2/authorize", school.host];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"api_id"] = school.apiId;
	params[@"school_id"] = school.schoolId;
	params[@"timestamp"] = [self timestamp];
	NSString *sign = [NSString stringWithFormat:@"%@&key=%@", paramStr(params), school.appSecretKey];
	sign = [self md5String:sign].uppercaseString;
	params[@"sign"] = sign;
	NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HM_GET params:params];
	[self requestDictionary:request completion:^(NSDictionary *dic, NSError *error) {
		if (error) {
			NSLog(@"request token error: %@", error.localizedDescription);
			return;
		}
		NSInteger code = [dic[@"code"] integerValue];
		if (code != 200) {
			NSString *message = dic[@"message"];
			NSLog(@"request token error: %@", message);
			return;
		}
		NSString *token = dic[@"data"][@"access_token"];
		if (completion) completion(token);
	}];
}


@end
