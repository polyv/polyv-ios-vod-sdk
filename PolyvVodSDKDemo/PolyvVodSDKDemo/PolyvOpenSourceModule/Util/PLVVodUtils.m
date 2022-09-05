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
    
    if (@available(iOS 16.0, *)) {
#ifdef __IPHONE_16_0
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *scene = (UIWindowScene *)array[0];
        UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAllButUpsideDown;
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight) {
            mask = UIInterfaceOrientationMaskLandscape;
        }else {
            mask = UIInterfaceOrientationMaskPortrait;
        }
        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:mask];
        [scene requestGeometryUpdateWithPreferences:geometryPreferences errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"iOS16旋转屏幕错误_%@", error);
        }];
#endif
    }else {
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
}

/// url safe Base64 编码
+ (NSString *)urlSafeBase64String:(NSString *)inputString {
    NSData *data = [inputString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return base64String;
}

+ (NSString *)pid {
    long timestamp = (long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    long rendom = arc4random_uniform(1000000) + 1000000;
    
    NSString *pid = [NSString stringWithFormat:@"%zdX%ld", timestamp, rendom];
    return pid;
}

@end
