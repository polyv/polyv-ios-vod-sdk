//
//  NSString+PLVVod.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2017/12/14.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "NSString+PLVVod.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (PLVVod)

- (NSString *)md5 {
	const char* str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (CC_LONG)strlen(str), result);
	
	NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
	for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
		[ret appendFormat:@"%02x",result[i]];
	}
	return ret;
}

- (NSString *)sha1 {
	const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	
	NSData *data = [NSData dataWithBytes:cstr length:self.length];
	//使用对应的CC_SHA1,CC_SHA256,CC_SHA384,CC_SHA512的长度分别是20,32,48,64
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	//使用对应的CC_SHA256,CC_SHA384,CC_SHA512
	CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
	
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];
	
	return output;
}

@end
