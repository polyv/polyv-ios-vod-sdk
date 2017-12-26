//
//  UIColor+PLVVod.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/11/21.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "UIColor+PLVVod.h"

@implementation UIColor (PLVVod)

+ (UIColor *)colorWithHex:(NSUInteger)hexValue {
	return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
						   green:((float)((hexValue & 0xFF00) >> 8))/255.0
							blue:((float)(hexValue & 0xFF))/255.0
						   alpha:1.0];
}

- (NSUInteger)hex {
	if (self == [UIColor whiteColor]) {
		return 0xffffff;
	}
	CGFloat red, green, blue, alpha;
	if (![self getRed:&red green:&green blue:&blue alpha:&alpha]) {
		[self getWhite:&red alpha:&alpha];
		green = red;
		blue = red;
	}
	
	red = roundf(red * 255.f);
	green = roundf(green * 255.f);
	blue = roundf(blue * 255.f);
	alpha = roundf(alpha * 255.f);
	
	return ((uint)alpha << 24) | ((uint)red << 16) | ((uint)green << 8) | ((uint)blue);
}

+ (UIColor *)themeColor {
	return [UIColor colorWithHex:0x2196F3];
}
+ (UIColor *)themeBackgroundColor {
	return [UIColor colorWithHex:0xE9EBF5];
}

@end
