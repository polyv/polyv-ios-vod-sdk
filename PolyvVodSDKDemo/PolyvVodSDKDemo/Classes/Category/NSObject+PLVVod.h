//
//  NSObject+PLVVod.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/30.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PLVVod)

/// 交换方法
+ (void)exchangeMethod:(SEL)originalSelector toMethod:(SEL)swizzledSelector;

@end
