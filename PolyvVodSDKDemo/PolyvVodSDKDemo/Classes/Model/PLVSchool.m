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
	// 网校信息
	self.host = @"sdk.dewx.net";
	self.schoolKey = @"989BCBAD980580763EC113D3602C985C";
}

@end
