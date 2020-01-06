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
	
	// 对应的点播账号信息
    BOOL userDefault = YES;
    if (userDefault){
        
        // 网校
        //self.vodKey = @"yQRmgnzPyCUYDx6weXRATIN8gkp7BYGAl3ATjE/jHZunrULx8CoKa1WGMjfHftVChhIQlCA9bFeDDX+ThiuBHLjsNRjotqxhiz97ZjYaCQH/MhUrbEURv58317PwPuGEf3rbLVPOa4c9jliBcO+22A==";

        
        // xyj
        //self.vodKey = @"oX+TWj5UAMrGzMcY/eRvW5i5SeYWaore3TUCOzox6BkEWHvkK3dttoFyA6gmYyIhWSpsDns0wHwBQKIZvMFDlTd3FquD8SpYzIq+DegtKT/2e6y6gO9BoLCj3arSZa++gKXRspyXr4mjK0DQr7ildQ==";
        
        // xiuzhu
//        self.vodKey = @"q+IymS51UBFVSXdsS/HWHaguQuQ8M923Ow+Ajx0BxlvbNBGVmW0XVbir12ebEg7tEvVukaBpqciLIvfKxKSL4VuK1q3B0t6vRhZ8hL4CROZp2mo6cpM0EoQgqaD1d/4yL/zrgxNyKrIZWnl43lcwLg==";
        
        // lien
//        self.vodKey = @"3pWUjhGKgwrVux6/+IUwrIyW6w/NRUAlzuTjp8eF060UX9LzDvvbu3w7CXjxE0p/a9t/iCpGCMEbsD4/ujqOgzmQkCPECmKgNC/GnP2r/V9XwoxhWIqFic/ffSGyR0Bl3ebakdu9a4nUe+GvQ8bJsA==";
        
        // peisi
        self.vodKey = @"DkkFJBbqPDRH4irrbAijiLlPgU7WYN510ol9YmjW/yJ6mivM4k5dhpnWioVrws1zfst1+abhuvyktxMRXK7nesmaw17vs13pFqUKwAiCrxx7qb9HzayomHz0dAXKnrCTbQYA3YmYdNjEuF5FLyLP0Q==";
               
        // polyv
//        self.vodKey = @"yQRmgnzPyCUYDx6weXRATIN8gkp7BYGAl3ATjE/jHZunrULx8CoKa1WGMjfHftVChhIQlCA9bFeDDX+ThiuBHLjsNRjotqxhiz97ZjYaCQH/MhUrbEURv58317PwPuGEf3rbLVPOa4c9jliBcO+22A==";
        
        self.vodKeyDecodeKey = @"VXtlHmwfS2oYm0CZ";
        self.vodKeyDecodeIv = @"2u9gDPKdX6GyQJKU";

    }
    else{
        
        // TODO： 配置个人账号信息，方便测试
       
    }
}

@end
