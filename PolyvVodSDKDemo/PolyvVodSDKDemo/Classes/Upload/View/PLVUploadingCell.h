//
//  PLVUploadingCell.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/16.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVUploadCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadingCell : PLVUploadCell

@property (nonatomic, copy) void (^abortHandler)(void);

@property (nonatomic, copy) void (^retryHandler)(void);

@property (nonatomic, copy) void (^resumeHandler)(void);

@end

NS_ASSUME_NONNULL_END
