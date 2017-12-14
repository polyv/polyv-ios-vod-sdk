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

/// 获取所在的视图控制器
- (UIViewController *)viewController {
	UIResponder *responder = self;
	while ((responder = [responder nextResponder]))
		if ([responder isKindOfClass: [UIViewController class]])
			return (UIViewController *)responder;
	return nil;
}

/// 返回所在的导航控制器
- (UINavigationController *)navigationController {
	UIResponder *responder = self;
	while ((responder = [responder nextResponder]))
		if ([responder isKindOfClass: [UINavigationController class]])
			return (UINavigationController *)responder;
	return nil;
}

@end
