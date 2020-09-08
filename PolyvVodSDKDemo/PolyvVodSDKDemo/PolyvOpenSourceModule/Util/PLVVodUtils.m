//
//  PLVVodUtils.m
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/8/14.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import "PLVVodUtils.h"

@implementation PLVVodUtils

+ (void)changeDeviceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];//从2开始，因为0 1 两个参数已经被selector和target占用
        [invocation invoke];
    }
}

@end
