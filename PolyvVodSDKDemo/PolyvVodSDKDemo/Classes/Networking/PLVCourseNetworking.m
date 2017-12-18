//
//  PLVCourseNetworking.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseNetworking.h"
#import "NSString+PLVVod.h"

#import "PLVSchool.h"
#import "PLVCourse.h"
#import "PLVTeacher.h"
#import "PLVCourseSection.h"
#import "PLVVodAccountVideo.h"
#import <PLVVodSDK/PLVVodSettings.h>

#define PLV_HM_POST @"POST"
#define PLV_HM_GET @"GET"

static BOOL PLVNetworkingLogEnable;
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

@implementation PLVCourseNetworking

#pragma mark - tool

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
			//if (PLVNetworkingLogEnable)
				NSLog(@"%@ - 请求结果 = \n%@", request.URL, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
			if (completion) completion(nil, error);
			return;
		}
		if (PLVNetworkingLogEnable) NSLog(@"%@ - 请求结果 = %@", request.URL, responseDic);
		PLVNetworkingLogEnable = NO;
		if (completion) completion(responseDic, nil);
	}];
}

/// 生成签名
+ (NSString *)signWithParams:(NSDictionary *)params secretKey:(NSString *)secretKey {
	NSArray *keys = params.allKeys;
	keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
		return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
	}];
	NSMutableString *plainSign = [NSMutableString string];
	for (int i = 0; i < keys.count; i ++) {
		NSString *key = keys[i];
		[plainSign appendFormat:@"%@%@", key, params[key]];
	}
	plainSign = [NSMutableString stringWithFormat:@"%@%@%@", secretKey, plainSign, secretKey];
	return plainSign.md5.uppercaseString;
}

#pragma mark - API

/// 获取课程课时
+ (void)requestCourseVideosWithCourseId:(NSString *)courseId completion:(void (^)(NSArray *videoSections))completion {
	PLVSchool *school = [PLVSchool sharedInstance];
	NSString *secretKey = school.schoolKey;
	NSString *url = [NSString stringWithFormat:@"http://%@/api/curriculum/vod-open-curriculum", school.host];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"courseId"] = courseId;
	params[@"timestamp"] = [self timestamp];
	params[@"sign"] = [self signWithParams:params secretKey:secretKey];
	NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HM_GET params:params];
	[self requestDictionary:request completion:^(NSDictionary *dic, NSError *error) {
		//NSLog(@"%@, %@", courseId, dic);
		NSInteger code = [dic[@"code"] integerValue];
		if (code != 200) {
			NSString *status = dic[@"status"];
			NSString *message = dic[@"message"];
			NSLog(@"%@, %@", status, message);
			return;
		}
		NSArray *data = dic[@"data"];
		NSArray *videoSections = [PLVCourseSection sectionsWithArray:data];
		if (completion) {
			completion(videoSections);
		}
	}];
}

/// 请求点播公开课课程列表
+ (void)requestCoursesWithCompletion:(void (^)(NSArray<PLVCourse *> *courses))completion {
	NSMutableDictionary *optionalParams = [NSMutableDictionary dictionary];
	optionalParams[@"page"] = @1;
	optionalParams[@"pageSize"] = @100;
	//PLVNetworkingLogEnable = YES;
	[self requestCoursesWithOptionalParams:optionalParams completion:completion];
}
+ (void)requestCoursesWithOptionalParams:(NSDictionary *)optionalParams completion:(void (^)(NSArray<PLVCourse *> *courses))completion {
	PLVSchool *school = [PLVSchool sharedInstance];
	NSString *secretKey = school.schoolKey;
	NSString *url = [NSString stringWithFormat:@"http://%@/api/course/vod-open-courses", school.host];
	__block NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params addEntriesFromDictionary:optionalParams];
	params[@"timestamp"] = [self timestamp];
	params[@"sign"] = [self signWithParams:params secretKey:secretKey];
	NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HM_GET params:params];
	[self requestDictionary:request completion:^(NSDictionary *dic, NSError *error) {
		NSInteger code = [dic[@"code"] integerValue];
		if (code != 200) {
			NSString *status = dic[@"status"];
			NSString *message = dic[@"message"];
			NSLog(@"%@, %@", status, message);
			return;
		}
		NSArray *data = dic[@"data"][@"contents"];
		NSMutableArray *courses = [NSMutableArray array];
		for (NSDictionary *courseDic in data) {
			PLVCourse *course = [[PLVCourse alloc] initWithDic:courseDic];
			[courses addObject:course];
		}
		if (completion) completion(courses);
	}];
}

/// 请求账户下的视频列表
+ (void)requestAccountVideoWithPageCount:(NSInteger)pageCount page:(NSInteger)page completion:(void (^)(NSArray<PLVVodAccountVideo *> *accountVideos))completion; {
	PLVVodSettings *settings = [PLVVodSettings sharedSettings];
	NSString *url = [NSString stringWithFormat:@"http://api.polyv.net/v2/video/%@/list", settings.userid];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"userid"] = settings.userid;
	params[@"ptime"] = [self timestamp];
	params[@"numPerPage"] = @(pageCount);
	params[@"pageNum"] = @(page);
	
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
	NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HM_GET params:params];
	[self requestDictionary:request completion:^(NSDictionary *dic, NSError *error) {
		NSInteger code = [dic[@"code"] integerValue];
		if (code != 200) {
			NSString *status = dic[@"status"];
			NSString *message = dic[@"message"];
			NSLog(@"%@, %@", status, message);
			return;
		}
		NSArray *videos = dic[@"data"];
		NSMutableArray *accountVideos = [NSMutableArray array];
		for (NSDictionary *videoDic in videos) {
			PLVVodAccountVideo *video = [[PLVVodAccountVideo alloc] initWithDic:videoDic];
			if (video.status < 60 || video.duration < 1) {
				continue;
			}
			[accountVideos addObject:video];
		}
		if (completion) completion(accountVideos);
	}];
}

@end
