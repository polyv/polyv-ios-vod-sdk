//
//  PLVUploadUtil.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/28.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadUtil : NSObject

+ (instancetype)sharedUtil;

- (void)loginUploadClient;

- (void)uploadVideos:(NSArray *)filePathArray;

@end

NS_ASSUME_NONNULL_END
