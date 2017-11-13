//
//  PLVSchool.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/10.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "PLVSchool.h"

@implementation PLVSchool

static id _sharedInstance = nil;

#pragma mark - singleton init

/// 静态对象
+ (instancetype)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
		[_sharedInstance commonInit];
	});
	return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!_sharedInstance) {
			_sharedInstance = [super allocWithZone:zone];
		}
	});
	return _sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
	return _sharedInstance;
}

- (void)commonInit {
	_host = @"demo.vlms.cn";
	_apiId = @"02419528";
	_schoolId = @"demo";
	_appSecretKey = @"F3E427FD5C30EAE3BFA57A7C8D4F06E9";
	_sdkKey = @"CMWht3MlpVkgpFzrLNAebYi4RdQDY/Nhvk3Kc+qWcck6chwHYKfl9o2aOVBvXVTRZD/14XFzVP7U5un43caq1FXwl0cYmTfimjTmNUYa1sZC1pkHE8gEsRpwpweQtEIiTGVEWrYVNo4/o5jI2/efzA==";
}

@end
