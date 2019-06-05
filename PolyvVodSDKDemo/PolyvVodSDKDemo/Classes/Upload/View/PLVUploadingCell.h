//
//  PLVUploadingCell.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/16.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVUploadModel;

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadingCell : UITableViewCell

@property (nonatomic, copy) void (^abortHandler)(void);

@property (nonatomic, copy) void (^retryHandler)(void);

@property (nonatomic, copy) void (^resumeHandler)(void);

- (void)setCellModel:(PLVUploadModel *)model;

@end

NS_ASSUME_NONNULL_END
