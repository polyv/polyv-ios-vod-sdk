//
//  AppDelegate.m
//  PolyvVodSDKDemo
//
//  Created by BqLin on 2017/11/9.
//  Copyright © 2017年 BqLin. All rights reserved.
//

#import "AppDelegate.h"
#import "PLVCourseNetworking.h"
#import "PLVCourse.h"
#import <PLVVodSDK/PLVVodSDK.h>
#import "PLVSchool.h"
#import "PLVVodAccountVideo.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	NSError *error = nil;
	PLVSchool *school = [PLVSchool sharedInstance];
	NSString *vodKey = school.vodKey;
	NSString *decodeKey = school.vodKeyDecodeKey;
	NSString *decodeIv = school.vodKeyDecodeIv;
	vodKey = @"v4yoqNIHwZ69WNbOTI4rzDRHbwjUYsh14V1Czv7CNhwRE3EGBEleaezLNZms14CKhxu+KB+OPH341zknQ5+7gE5UZnz4u5V0jP+SCO9kaRwthY4UyvZ3ClHgnSBEZoTCkwrYQ+sgLVIRhjo2y+uZIQ==";
	PLVVodSettings *settings = [PLVVodSettings settingsWithConfigString:vodKey key:decodeKey iv:decodeIv error:&error];
	NSLog(@"settings: %@", settings);
	if (error) {
		NSLog(@"account settings error: %@", error);
	}
	
	// 接收远程事件
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
	
	return YES;
}

/// 转发远程事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
	[[NSNotificationCenter defaultCenter] postNotificationName:PLVVodRemoteControlEventDidReceiveNotification object:self userInfo:@{PLVVodRemoteControlEventKey: event}];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
