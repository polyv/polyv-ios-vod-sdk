//
//  PLVVodUtils.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2020/8/14.
//  Copyright © 2020 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define isIpad(newCollection) (newCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular && newCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular)

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodUtils : NSObject

+ (void)changeDeviceOrientation:(UIInterfaceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
