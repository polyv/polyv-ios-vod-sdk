//
//  PLVVodDanmu+PLVVod.m
//  PolyvVodSDK
//
//  Created by Bq Lin on 2017/11/29.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVVodDanmu+PLVVod.h"

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
	description = description.lowercaseString;
	PLVVodDanmuMode mode = PLVVodDanmuModeRoll;
	if ([description isEqualToString:@"roll"]) {
		mode = PLVVodDanmuModeRoll;
	} else if ([description isEqualToString:@"top"]) {
		mode = PLVVodDanmuModeTop;
	} else if ([description isEqualToString:@"bottom"]) {
		mode = PLVVodDanmuModeBottom;
	}
	return mode;
}

#pragma mark - networking

+ (void)sendDanmu:(NSString *)danmu vid:(NSString *)vid time:(NSTimeInterval)time fontSize:(double)fontSize color:(NSUInteger)colorHex mode:(NSInteger)mode completion:(void (^)(NSError *error))completion {
	NSString *url = @"https://go.polyv.net/admin/add.php";
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
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"vid"] = vid;
	params[@"msg"] = danmu;
	params[@"time"] = @(time);
	params[@"fontSize"] = @((int)fontSize);
	params[@"fontMode"] = modelName;
	params[@"fontColor"] = [NSString stringWithFormat:@"0x%08x", (uint)colorHex];
	NSInteger timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
	params[@"timestamp"] = @(timeInterval).description;
	url = [NSString stringWithFormat:@"%@?%@", url, paramStr(params)];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		NSInteger httpStatusCode = httpResponse.statusCode;
		if (error) { // 网络错误
			NSLog(@"网络错误: %@", error);
		} else if (httpStatusCode != 200) { // 服务器错误
			NSString *errorMessage = [NSString stringWithFormat:@"服务器响应失败，状态码:%zd",httpResponse.statusCode];
			NSLog(@"%@，服务器错误: %@", request.URL.absoluteString, errorMessage);
		}
	}] resume];
}

/// 加载弹幕
+ (void)requestDanmusWithVid:(NSString *)vid maxCount:(NSInteger)maxCount completion:(void (^)(NSArray *danmus, NSError *error))completion {
	NSString *url = @"https://go.polyv.net/admin/printjson.php";
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	params[@"vid"] = vid;
	params[@"limit"] = @(maxCount);
	url = [NSString stringWithFormat:@"%@?%@", url, paramStr(params)];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
	
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		NSInteger httpStatusCode = httpResponse.statusCode;
		if (error) { // 网络错误
			NSLog(@"网络错误: %@", error);
		} else if (httpStatusCode != 200) { // 服务器错误
			NSString *errorMessage = [NSString stringWithFormat:@"服务器响应失败，状态码:%zd",httpResponse.statusCode];
			NSLog(@"%@，服务器错误: %@", request.URL.absoluteString, errorMessage);
		} else {
			NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
			if (error){
				NSLog(@"JSONReading error = %@", error.localizedDescription);
				return;
			}
			if ([responseDic isKindOfClass:[NSArray class]]) {
				if (completion) completion((NSArray *)responseDic, nil);
			}
		}
	}] resume];
}

#pragma mark -public

/// 发送弹幕
- (void)sendDammuWithVid:(NSString *)vid completion:(void (^)(NSError *error))completion {
	[self.class sendDanmu:self.content vid:vid time:self.time fontSize:self.fontSize color:self.colorHex mode:self.mode completion:completion];
	[[NSNotificationCenter defaultCenter] postNotificationName:PLVVodDanmuDidSendNotification object:self];
}

/// 加载弹幕
+ (void)requestDanmusWithVid:(NSString *)vid completion:(void (^)(NSArray<PLVVodDanmu *> *danmus, NSError *error))completion {
	[self requestDanmusWithVid:vid maxCount:100 completion:^(NSArray *danmus, NSError *error) {
		if (error) {
			if (completion) completion(nil, error);
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
