//
//  UIView+PLVVod.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/30.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "UIView+PLVVod.h"

@implementation UIView (PLVVod)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	CGFloat widthDelta = CGRectGetWidth(self.bounds) > 44 ? 0 : 44 - CGRectGetWidth(self.bounds);
	CGFloat heightDelta = CGRectGetHeight(self.bounds) > 44 ? 0 : 44 - CGRectGetHeight(self.bounds);
	CGRect bounds = CGRectInset(self.bounds, -0.5 * widthDelta, -0.5 * heightDelta);
	return CGRectContainsPoint(bounds, point);
}

@end
