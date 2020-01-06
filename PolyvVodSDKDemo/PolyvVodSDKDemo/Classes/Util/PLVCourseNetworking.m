//
//  PLVCourseNetworking.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVCourseNetworking.h"
#import "PLVVodNetworkUtil.h"
#import "NSString+PLVVod.h"

#import "PLVSchool.h"
#import "PLVCourse.h"
#import "PLVCourseSection.h"
#import "PLVVodAccountVideo.h"

#define PLV_HM_POST @"POST"
#define PLV_HM_GET @"GET"

@implementation PLVCourseNetworking

#pragma mark - tool

/// 时间戳
+ (NSString *)timestamp {
	float timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    NSString *timeStr = [NSString stringWithFormat:@"%.0f", timeInterval];
    return timeStr;
}

/// 快速生成Request
+ (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)HTTPMethod params:(NSDictionary *)paramDic {
	NSString *urlString = url.copy;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	if (paramDic.count) {
        NSString *parameters = [PLVVodNetworkUtil convertDictionaryToSortedString:paramDic];
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
	
	//NSString *userAgent = [NSString stringWithFormat:@"polyv-ios-sdk_%@", PLVVodSdkVersion];
	//[request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	return request;
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
    [PLVVodNetworkUtil requestData:request success:^(NSDictionary * _Nonnull dic) {
        NSArray *data = dic[@"data"];
        NSArray *videoSections = [PLVCourseSection sectionsWithArray:data];
        !completion ?: completion(videoSections);
    } failure:nil];
}

/// 请求点播公开课课程列表
+ (void)requestCoursesWithCompletion:(void (^)(NSArray<PLVCourse *> *courses))completion {
	NSMutableDictionary *optionalParams = [NSMutableDictionary dictionary];
	optionalParams[@"page"] = @1;
	optionalParams[@"pageSize"] = @100;
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
    [PLVVodNetworkUtil requestData:request success:^(NSDictionary * _Nonnull dic) {
        NSArray *data = dic[@"data"][@"contents"];
        NSMutableArray *courses = [NSMutableArray array];
        for (NSDictionary *courseDic in data) {
            PLVCourse *course = [[PLVCourse alloc] initWithDic:courseDic];
            [courses addObject:course];
        }
        !completion ?: completion(courses);
    } failure:nil];
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
	
	NSMutableURLRequest *request = [self requestWithUrl:url method:PLV_HM_GET params:[PLVVodNetworkUtil addSign:params]];
    [PLVVodNetworkUtil requestData:request success:^(NSDictionary * _Nonnull dic) {
        NSArray *videos = dic[@"data"];
        NSMutableArray *accountVideos = [NSMutableArray array];
        for (NSDictionary *videoDic in videos) {
            PLVVodAccountVideo *video = [[PLVVodAccountVideo alloc] initWithDic:videoDic];
            if (video.status < 60 || video.duration < 1) {
                continue;
            }
            [accountVideos addObject:video];
        }
        !completion ?: completion(accountVideos);
    } failure:nil];
}

@end
