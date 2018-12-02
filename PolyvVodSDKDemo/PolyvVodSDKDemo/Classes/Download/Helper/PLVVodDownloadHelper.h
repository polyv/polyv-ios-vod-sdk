//
//  PLVVodDownloadHelper.h
//  PolyvVodSDKDemo
//
//  Created by mac on 2018/11/13.
//  Copyright © 2018年 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface PLVVodDownloadHelper : NSObject

+ (instancetype)shareInstance;

- (void)applicationWillEnterForeground;

- (void)applicationDidEnterBackground;

@end

NS_ASSUME_NONNULL_END
