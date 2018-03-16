//
//  UIControl+PLVVod.m
//  PolyvVodSDKDemo
//
//  Created by Bq Lin on 2018/3/2.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import "UIControl+PLVVod.h"
#import <objc/runtime.h>

static void *AcceptEventIntervalKey = &AcceptEventIntervalKey;
static void *IgnoreEventKey = &IgnoreEventKey;

@implementation UIControl (PLVVod)

- (NSTimeInterval)acceptEventInterval {
	return [objc_getAssociatedObject(self, AcceptEventIntervalKey) doubleValue];
}

- (void)setAcceptEventInterval:(NSTimeInterval)acceptEventInterval {
	objc_setAssociatedObject(self, AcceptEventIntervalKey, @(acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ignoreEvent {
	return [objc_getAssociatedObject(self, IgnoreEventKey) boolValue];
}

- (void)setIgnoreEvent:(BOOL)ignoreEvent {
	objc_setAssociatedObject(self, IgnoreEventKey, @(ignoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
	Method a = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
	Method b = class_getInstanceMethod(self, @selector(_sendAction:to:forEvent:));
	
	method_exchangeImplementations(a, b);
}

- (void)_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
	if (self.ignoreEvent) return;
	if (self.acceptEventInterval > 0) {
		self.ignoreEvent = YES;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setIgnoreEvent:) object:nil];
		[self performSelector:@selector(setIgnoreEvent:) withObject:@(NO) afterDelay:self.acceptEventInterval];
	}
	
	[self _sendAction:action to:target forEvent:event];
}

@end
