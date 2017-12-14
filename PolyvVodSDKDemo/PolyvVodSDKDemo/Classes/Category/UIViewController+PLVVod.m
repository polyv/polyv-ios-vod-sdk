//
//  UIViewController+PLVVod.m
//  PolyvVodSDK
//
//  Created by BqLin on 2017/10/30.
//  Copyright © 2017年 POLYV. All rights reserved.
//

#import "UIViewController+PLVVod.h"
#import <objc/runtime.h>
#import "NSObject+PLVVod.h"
//#import "PLVVodUtil.h"

static void *PLVVodAutoHideNavigationBarKey = &PLVVodAutoHideNavigationBarKey;

@interface UIViewController ()

@end

@implementation UIViewController (PLVVod)

#pragma mark - property

- (BOOL)plv_autoHideNavigationBar {
	NSNumber *value = objc_getAssociatedObject(self, &PLVVodAutoHideNavigationBarKey);
	return value.boolValue;
}
- (void)setPlv_autoHideNavigationBar:(BOOL)plv_autoHideNavigationBar {
	objc_setAssociatedObject(self, &PLVVodAutoHideNavigationBarKey, @(plv_autoHideNavigationBar), OBJC_ASSOCIATION_COPY);
}

#pragma mark - inject

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self exchangeMethod:@selector(viewWillAppear:) toMethod:@selector(plv_viewWillAppear:)];
		[self exchangeMethod:@selector(viewWillDisappear:) toMethod:@selector(plv_viewWillDisappear:)];
	});
}

- (void)plv_viewWillAppear:(BOOL)animated {
	[self plv_viewWillAppear:animated];
	[self addOrientationObserver];
}
- (void)plv_viewWillDisappear:(BOOL)animated {
	[self plv_viewWillDisappear:animated];
	[self removeOrientationObserver];
}

- (void)addOrientationObserver {
	UIDevice *device = [UIDevice currentDevice];
	[device beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:device];
	[self orientationDidChanged:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	[self interfaceOrientationDidChange:nil];
}

- (void)removeOrientationObserver {
	UIDevice *device = [UIDevice currentDevice];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
	[device endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
	UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
	BOOL hideNavigationBar = NO;
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:{
			hideNavigationBar = NO;
		}break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		case UIInterfaceOrientationPortraitUpsideDown:{
			hideNavigationBar = YES;
		}break;
		default:{}break;
	}
	if (self.navigationController && self.plv_autoHideNavigationBar) {
		//NSLog(@"_interface orientation: %@", NSStringFromUIDeviceOrientation((UIDeviceOrientation)interfaceOrientation));
		[self.navigationController setNavigationBarHidden:hideNavigationBar animated:YES];
	}
}

- (void)orientationDidChanged:(NSNotification *)notification {
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
	
	switch (deviceOrientation) {
		case UIDeviceOrientationPortrait:{
			
		}break;
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
		case UIDeviceOrientationPortraitUpsideDown:{
			
		}break;
		default:{}break;
	}
	if (self.plv_autoHideNavigationBar) {
		//NSLog(@"_device orientation: %@", NSStringFromUIDeviceOrientation(deviceOrientation));
	}
}

@end
