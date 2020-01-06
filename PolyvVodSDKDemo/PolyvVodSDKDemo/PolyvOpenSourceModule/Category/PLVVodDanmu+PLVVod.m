//
//  PLVVodDanmu+PLVVod.m
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/11/29.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodDanmu+PLVVod.h"
#import "PLVVodNetworkUtil.h"

@implementation PLVVodDanmu (PLVVod)

+ (instancetype)danmuWithDic:(NSDictionary *)dic {
	PLVVodDanmu *danmu = [[PLVVodDanmu alloc] init];
	danmu.content = dic[@"msg"];
	danmu.time = [self secondsWithtimeString:dic[@"time"]];
	danmu.fontSize = [dic[@"fontSize"] intValue];
	
	NSString *color = [dic[@"fontColor"] lowercaseString];
	if ([color hasPrefix:@"0x"]) {
		color = [color substringFromIndex:2];
	}
	if (color.length) {
		NSScanner *scanner = [NSScanner scannerWithString:color];
		unsigned int colorHex;
		if (![scanner scanHexInt:&colorHex]) colorHex = 0xFFFFFF;
		danmu.colorHex = colorHex;
	}
	return danmu;
}

/// 字符串转时间
+ (NSTimeInterval)secondsWithtimeString:(NSString *)timeString {
	NSArray *timeComponents = [timeString componentsSeparatedByString:@":"];
	NSTimeInterval seconds = 0;
	int componentCount = 3;
	if (timeComponents.count < componentCount) {
		componentCount = (int)timeComponents.count;
	}
	for (int i = 0; i < componentCount; i++) {
		NSInteger index = timeComponents.count-1-i;
		NSTimeInterval timeComponent = [timeComponents[index] doubleValue];
		seconds += pow(60, i) * timeComponent;
	}
	return seconds;
//	return [[timeComponents objectAtIndex:0]intValue] * 60 * 60
//	+[[timeComponents objectAtIndex:1]intValue] * 60
//	+ [[timeComponents objectAtIndex:2]intValue];
}

+ (PLVVodDanmuMode)danmuModeWithDescription:(NSString *)description {
    NSString *lowerCaseDesc = description.lowercaseString;
	PLVVodDanmuMode mode = PLVVodDanmuModeRoll;
	if ([lowerCaseDesc isEqualToString:@"roll"]) {
		mode = PLVVodDanmuModeRoll;
	} else if ([lowerCaseDesc isEqualToString:@"top"]) {
		mode = PLVVodDanmuModeTop;
	} else if ([lowerCaseDesc isEqualToString:@"bottom"]) {
		mode = PLVVodDanmuModeBottom;
	}
	return mode;
}

#pragma mark - networking

+ (void)sendDanmu:(NSString *)danmu vid:(NSString *)vid time:(NSTimeInterval)time fontSize:(double)fontSize color:(NSUInteger)colorHex mode:(NSInteger)mode completion:(void (^)(NSError *error, NSString * danmuId))completion {
	NSString *url = @"https://api.polyv.net/v2/danmu/add";
	NSString *modelName = nil;
	switch (mode) {
		case PLVVodDanmuModeRoll:{
			modelName = @"roll";
		}break;
		case PLVVodDanmuModeTop:{
			modelName = @"top";
		}break;
		case PLVVodDanmuModeBottom:{
			modelName = @"bottom";
		}break;
		default:{}break;
	}
    
    NSInteger seconds = time;
    NSString * hStr = [NSString stringWithFormat:@"%02zd",seconds/60/60];
    NSString * mStr = [NSString stringWithFormat:@"%02zd",(seconds/60)%60];
    NSString * sStr = [NSString stringWithFormat:@"%02zd",seconds%60];
    NSString * timeStr = [NSString stringWithFormat:@"%@:%@:%@",hStr,mStr,sStr];
    
    // 清除开头空格
    NSString *danmuMsg = nil;
    if (danmu.length){
        danmuMsg = [danmu stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"vid"] = vid;
	params[@"msg"] = danmuMsg;
	params[@"time"] = timeStr;
	params[@"fontSize"] = @((int)fontSize);
	params[@"fontMode"] = modelName;
	params[@"fontColor"] = [NSString stringWithFormat:@"0x%08x", (uint)colorHex];
	NSInteger timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
	params[@"timestamp"] = @(timeInterval).description;
    
//    url = [NSString stringWithFormat:@"%@?%@", url, [PLVVodNetworkUtil convertDictionaryToSortedString:params]];
//    url = [self urlEncode:url];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSMutableURLRequest *request = [self requestWithUrl:url method:@"POST" params:params];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		NSInteger httpStatusCode = httpResponse.statusCode;
		if (error) { // 网络错误
			NSLog(@"网络错误: %@", error);
            if (completion) { completion(error, nil); }
		} else if (httpStatusCode != 200) { // 服务器错误
			NSString *errorMessage = [NSString stringWithFormat:@"服务器响应失败，状态码:%zd",httpResponse.statusCode];
			NSLog(@"%@，服务器错误: %@", request.URL.absoluteString, errorMessage);
            if (completion) { completion(error, nil); }
        }else{
            NSDictionary * responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            NSDictionary * resData = responseDic[@"data"];
            NSString *danmuId = nil;
            if ([resData isKindOfClass:[NSDictionary class]]){
                danmuId = [resData objectForKey:@"id"];
            }
            if (completion) { completion(nil, danmuId); }
        }
	}] resume];
}

/// 加载弹幕
+ (void)requestDanmusWithVid:(NSString *)vid maxCount:(NSInteger)maxCount completion:(void (^)(NSArray *danmus, NSError *error))completion {
	NSString *url = @"https://api.polyv.net/v2/danmu";
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"vid"] = vid;
    if (maxCount > 0) {
        params[@"limit"] = @(maxCount);
    }
	url = [NSString stringWithFormat:@"%@?%@", url, [PLVVodNetworkUtil convertDictionaryToSortedString:params]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [PLVVodNetworkUtil requestData:request completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error){
                NSLog(@"JSONReading error = %@", error.localizedDescription);
            } else if ([responseDic isKindOfClass:[NSArray class]]) {
                !completion ?: completion((NSArray *)responseDic, nil);
            }
        }
    }];
}

+ (NSString *)urlEncode:(NSString *)url{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)url,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

/// 快速生成Request
+ (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)HTTPMethod params:(NSDictionary *)paramDic {
    NSString *urlString = url.copy;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if (paramDic.count) {
        NSString *parameters = [PLVVodNetworkUtil convertDictionaryToSortedString:paramDic];
        NSData *bodyData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = bodyData;
    }
    
    NSURL *URL = [NSURL URLWithString:urlString];
    request.URL = URL;
    request.HTTPMethod = HTTPMethod;
    request.timeoutInterval = 10;

    return request;
}




#pragma mark -public

/// 发送弹幕
- (void)sendDammuWithVid:(NSString *)vid completion:(void (^)(NSError *error, NSString * danmuId))completion {
	[self.class sendDanmu:self.content vid:vid time:self.time fontSize:self.fontSize color:self.colorHex mode:self.mode completion:completion];
	[[NSNotificationCenter defaultCenter] postNotificationName:PLVVodDanmuDidSendNotification object:self];
}

/// 加载弹幕
+ (void)requestDanmusWithVid:(NSString *)vid completion:(void (^)(NSArray<PLVVodDanmu *> *danmus, NSError *error))completion {
	[self requestDanmusWithVid:vid maxCount:200 completion:^(NSArray *danmus, NSError *error) {
		if (error && completion) {
			completion(nil, error);
		}
		NSMutableArray *danmuModels = [NSMutableArray array];
		for (NSDictionary *dic in danmus) {
			PLVVodDanmu *danmu = [self danmuWithDic:dic];
			[danmuModels addObject:danmu];
		}
		if (completion) completion(danmuModels, nil);
	}];
}

@end
