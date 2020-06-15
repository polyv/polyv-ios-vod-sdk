//
//  PLVVodAccount.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/6/1.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import "PLVVodAccount.h"

//#define PLV_VOD_KEY @""

#ifdef PLV_VOD_KEY
NSString *PLVVodConfigString = PLV_VOD_KEY;
#else
NSString *PLVVodConfigString =   @"yQRmgnzPyCUYDx6weXRATIN8gkp7BYGAl3ATjE/jHZunrULx8CoKa1WGMjfHftVChhIQlCA9bFeDDX+ThiuBHLjsNRjotqxhiz97ZjYaCQH/MhUrbEURv58317PwPuGEf3rbLVPOa4c9jliBcO+22A==";
#endif

NSString *PLVVodDecodeKey = @"VXtlHmwfS2oYm0CZ";
NSString *PLVVodDecodeIv = @"2u9gDPKdX6GyQJKU";

#pragma mark - 子账号登陆

// 主帐号加密key
NSString *PLVVodSecretKey = @"";

NSString *PLVVodUserId = @"";
NSString *PLVVodSubAccountAppId = @"";
NSString *PLVVodSubAccountSecretKey = @"";

@implementation PLVVodAccount

@end
