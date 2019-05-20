//
//  PLVUploadCompleteData.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/4/22.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLVUploadUncompleteData, PLVUploadModel;

NS_ASSUME_NONNULL_BEGIN

@interface PLVUploadCompleteData : NSObject

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger fileSize;

@property (nonatomic, copy) NSDate *completeDate;

- (instancetype)initWithUncompleteData:(PLVUploadUncompleteData *)uncompleteData;

- (PLVUploadModel *)changeToModel;

@end

NS_ASSUME_NONNULL_END
