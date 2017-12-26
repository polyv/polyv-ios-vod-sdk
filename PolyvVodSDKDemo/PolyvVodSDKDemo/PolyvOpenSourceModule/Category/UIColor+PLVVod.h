//
//  UIColor+PLVVod.h
//  PolyvVodSDK
//
//  Created by BqLin on 2017/11/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (PLVVod)

@property (nonatomic, assign, readonly) NSUInteger hex;

+ (UIColor *)colorWithHex:(NSUInteger)hexValue;

+ (UIColor *)themeColor;
+ (UIColor *)themeBackgroundColor;

@end
